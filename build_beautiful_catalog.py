import re
import os
import json

base_path = "c:/Users/kevin/Documents/002 Kandy Shop"
index_html_path = os.path.join(base_path, "catalogo", "index.html")

with open(index_html_path, "r", encoding="utf-8") as f:
    old_index = f.read()

# Discover categories from index.html
existing_cats = re.findall(r'<section class="cat-section" id="(.*?)">\s*<h2 class="cat-title">(.*?)</h2>', old_index)
cat_info = {cat_id: title for cat_id, title in existing_cats}
cat_order = [cat_id for cat_id, _ in existing_cats]

# Some text categories mappings to IDs in index.html
KEYWORD_TO_ID = {
    "ANILLOS": "anillos",
    "ARNESES": "arneses",
    "BOLAS VAGINALES": "bolas",
    "BOMBAS": "bombas",
    "BONDAGE": "bondage",
    "COMESTIBLES": "comestibles",
    "ROPA COMESTIBLE": "comestibles",  # merge? or 'ropacomestible'
    "VIGORIZANTES": "vigorizantes",
    "DESPEDIDA": "despedida",
    "DILDOS": "dildos",
    "ENEMAS": "enemas",
    "ESTIMULANTES": "estimulantes",
    "FEROMONAS": "feromonas",
    "FUNDAS": "fundas",
    "MASTURBADORES": "masturbadores",
    "PLUG ANAL": "pluganal",
    "LENCERIA": "lenceria",
    "DISFRACES": "disfraces",
    "LIMPIADORES": "limpiadores",
    "LUBRICANTES": "lubricantes",
    "GELES LUBRICANTES": "lubricantes",
    "PRESERVATIVOS": "preservativos",
    "VIBRADORES": "vibradores",
    "SUCCIONADOR": "vibradores",
    "MASAJEADOR": "masajeadores"
}

# 1. Parse Image Map
images_map = {}
with open(os.path.join(base_path, "slide_images_map.txt"), "r", encoding="utf-8", errors="ignore") as f:
    for line in f:
        if ":" in line:
            slide, imgs = line.split(":", 1)
            # Find all imageX.ext
            found_imgs = re.findall(r'image\d+\.[a-zA-Z]+', imgs)
            # Remove image1 which is logo
            found_imgs = [i for i in found_imgs if not i.startswith("image1.")]
            images_map[slide.strip().lower()] = found_imgs

# 2. Parse Text
products = []
with open(os.path.join(base_path, "all_slides_text.txt"), "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

# Fix common encoding issues
replacements = {
    'ï¿½': '', 'Ã³': 'ó', 'Ã©': 'é', 'Ã­': 'í', 'Ã¡': 'á', 'Ãº': 'ú', 'Ã±': 'ñ', 
    'Ã ': 'Ó', 'Ã‰': 'É', 'Ã ': 'Í', 'Ã ': 'Á', 'Ãš': 'Ú', 'Ã‘': 'Ñ',
    'â€“': '-', 'â€™': "'", 'Â': ''
}
for k, v in replacements.items():
    content = content.replace(k, v)

# Process slides
slides_text = re.split(r'=== (slide\d+) ===', content)
current_category = "vibradores" # default fallback
for i in range(1, len(slides_text), 2):
    slide_id = slides_text[i].lower()
    text = slides_text[i+1].strip()
    
    # Try to find category in this text block
    for keyword, cat_id in KEYWORD_TO_ID.items():
        if re.search(r'\b' + re.escape(keyword) + r'\b', text, re.IGNORECASE):
            current_category = cat_id
            break
            
    # Extract products
    chunks = re.split(r'Precio\s*:', text)
    slide_products = []
    
    for c in chunks[:-1]: # the last chunk doesn't have a product BEFORE it
        words = c.split()
        if not words: continue
        
        # Look backwards for SKU
        sku = ""
        for w in reversed(words[-4:]): # check last 4 words for something looking like SKU
            if re.search(r'[0-9]', w) and len(w) >= 3:
                sku = w
                break
                
        # The remainder is a name?
        name_parts = []
        for w in reversed(words):
            if w == sku and not name_parts:
                pass # skip the sku itself
            elif w.lower() in ['kandy', 'sex', 'shop', '-', 'catálogo', '2025', '2026', 'hoja', '01']:
                pass # filter out header texts
            elif w.isupper() and w in KEYWORD_TO_ID:
                pass # skip standalone category markers
            else:
                name_parts.append(w)
        
        name = " ".join(reversed(name_parts)).strip()
        # Clean up name a bit more
        name = re.sub(r'^(?i)(KANDY SEX SHOP\s*-\s*CATÁLOGO\s*\d{4}\s*)+', '', name).strip()
        if not name: name = "Producto"
        
        slide_products.append({"name": name, "sku": sku})
        
    # Extract prices from the chunks
    prices = re.findall(r'\$\s*([\d\.,]+(?:\s*\d+)?)\s*pesos?', text)
    
    # Merge them
    imgs = images_map.get(slide_id.strip(), [])
    
    for idx, p in enumerate(slide_products):
        price = prices[idx] if idx < len(prices) else "0.00"
        price = price.replace(" ", "")
        
        # Fallback image if not enough
        img = imgs[idx] if idx < len(imgs) else "image_placeholder.jpg"
        
        products.append({
            "name": p["name"],
            "sku": p["sku"],
            "price": price,
            "img": img,
            "category": current_category,
            "slide": slide_id
        })

# Group by category
grouped = {}
for p in products:
    grouped.setdefault(p["category"], []).append(p)

print(f"Total products parsed: {len(products)}")

with open(os.path.join(base_path, "catalogo", "catalog_data.json"), "w", encoding="utf-8") as f:
    json.dump(grouped, f, indent=2, ensure_ascii=False)
