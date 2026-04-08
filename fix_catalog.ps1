$ErrorActionPreference = "Stop"

$tempHtmlPath = "c:\Users\kevin\Documents\002 Kandy Shop\catalogo\index_temp.html"
$indexPath = "c:\Users\kevin\Documents\002 Kandy Shop\catalogo\index.html"

# Mapeo de Categorías de index_temp a IDs y Títulos Hermosos de index.html
$catMapping = @{
    "anillos" = @{ id="anillos"; title="💍 Anillos" }
    "arneses" = @{ id="arneses"; title="🔗 Arneses" }
    "bolasvaginales" = @{ id="bolas"; title="⚪ Bolas Vaginales" }
    "bombas" = @{ id="bombas"; title="💨 Bombas" }
    "bondage" = @{ id="bondage"; title="🔒 Bondage & Fetish" }
    "comestibles" = @{ id="comestibles"; title="🍬 Comestibles" }
    "despedidadesoltera" = @{ id="despedida"; title="🎉 Despedida de Soltera" }
    "dildos" = @{ id="dildos"; title="🥒 Dildos" }
    "disfraces" = @{ id="disfraces"; title="🎭 Disfraces" }
    "enemas" = @{ id="enemas"; title="💧 Enemas" }
    "feromonas" = @{ id="feromonas"; title="🧪 Feromonas" }
    "lencera" = @{ id="lenceria"; title="🖤 Lencería" }
    "lubricantes" = @{ id="lubricantes"; title="💦 Lubricantes & Geles" }
    "masturbadores" = @{ id="masturbadores"; title="🌀 Masturbadores" }
    "pluganal" = @{ id="pluganal"; title="🔮 Plug Anal" }
    "vibradores" = @{ id="vibradores"; title="💜 Vibradores" }
    "vigorizantes" = @{ id="estimulantes"; title="⚡ Estimulantes & Retardantes" } # Mapeo de Vigorizantes -> Estimulantes si lo decíamos, o si tiene su propio slot. 
# En el archivo HTML la lista tiene: Estimulantes y Retardantes. No vi Vigorizantes.
}

# 1. Read the old index.html to extract the prefix (Header + Navigation) and suffix (Footer)
$oldIndex = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

# Find the start of the catalog and the end
$startIndex = $oldIndex.IndexOf('<main class="cat-grid">')
$endIndex = $oldIndex.IndexOf('<footer id="footer">')

if ($startIndex -eq -1 -or $endIndex -eq -1) {
    Write-Host "Error: Could not find markers in index.html"
    exit 1
}

$prefix = $oldIndex.Substring(0, $startIndex + '<main class="cat-grid">'.Length)
$suffix = $oldIndex.Substring($endIndex)

# We will also preserve the <section id="cat-index"> from the old index as it was beautiful!
$catIndexStart = $oldIndex.IndexOf('<section id="cat-index"')
$catIndexEnd = $oldIndex.IndexOf('</section>', $catIndexStart) + '</section>'.Length
$catIndexHtml = $oldIndex.Substring($catIndexStart, $catIndexEnd - $catIndexStart)

# 2. Add catIndexHtml right after main class="cat-grid"
$prefix = $prefix + "`r`n`r`n    " + $catIndexHtml + "`r`n"

# 3. Read index_temp.html
$tempHtml = [System.IO.File]::ReadAllText($tempHtmlPath, [System.Text.Encoding]::UTF8)

# Encoding corrections
$tempHtml = $tempHtml -replace "ï¿½", ""
$tempHtml = $tempHtml -replace "Ã³", "ó"
$tempHtml = $tempHtml -replace "Ã©", "é"
$tempHtml = $tempHtml -replace "Ã­", "í"
$tempHtml = $tempHtml -replace "Ã¡", "á"
$tempHtml = $tempHtml -replace "Ãº", "ú"
$tempHtml = $tempHtml -replace "Ã±", "ñ"
$tempHtml = $tempHtml -replace "Ã ", "Ó"
$tempHtml = $tempHtml -replace "Ãš", "Ú"
$tempHtml = $tempHtml -replace "Ã‘", "Ñ"
$tempHtml = $tempHtml -replace "â€“", "-"
$tempHtml = $tempHtml -replace "â€™", "'"
$tempHtml = $tempHtml -replace "Â", ""
$tempHtml = $tempHtml -replace "Ã“", "Ó"
$tempHtml = $tempHtml -replace "Ãˆ", "É"
$tempHtml = $tempHtml -replace "Ã", "í" # Sometimes remaining
$tempHtml = $tempHtml -replace "Lencera", "Lencería"

# Extract sections
$sectionsHtml = ""
$matchParams = [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
$sectionRegex = [regex]::new("<section class='cat-section' id='(.*?)'>\s*<h2 class='cat-title'>.*?</h2>(.*?)<\/section>", $matchParams)
$matches = $sectionRegex.Matches($tempHtml)

foreach ($match in $matches) {
    $tempId = $match.Groups[1].Value
    $productsInner = $match.Groups[2].Value
    
    $mappedId = $tempId
    $mappedTitle = $tempId

    if ($catMapping.ContainsKey($tempId)) {
        $mappedId = $catMapping[$tempId].id
        $mappedTitle = $catMapping[$tempId].title
    }

    # Formatting product cards dynamically
    # Replace single quotes with double quotes
    $productsInner = $productsInner -replace "class='product-card'", 'class="product-card"'
    $productsInner = $productsInner -replace "data-name='(.*?)'", 'data-name="$1"'
    $productsInner = $productsInner -replace "class='product-img'", 'class="product-img"'
    $productsInner = $productsInner -replace "src='(.*?)'", 'src="$1"'
    $productsInner = $productsInner -replace "alt='(.*?)'", 'alt="$1"'
    $productsInner = $productsInner -replace "class='product-info'", 'class="product-info"'
    $productsInner = $productsInner -replace "class='product-name'", 'class="product-name"'
    $productsInner = $productsInner -replace "class='sku'", 'class="sku"'
    $productsInner = $productsInner -replace "class='product-price'", 'class="product-price"'
    
    # Capitalize the product names carefully using regex to title case
    $productsInner = [regex]::Replace($productsInner, '(?<=<div class="product-name">)(.*?)(?=</div>)', { param($m) (Get-Culture).TextInfo.ToTitleCase($m.Value.ToLower()) })

    # Also Capitalize ALT text
    $productsInner = [regex]::Replace($productsInner, '(?<=alt=")(.*?)(?=")', { param($m) (Get-Culture).TextInfo.ToTitleCase($m.Value.ToLower()) })

    # Fix spaces in prices `$ 340.00` -> `$340.00`
    $productsInner = $productsInner -replace '\$\s+([\d.,]+)', '$$$1'

    # Add section
    $sectionsHtml += "    <section class=`"cat-section`" id=`"$mappedId`">`n"
    $sectionsHtml += "      <h2 class=`"cat-title`">$mappedTitle</h2>`n"
    $sectionsHtml += $productsInner
    $sectionsHtml += "</section>`n`n"
}

# The new HTML
$newHtml = $prefix + $sectionsHtml + "  </main>`n" + $suffix

[System.IO.File]::WriteAllText($indexPath, $newHtml, [System.Text.Encoding]::UTF8)

Write-Host "Rebuilt beautifully."

