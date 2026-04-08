import re
import os

def normalize_sku(sku):
    if not sku: return ""
    return re.sub(r'[^A-Z0-9]', '', sku.upper())

def parse_text(file_path):
    slides = {}
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    parts = re.split(r'=== (slide\d+) ===', content)
    for i in range(1, len(parts), 2):
        slide_id = parts[i]
        text = parts[i+1].strip()
        
        products = []
        # Split by "Precio:"
        entries = re.split(r'Precio:', text)
        for chunk in entries[:-1]:
            # Look for SKU before "Precio"
            words = chunk.split()
            if not words: continue
            found_sku = None
            for w in reversed(words[-3:]):
                # Normalize and check if it's a valid SKU-like thing
                # (has numbers, at least 3 chars)
                if re.search(r'[0-9]', w) and len(w) >= 3:
                    found_sku = w
                    break
            if found_sku:
                products.append(found_sku)
        slides[slide_id] = products
    return slides

def parse_map(file_path):
    slides = {}
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            if ':' not in line: continue
            slide_id, images_str = line.split(':', 1)
            images = [img.strip() for img in images_str.split('|')]
            # Exclude image1.png (icon/logo)
            images = [img for img in images if 'image1.png' not in img]
            slides[slide_id.strip()] = images
    return slides

text_slides = parse_text('c:/Users/kevin/Documents/002 Kandy Shop/all_slides_text.txt')
map_slides = parse_map('c:/Users/kevin/Documents/002 Kandy Shop/slide_images_map.txt')

sku_to_image = {}
for slide_id, skus in text_slides.items():
    images = map_slides.get(slide_id, [])
    for i in range(min(len(skus), len(images))):
        norm = normalize_sku(skus[i])
        if norm:
            sku_to_image[norm] = images[i]

with open('c:/Users/kevin/Documents/002 Kandy Shop/catalogo/index_temp.html', 'r', encoding='utf-8') as f:
    html = f.read()

mismatches_count = 0
def update_product_card(match):
    global mismatches_count
    card_content = match.group(0)
    sku_match = re.search(r'class="sku">([^<]+)</div>', card_content)
    if sku_match:
        sku = sku_match.group(1).strip()
        norm = normalize_sku(sku)
        if norm in sku_to_image:
            new_img = sku_to_image[norm]
            current_img_match = re.search(r'src="images/([^"]+)"', card_content)
            if current_img_match:
                current_img = current_img_match.group(1)
                if current_img != new_img:
                    print(f"Fixing {sku}: {current_img} -> {new_img}")
                    card_content = card_content.replace(f'src="images/{current_img}"', f'src="images/{new_img}"')
                    mismatches_count += 1
    return card_content

updated_html = re.sub(r'<div class="product-card".*?</div>\s*</div>', update_product_card, html, flags=re.DOTALL)

print(f"Total fixes: {mismatches_count}")

with open('c:/Users/kevin/Documents/002 Kandy Shop/catalogo/index_temp.html', 'w', encoding='utf-8') as f:
    f.write(updated_html)
