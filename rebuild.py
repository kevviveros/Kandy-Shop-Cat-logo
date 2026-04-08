
import os
import re

index_temp_path = r"c:\Users\kevin\Documents\002 Kandy Shop\catalogo\index_temp.html"
index_final_path = r"c:\Users\kevin\Documents\002 Kandy Shop\catalogo\index.html"

# Read the temp file (it was saved as UTF8)
with open(index_temp_path, 'r', encoding='utf-8', errors='ignore') as f:
    raw_content = f.read()

# Extract all <section class="cat-section"> blocks
sections = re.findall(r'(?s)<section class="cat-section".*?</section>', raw_content)

# Clean up encoding artifacts in sections (others)
def clean_text(text):
    text = text.replace('ï¿½', '') # Common encoding mess
    text = text.replace('', '') # Remove replacement characters
    return text

cleaned_sections = [clean_text(s) for s in sections]

# If we have Vibradores, ensure it is first in the list
vibradores = None
other_sections = []
for s in cleaned_sections:
    if 'id="vibradores"' in s:
        vibradores = s
    else:
        other_sections.append(s)

ordered_sections = []
if vibradores:
    ordered_sections.append(vibradores)
ordered_sections.extend(other_sections)

all_sections_html = "\\n\\n".join(ordered_sections)

# Components from my turn history
style = """<style>
* {box-sizing: border-box; margin: 0; padding: 0}
:root {--pink: #FF20BF; --dpink: #c4007a; --dark: #ffffff; --card: #f7f7f7; --text: #1a1a1a; --sub: #888}
body {font-family: 'Poppins', sans-serif; background: #fff; color: #1a1a1a; margin: 0; padding: 0; overflow-x: hidden}

/* COVER */
#cover {
    height: 100svh; width: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center;
    background: linear-gradient(180deg, #1a0020 0%, #0d0d0d 100%); padding: 2rem; text-align: center; position: relative; overflow: hidden
}
#cover::before {
    content: ''; position: absolute; inset: 0; background: radial-gradient(circle at 50% 35%, rgba(255, 32, 191, .25) 0%, transparent 75%)
}
.cover-logo {
    font-size: 5.5rem; font-weight: 900; color: var(--pink); letter-spacing: 1px; line-height: 0.85; margin-bottom: 1rem; text-shadow: 0 0 50px rgba(255, 32, 191, .5)
}
.cover-sub {
    font-size: 1.45rem; font-weight: 700; color: #fff; margin-bottom: 0.5rem; letter-spacing: 12px; text-transform: uppercase
}
.cover-year {
    font-size: 1.2rem; color: rgba(255, 255, 255, .6); letter-spacing: 4px; font-weight: 300
}
.cover-divider {
    width: 60px; height: 3px; background: var(--pink); border-radius: 2px; margin: 2.5rem auto
}
.cover-tagline {
    font-size: .95rem; color: rgba(255, 255, 255, .7); max-width: 300px; line-height: 1.6; margin: 0 auto 2.5rem; font-weight: 300
}
.cover-btn {
    display: inline-block; padding: 1.1rem 3rem; background: var(--pink); color: #fff; font-weight: 700; font-size: 1.15rem; border-radius: 60px;
    text-decoration: none; box-shadow: 0 0 35px rgba(255, 32, 191, .45); transition: transform .2s, box-shadow .2s; border: none; cursor: pointer
}
.cover-btn:active { transform: scale(.95) }

/* NAV */
#nav-bar {
    position: fixed; top: 0; left: 0; right: 0; z-index: 100; background: rgba(255, 255, 255, 0.97); backdrop-filter: blur(10px);
    border-bottom: 2px solid rgba(255, 32, 191, 0.25); display: flex; align-items: center; padding: .7rem 1rem; gap: .8rem;
    transition: transform 0.3s ease, opacity 0.3s ease; transform: translateY(-101%); opacity: 0;
}
.nav-logo { font-size: 1.1rem; font-weight: 900; color: var(--pink); letter-spacing: 1px; cursor: pointer }
.nav-search { flex: 1; background: #f0f0f0; border: 1px solid #ddd; border-radius: 20px; padding: .4rem .9rem; color: #1a1a1a; font-size: .85rem; outline: none; font-family: inherit }

/* INDEX */
#cat-index { padding: 5rem 1rem 2rem; background: #fafafa; border-bottom: 1px solid #eee }
#cat-index h2 {
    font-size: 1.5rem; font-weight: 800; color: var(--pink); margin-bottom: 2rem; text-align: center; letter-spacing: 1px;
    text-transform: uppercase; display: flex; align-items: center; justify-content: center; gap: .6rem
}
.index-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: .7rem }
.index-card {
    background: #fff; border-radius: 14px; overflow: hidden; text-align: center; text-decoration: none; color: var(--text); border: 1px solid #eee;
    box-shadow: 0 2px 6px rgba(0, 0, 0, .06); transition: transform .2s, border-color .2s; display: flex; flex-direction: column; align-items: center; padding: .9rem .5rem .7rem
}
.index-card:active { transform: scale(.95); border-color: var(--pink) }
.index-emoji { font-size: 2rem; margin-bottom: .4rem }
.index-label { font-size: .65rem; font-weight: 600; line-height: 1.2; letter-spacing: .5px }

/* SECTIONS */
.cat-section { padding: 2rem 1rem 1rem; background: #fff }
.cat-title {
    font-size: 1.4rem; font-weight: 900; color: var(--pink); margin-bottom: 1.5rem; border-bottom: 2px solid rgba(255, 32, 191, .2);
    padding-bottom: .6rem; display: flex; align-items: center; gap: .5rem
}
.product-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: .9rem }
.product-card { background: #fff; border-radius: 16px; overflow: hidden; border: 1px solid #eee; box-shadow: 0 2px 8px rgba(0, 0, 0, .06); transition: border-color .2s }
.product-card:active { border-color: var(--pink) }
.product-img { width: 100%; aspect-ratio: 1; object-fit: contain; background: #fff; padding: .5rem; border-bottom: 1px solid #eee }
.product-info { padding: .7rem }
.product-name { font-size: .72rem; font-weight: 600; line-height: 1.3; margin-bottom: .2rem; color: #1a1a1a }
.product-price { font-size: .9rem; font-weight: 700; color: var(--pink) }
.sku { font-size: .55rem; color: #aaa; margin-top: .1rem }

/* FOOTER */
footer { background: #f9f9f9; border-top: 1px solid #eee; padding: 2.5rem 1rem; text-align: center }
footer p { color: #888; font-size: .75rem; line-height: 1.8 }

/* FLOATING MENU */
#menu-btn {
    position: fixed; bottom: 1.5rem; right: 1.5rem; z-index: 200; width: 60px; height: 60px; border-radius: 50%;
    background: var(--pink); border: none; box-shadow: 0 5px 20px rgba(255, 32, 191, .4); cursor: pointer; display: flex; align-items: center; justify-content: center; transition: transform .2s
}
#menu-btn:active { transform: scale(.9) }
#menu-btn svg { width: 26px; height: 26px; fill: #fff }
#cat-drawer {
    position: fixed; bottom: 0; left: 0; right: 0; z-index: 190; background: #fff; border-radius: 24px 24px 0 0;
    box-shadow: 0 -5px 30px rgba(0, 0, 0, .15); transform: translateY(100%); transition: transform .32s cubic-bezier(.4, 0, .2, 1);
    max-height: 80vh; overflow-y: auto
}
#cat-drawer.open { transform: translateY(0) }
.drawer-header { padding: 1.2rem; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center }
.drawer-header h3 { font-size: 1rem; color: var(--pink); font-weight: 800 }
.drawer-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: .6rem; padding: 1rem }
.drawer-link {
    display: flex; align-items: center; gap: .6rem; padding: .8rem; border-radius: 14px; background: #f8f8f8;
    text-decoration: none; color: #1a1a1a; font-size: .85rem; font-weight: 600; border: 1px solid transparent
}
.drawer-link:active { background: #fff0fb; border-color: var(--pink) }
#overlay { position: fixed; inset: 0; z-index: 180; background: rgba(0, 0, 0, .4); display: none }
#overlay.show { display: block }
</style>"""

cover = """<section id="cover">
  <div class="cover-logo">KANDY</div>
  <div class="cover-sub">SEX SHOP</div>
  <div class="cover-year">Catálogo 2026</div>
  <div class="cover-divider"></div>
  <p class="cover-tagline">Placer de calidad, discreción garantizada. Descubre nuestra colección completa.</p>
  <a href="javascript:void(0)" class="cover-btn" onclick="enterCatalog()">Ver Catálogo →</a>
</section>"""

nav = """<nav id="nav-bar">
  <div class="nav-logo" onclick="goHome()">KANDY</div>
  <input class="nav-search" type="search" id="search-input" placeholder="🔍 Buscar por nombre o SKU..." oninput="handleSearch(this.value)">
</nav>"""

index_html = """<section id="cat-index" aria-label="Índice de categorías">
  <h2>🏷️ CATEGORÍAS</h2>
  <div class="index-grid">
    <a href="#vibradores" class="index-card"><div class="index-emoji">💜</div><div class="index-label">Vibradores</div></a>
    <a href="#anillos" class="index-card"><div class="index-emoji">💍</div><div class="index-label">Anillos</div></a>
    <a href="#dildos" class="index-card"><div class="index-emoji">🔥</div><div class="index-label">Dildos</div></a>
    <a href="#lubricantes" class="index-card"><div class="index-emoji">💧</div><div class="index-label">Lubricantes</div></a>
    <a href="#lenceria" class="index-card"><div class="index-emoji">🖤</div><div class="index-label">Lencería</div></a>
    <a href="#masturbadores" class="index-card"><div class="index-emoji">🌀</div><div class="index-label">Masturbadores</div></a>
    <a href="#pluganal" class="index-card"><div class="index-emoji">🔮</div><div class="index-label">Plug Anal</div></a>
    <a href="#comestibles" class="index-card"><div class="index-emoji">🍬</div><div class="index-label">Comestibles</div></a>
    <a href="#arneses" class="index-card"><div class="index-emoji">🔗</div><div class="index-label">Arneses</div></a>
    <a href="#bolas" class="index-card"><div class="index-emoji">⚪</div><div class="index-label">Bolas Vaginales</div></a>
    <a href="#bombas" class="index-card"><div class="index-emoji">💨</div><div class="index-label">Bombas</div></a>
    <a href="#bondage" class="index-card"><div class="index-emoji">🔒</div><div class="index-label">Bondage</div></a>
    <a href="#despedida" class="index-card"><div class="index-emoji">🎉</div><div class="index-label">Despedida</div></a>
    <a href="#disfraces" class="index-card"><div class="index-emoji">💃</div><div class="index-label">Disfraces</div></a>
    <a href="#enemas" class="index-card"><div class="index-emoji">🚿</div><div class="index-label">Enemas</div></a>
    <a href="#estimulantes" class="index-card"><div class="index-emoji">⚡</div><div class="index-label">Estimulantes</div></a>
    <a href="#feromonas" class="index-card"><div class="index-emoji">✨</div><div class="index-label">Feromonas</div></a>
    <a href="#fundas" class="index-card"><div class="index-emoji">🧲</div><div class="index-label">Fundas</div></a>
    <a href="#preservativos" class="index-card"><div class="index-emoji">🛡️</div><div class="index-label">Preservativos</div></a>
    <a href="#masajeadores" class="index-card"><div class="index-emoji">💆</div><div class="index-label">Masajeadores</div></a>
  </div>
</section>"""

footer = """<footer id="footer">
  <p><strong>KANDY SEX SHOP</strong> &copy; 2026. Todos los derechos reservados.</p>
</footer>

<div id="overlay" onclick="closeDrawer()"></div>
<button id="menu-btn" onclick="toggleDrawer()">
  <svg viewBox="0 0 24 24"><path d="M3 6h18v2H3zm0 5h18v2H3zm0 5h18v2H3z"/></svg>
</button>

<div id="cat-drawer">
  <div class="drawer-header">
    <h3>📋 Categorías</h3>
    <button onclick="closeDrawer()" style="background:none;border:none;font-size:1.5rem;color:#ccc">✕</button>
  </div>
  <div class="drawer-grid">
    <a class="drawer-link" href="#vibradores" onclick="closeDrawer()"><span>💜</span> Vibradores</a>
    <a class="drawer-link" href="#anillos" onclick="closeDrawer()"><span>💍</span> Anillos</a>
    <a class="drawer-link" href="#dildos" onclick="closeDrawer()"><span>🔥</span> Dildos</a>
    <a class="drawer-link" href="#lubricantes" onclick="closeDrawer()"><span>💧</span> Lubricantes</a>
    <a class="drawer-link" href="#lenceria" onclick="closeDrawer()"><span>🖤</span> Lencería</a>
    <a class="drawer-link" href="#masturbadores" onclick="closeDrawer()"><span>🌀</span> Masturbadores</a>
    <a class="drawer-link" href="#pluganal" onclick="closeDrawer()"><span>🔮</span> Plug Anal</a>
    <a class="drawer-link" href="#comestibles" onclick="closeDrawer()"><span>🍬</span> Comestibles</a>
    <a class="drawer-link" href="#arneses" onclick="closeDrawer()"><span>🔗</span> Arneses</a>
    <a class="drawer-link" href="#bolas" onclick="closeDrawer()"><span>⚪</span> Bolas</a>
    <a class="drawer-link" href="#bombas" onclick="closeDrawer()"><span>💨</span> Bombas</a>
    <a class="drawer-link" href="#bondage" onclick="closeDrawer()"><span>🔒</span> Bondage</a>
    <a class="drawer-link" href="#despedida" onclick="closeDrawer()"><span>🎉</span> Despedida</a>
    <a class="drawer-link" href="#disfraces" onclick="closeDrawer()"><span>💃</span> Disfraces</a>
    <a class="drawer-link" href="#enemas" onclick="closeDrawer()"><span>🚿</span> Enemas</a>
    <a class="drawer-link" href="#estimulantes" onclick="closeDrawer()"><span>⚡</span> Estimulantes</a>
    <a class="drawer-link" href="#feromonas" onclick="closeDrawer()"><span>✨</span> Feromonas</a>
    <a class="drawer-link" href="#fundas" onclick="closeDrawer()"><span>🧲</span> Fundas</a>
    <a class="drawer-link" href="#preservativos" onclick="closeDrawer()"><span>🛡️</span> Preservativos</a>
    <a class="drawer-link" href="#masajeadores" onclick="closeDrawer()"><span>💆</span> Masajeadores</a>
  </div>
</div>"""

script = """<script>
window.addEventListener('scroll', () => {
  const nav = document.getElementById('nav-bar');
  if (window.scrollY > window.innerHeight * 0.3) {
    nav.style.transform = 'translateY(0)'; nav.style.opacity = '1';
  } else {
    nav.style.transform = 'translateY(-101%)'; nav.style.opacity = '0';
  }
});

function handleSearch(term) {
  term = term.toLowerCase().trim();
  const productCards = document.querySelectorAll('.product-card');
  const catSections = document.querySelectorAll('.cat-section');
  const catIndex = document.getElementById('cat-index');
  if (!term) {
    productCards.forEach(c => c.style.display = 'block');
    catSections.forEach(s => s.style.display = 'block');
    catIndex.style.display = 'block';
    return;
  }
  catIndex.style.display = 'none';
  productCards.forEach(card => {
    const name = (card.getAttribute('data-name') || '').toLowerCase();
    const sku = card.querySelector('.sku')?.innerText.toLowerCase() || "";
    card.style.display = (name.includes(term) || sku.includes(term)) ? 'block' : 'none';
  });
  catSections.forEach(s => {
    const visible = s.querySelectorAll('.product-card[style="display: block;"]').length;
    s.style.display = visible > 0 ? 'block' : 'none';
  });
}

function enterCatalog() {
  const target = document.getElementById('cat-index');
  if(target) target.scrollIntoView({ behavior: 'smooth' });
}

function goHome() {
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

function toggleDrawer(){
  document.getElementById('cat-drawer').classList.toggle('open');
  document.getElementById('overlay').classList.toggle('show');
}
function closeDrawer(){
  document.getElementById('cat-drawer').classList.remove('open');
  document.getElementById('overlay').classList.remove('show');
}
</script>"""

full_html = f\"\"\"<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kandy Sex Shop | Catálogo 2026</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;900&display=swap" rel="stylesheet">
    {style}
</head>
<body>
    {cover}
    {nav}
    <main id="main-content">
        {index_html}
        {all_sections_html}
    </main>
    {footer}
    {script}
</body>
</html>
\"\"\"

with open(index_final_path, 'w', encoding='utf-8') as f:
    f.write(full_html)

print(f"Rebuilt with {len(sections)} sections.")
