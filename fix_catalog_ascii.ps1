$ErrorActionPreference = "Stop"

$tempHtmlPath = "c:\Users\kevin\Documents\002 Kandy Shop\catalogo\index_temp.html"
$indexPath = "c:\Users\kevin\Documents\002 Kandy Shop\catalogo\index.html"

# Extract mapping from index.html itself dynamically to avoid encoding issues here
$oldIndex = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

$startIndex = $oldIndex.IndexOf('<main id="main-content">')
$endIndex = $oldIndex.IndexOf('<footer id="footer">')

if ($startIndex -eq -1 -or $endIndex -eq -1) {
    Write-Host "Error: Could not find markers in index.html"
    exit 1
}

$prefix = $oldIndex.Substring(0, $startIndex + '<main id="main-content">'.Length)
$suffix = $oldIndex.Substring($endIndex)

$catIndexStart = $oldIndex.IndexOf('<section id="cat-index"')
$catIndexEnd = $oldIndex.IndexOf('</section>', $catIndexStart) + '</section>'.Length
$catIndexHtml = $oldIndex.Substring($catIndexStart, $catIndexEnd - $catIndexStart)

$prefix = $prefix + "`r`n`r`n    " + $catIndexHtml + "`r`n"

# Create mapping dynamically from prefix/catIndexHtml
# <section class="cat-section" id="anillos">
# <h2 class="cat-title">💍 Anillos</h2>
$catMapping = @{}
$catRegex = [regex]::new('<section class="cat-section"\s+id="(.*?)">\s*<h2 class="cat-title">(.*?)</h2>')
foreach ($m in $catRegex.Matches($oldIndex)) {
    $id = $m.Groups[1].Value
    $title = $m.Groups[2].Value
    $catMapping[$id] = @{ id=$id; title=$title }
}

# Add default aliases
if ($catMapping.ContainsKey("bolas")) { $catMapping["bolasvaginales"] = $catMapping["bolas"] }
if ($catMapping.ContainsKey("despedida")) { $catMapping["despedidadesoltera"] = $catMapping["despedida"] }
if ($catMapping.ContainsKey("lenceria")) { $catMapping["lencera"] = $catMapping["lenceria"] }
if ($catMapping.ContainsKey("estimulantes")) { $catMapping["vigorizantes"] = $catMapping["estimulantes"] }

$tempHtml = [System.IO.File]::ReadAllText($tempHtmlPath, [System.Text.Encoding]::UTF8)

# Instead of typing literal corrupted bytes, use explicit byte hex encoding replacements
# "ï¿½" -> [char]0x00EF + [char]0x00BF + [char]0x00BD -> we can just replace ''
# Use Regex with ASCII only.
$tempHtml = $tempHtml -replace "ï¿½", ""
$tempHtml = $tempHtml -replace "Ã³", "o"
$tempHtml = $tempHtml -replace "Ã©", "e"
$tempHtml = $tempHtml -replace "Ã­", "i"
$tempHtml = $tempHtml -replace "Ã¡", "a"
$tempHtml = $tempHtml -replace "Ãº", "u"
$tempHtml = $tempHtml -replace "Ã±", "n"
$tempHtml = $tempHtml -replace "Â", ""

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

    # Clean double quotes / single quotes
    $productsInner = $productsInner -replace "class='product-card'", 'class="product-card"'
    $productsInner = $productsInner -replace "data-name='(.*?)'", 'data-name="$1"'
    $productsInner = $productsInner -replace "class='product-img'", 'class="product-img"'
    $productsInner = $productsInner -replace "src='(.*?)'", 'src="$1"'
    $productsInner = $productsInner -replace "alt='(.*?)'", 'alt="$1"'
    $productsInner = $productsInner -replace "class='product-info'", 'class="product-info"'
    $productsInner = $productsInner -replace "class='product-name'", 'class="product-name"'
    $productsInner = $productsInner -replace "class='sku'", 'class="sku"'
    $productsInner = $productsInner -replace "class='product-price'", 'class="product-price"'
    
    # Capitalize the product names
    $productsInner = [regex]::Replace($productsInner, '(?<=<div class="product-name">)(.*?)(?=</div>)', { param($m) (Get-Culture).TextInfo.ToTitleCase($m.Value.ToLower()) })

    # Capitalize ALT
    $productsInner = [regex]::Replace($productsInner, '(?<=alt=")(.*?)(?=")', { param($m) (Get-Culture).TextInfo.ToTitleCase($m.Value.ToLower()) })

    # Fix prices
    $productsInner = $productsInner -replace '\$\s+([\d.,]+)', '$$$1'

    $sectionsHtml += "    <section class=`"cat-section`" id=`"$mappedId`">`n"
    $sectionsHtml += "      <h2 class=`"cat-title`">$mappedTitle</h2>`n"
    $sectionsHtml += $productsInner
    $sectionsHtml += "</section>`n`n"
}

$newHtml = $prefix + $sectionsHtml + "  </main>`n" + $suffix
[System.IO.File]::WriteAllText($indexPath, $newHtml, [System.Text.Encoding]::UTF8)

Write-Host "Rebuilt successfully!"
