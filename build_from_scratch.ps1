$ErrorActionPreference = "Stop"

$basePath = "c:\Users\kevin\Documents\002 Kandy Shop"
$textPath = "$basePath\all_slides_text.txt"
$mapPath = "$basePath\slide_images_map.txt"
$indexPath = "$basePath\catalogo\index.html"

# Load Image Maps
$imageMap = @{}
$mapLines = [System.IO.File]::ReadAllLines($mapPath, [System.Text.Encoding]::UTF8)
foreach ($line in $mapLines) {
    if ($line -match "^(slide\d+)\s*:\s*(.*)$") {
        $slide = $Matches[1].ToLower().Trim()
        $imgsRaw = $Matches[2]
        $imgs = [regex]::Matches($imgsRaw, "image\d+\.[a-zA-Z]+") | ForEach-Object { $_.Value }
        $imgs = $imgs | Where-Object { $_ -notmatch "^image1\." }
        $imageMap[$slide] = @($imgs)
    }
}

# Read Text and fix Encoding mangles
$bytes = [System.IO.File]::ReadAllBytes($textPath)
$rawText = [System.Text.Encoding]::UTF8.GetString($bytes)

# Removing everything from KANDY until the years 2025/2026 (allowing for spaces in years)
$rawText = $rawText -replace "(?i)KANDY.*?202\s*[56]", ""
$rawText = $rawText -replace "(?i)KANDY\s+SEX\s+SHOP", "" 
$rawText = $rawText -replace "(?i)CAT.*?LOGO", ""

# Explicitly remove specific mangled residues seen in the hex/utf8 output
$rawText = $rawText -replace "Â–", ""
$rawText = $rawText -replace "Â", ""
$rawText = $rawText -replace "â", ""
$rawText = $rawText -replace "–", ""

# Clean HOJA lines
$rawText = $rawText -replace "(?i)HOJA\s*\d+\s*", ""

$rawText = $rawText -replace "LǸ", "Lé" 
$rawText = $rawText -replace "elã©ctrico", "eléctrico"
$rawText = $rawText -replace "Elã©Ctrico", "Eléctrico"
$rawText = $rawText -replace "corazã³n", "corazón"
$rawText = $rawText -replace "Corazã³n", "Corazón"
$rawText = $rawText -replace "\?\?", "''" # Convert ?? to inches mark ''
$rawText = $rawText -replace "([0-9])\?\?", "$1''"

# Common fragmented words cleanup
$rawText = $rawText -replace "(?i)\bAnillo\s+s\b", "Anillos"
$rawText = $rawText -replace "(?i)\bArn\s*..?\s*ses\b", "Arneses"
$rawText = $rawText -replace "(?i)\bSuspensorio\s+s\b", "Suspensores"
$rawText = $rawText -replace "(?i)\bMasturbador\s+es\b", "Masturbadores"
$rawText = $rawText -replace "(?i)\bLencer\s*[i]\s*a\b", "Lencería"
$rawText = $rawText -replace "(?i)\bComestible\s+s\b", "Comestibles"

# Category Definitions
$catKeywords = @(
    "ANILLOS", "ARNESES", "BONDAGE", "VIGORIZANTES", "DESPEDIDA DE SOLTERA Y JUEGOS", 
    "DILDOS", "FUNDAS Y EXTENSORES", "MASTURBADORES", "JUGUETES ANALES", "LENCERIA", 
    "ACEITES ESENCIALES", "VIBRADORES BALA", "VIBRADORES", "MASAJEADORES"
)

$catMapping = @{
    "ANILLOS" = @{id="anillos"; title="💍 Anillos Vibradores"}
    "ARNESES" = @{id="arneses"; title="🔗 Arneses & Suspensores"}
    "BONDAGE" = @{id="bondage"; title="🔒 Bondage & Fetish"}
    "VIGORIZANTES" = @{id="vigorizantes"; title="⚡ Estimulantes & Vigorizantes"}
    "DESPEDIDA DE SOLTERA Y JUEGOS" = @{id="despedida"; title="🎉 Despedida de Soltera & Juegos"}
    "DILDOS" = @{id="dildos"; title="🔥 Dildos"}
    "FUNDAS Y EXTENSORES" = @{id="fundas"; title="🍆 Fundas & Extensores"}
    "MASTURBADORES" = @{id="masturbadores"; title="🌀 Masturbadores M For Men"}
    "JUGUETES ANALES" = @{id="pluganal"; title="🔮 Juguetes Anales"}
    "LENCERIA" = @{id="lenceria"; title="🖤 Lencería Fina"}
    "ACEITES ESENCIALES" = @{id="aceites"; title="🧪 Aceites Esenciales & Aromas"}
    "VIBRADORES BALA" = @{id="vibradoresbala"; title="✨ Vibradores Bala"}
    "VIBRADORES" = @{id="vibradores"; title="💜 Vibradores Femeninos"}
    "MASAJEADORES" = @{id="masajeadores"; title="💆 Masajeadores Ergonómicos"}
}

$colorKeywords = @("Black", "Blue", "Pink", "White", "Clear", "Mocha", "Vanilla", "Brown", "Red", "Purple", "Green", "Silver", "Gold", "Violet", "Orange", "Yellow", "Lavender")

$slides = $rawText -split "=== (slide\d+) ==="
$productsList = @()
$currentCat = "VIBRADORES"
$totalProducts = 0

for ($i=1; $i -lt $slides.Length; $i+=2) {
    $slideId = $slides[$i].ToLower().Trim()
    $text = $slides[$i+1].Trim()

    foreach ($kw in $catKeywords) {
        if ($text -match "\b$kw\b") { $currentCat = $kw }
    }

    # Split by Precio: 
    $parts = $text -split '(?i)Precio\s*:?\s*\$?\s*([\d\.,\s]+)(?:pesos?)?\s*'
    $numProductsInSlide = [math]::Floor($parts.Length / 2)
    $slideImages = $imageMap[$slideId]
    
    for ($p=0; $p -lt $numProductsInSlide; $p++) {
        $rawFragment = $parts[$p*2].Trim()
        $priceVal = $parts[$p*2 + 1] -replace "\s+", ""
        
        # Clean current fragment of any noise (double check)
        $cleanString = $rawFragment -replace "\?", " "
        $cleanString = $cleanString -replace "\s+", " "
        
        # Remove categories repeated in names
        foreach ($kw in $catKeywords) {
             $cleanString = $cleanString -replace "(?i)\b$kw\b", ""
        }
        $cleanString = $cleanString.Trim("- –—? ")

        # Separating SKU and Name
        $sku = ""
        $name = $cleanString
        
        $words = $cleanString.Split(@(' '), [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($words.Length -gt 1) {
            # Find where the SKU parts start (from the end)
            $splitPos = $words.Length
            for ($k = $words.Length - 1; $k -ge 0; $k--) {
                 $word = $words[$k]
                 $isColor = $false
                 foreach ($color in $colorKeywords) { if ($word -ieq $color) { $isColor = $true; break } }
                 
                 # Logic for SKU part: not a color, and matches SKU patterns (digits, all upper, or hyphen/dot)
                 # Using -ceq for case-sensitive comparison to avoid matching words like "Pack"
                 $isSkuPart = (-not $isColor -and ($word -match "[0-9]" -or $word -ceq $word.ToUpper() -or $word -match "^[\-\.]+$") -and $word.Length -ge 1 -and $word -notmatch "Pack|Set|The|Case|Mini|XL|XXL")
                 
                 if ($isSkuPart) {
                     $splitPos = $k
                 } else {
                     # Once we hit a non-SKU part, we stop searching backwards
                     break
                 }
            }
            
            if ($splitPos -lt $words.Length) {
                # Look-ahead: avoid splitting if the "sku" we found is just too long or looks like words
                if (($words.Length - $splitPos) -gt 4) { $splitPos = $words.Length } # Safety
                
                if ($splitPos -lt $words.Length) {
                    $name = ($words[0..($splitPos-1)] -join " ").Trim()
                    $sku = ($words[$splitPos..($words.Length-1)] -join " ").Replace(" ", "") # Join and strip internal spaces
                }
            }
        }

        # Fix capitalization
        if ($name -eq "") { $name = "Producto Kandy" }
        $name = (Get-Culture).TextInfo.ToTitleCase($name.ToLower())
        
        # Patches
        $name = $name -replace "C- Ring", "C-Ring"
        $name = $name -replace " – ", " – "
        $name = $name.Trim("- –— ")

        $img = "image_placeholder.jpg"
        if ($slideImages -and $p -lt $slideImages.Count) { $img = $slideImages[$p] }

        # Final Price formatting with commas
        $priceVal = $priceVal -replace "[^0-9\.]", ""
        if ($priceVal -match "^\d+(\.\d+)?$") {
            $priceVal = [double]$priceVal
            $formattedPrice = "$($priceVal.ToString('N2'))"
        } else {
            $formattedPrice = $parts[$p*2 + 1].Trim()
        }

        # SPECIAL FIX for MASAJEADORES SKU Swap (Ref Google Doc)
        if ($sku -eq "AH205" -and $name -match "10X Mini Silicone Wand") { $sku = "PD3027-12-19" }
        elseif ($sku -eq "PD3027-12-19" -and $name -match "Wanachi Mini Massager") { $sku = "AH205" }

        $productsList += @{
            Name = $name
            Sku = $sku
            Price = "`$$formattedPrice"
            Category = $currentCat
            Image = $img
        }
        $totalProducts++
    }
}

Write-Host "Total products parsed: $totalProducts"

# Rebuilding index.html
$oldIndex = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
$startIndex = $oldIndex.IndexOf("<main id=`"main-content`">")
$endIndex = $oldIndex.IndexOf("<footer id=`"footer`">")

if ($startIndex -eq -1 -or $endIndex -eq -1) { Write-Host "Markers not found"; exit 1 }

$prefix = $oldIndex.Substring(0, $startIndex + "<main id=`"main-content`">".Length)
$suffix = $oldIndex.Substring($endIndex)

$catIndexStart = $oldIndex.IndexOf("<section id=`"cat-index`"")
$catIndexEnd = $oldIndex.IndexOf("</section>", $catIndexStart) + "</section>".Length
$catIndexHtml = $oldIndex.Substring($catIndexStart, $catIndexEnd - $catIndexStart)

$sectionsHtml = "`r`n`r`n    " + $catIndexHtml + "`r`n"
$catGroups = @{}
foreach ($p in $productsList) { 
    if (-not $catGroups.ContainsKey($p.Category)) { $catGroups[$p.Category] = @() }
    $catGroups[$p.Category] += @($p) 
}

foreach ($kw in $catKeywords) {
    if (-not $catGroups.ContainsKey($kw)) { continue }
    $mapped = $catMapping[$kw]
    $sectionsHtml += "    <section class=`"cat-section`" id=`"$($mapped.id)`">`n"
    $sectionsHtml += "      <h2 class=`"cat-title`">$($mapped.title)</h2>`n"
    $sectionsHtml += "      <div class=`"product-grid`">`n"
    foreach ($p in $catGroups[$kw]) {
        # Final name cleanup for the HTML injection
        $finalName = $p.Name -replace "Â|â|–|—", ""
        $finalName = $finalName.Trim()
        
        $sectionsHtml += "        <div class=`"product-card`" data-name=`"$($finalName.ToLower())`">`n"
        $sectionsHtml += "          <img class=`"product-img`" src=`"images/$($p.Image)`" alt=`"$finalName`">`n"
        $sectionsHtml += "          <div class=`"product-info`">`n"
        $sectionsHtml += "            <div class=`"sku`">$($p.Sku)</div>`n"
        $sectionsHtml += "            <div class=`"product-name`">$finalName</div>`n"
        $sectionsHtml += "            <div class=`"product-price`">$($p.Price)</div>`n"
        $sectionsHtml += "          </div>`n"
        $sectionsHtml += "        </div>`n"
    }
    $sectionsHtml += "      </div>`n"
    $sectionsHtml += "    </section>`n`n"
}

$newHtml = $prefix + $sectionsHtml + "  </main>`n" + $suffix
[System.IO.File]::WriteAllText($indexPath, $newHtml, [System.Text.Encoding]::UTF8)
Write-Host "Catalog Cleaned and Rebuilt Successfully!"
