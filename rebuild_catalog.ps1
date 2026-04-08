$textPath = "c:\Users\kevin\Documents\002 Kandy Shop\all_slides_text.txt"
$mapPath = "c:\Users\kevin\Documents\002 Kandy Shop\slide_images_map.txt"
$outputPath = "c:\Users\kevin\Documents\002 Kandy Shop\catalogo\full_catalog_fragment.html"

# Load Maps
$slideImages = @{}
if (Test-Path $mapPath) {
    $lines = Get-Content $mapPath
    foreach ($line in $lines) {
        if ($line -match "^slide(\d+)\s*:\s*(.*)$") {
            $sId = $matches[1].Trim()
            $imgs = $matches[2] -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ -notlike "*image1.png*" }
            $slideImages[$sId] = @($imgs)
        }
    }
}

$content = [System.IO.File]::ReadAllText($textPath, [System.Text.Encoding]::UTF8)
$slides = $content -split "=== slide"
$catalog = @()
$currentCat = "General"

$markers = "ANILLOS|ARNESES|BOLAS VAGINALES|BOMBAS|BONDAGE|COMESTIBLES|VIGORIZANTES|ROPA COMESTIBLE|DESPEDIDA|DILDOS|ENEMAS|ESTIMULANTES|FEROMONAS|FUNDAS|MASTURBADORES|PLUG ANAL|LENCERIA|DISFRACES|LIMPIADORES|LUBRICANTES|PRESERVATIVOS|VIBRADORES|SUCCIONADOR|ANALOGO|DIVERSOS"

foreach ($s in $slides) {
    if ($s -match "(?s)^\s*(\d+)\s*===\s*(.*)") {
        $sId = $matches[1]
        $body = $matches[2]
        $u = $body.ToUpper()
        if ($u -match "ANILLOS") { $currentCat = "Anillos" }
        elseif ($u -match "ARNESES") { $currentCat = "Arneses" }
        elseif ($u -match "VIBRADORES|SUCCIONADOR") { $currentCat = "Vibradores" }
        elseif ($u -match "DILDOS") { $currentCat = "Dildos" }
        elseif ($u -match "LUBRICANTES") { $currentCat = "Lubricantes" }
        elseif ($u -match "LENCERIA") { $currentCat = "Lencería" }
        elseif ($u -match "COMESTIBLES") { $currentCat = "Comestibles" }

        $body = [regex]::Replace($body, "(?s)KANDY SEX SHOP.*?CATÁLOGO 202\s*[56]", " ")
        $body = [regex]::Replace($body, "HOJA \d+", " ")
        $body = $body -replace "[\r\n]+", " "
        
        $parts = $body -split "Precio\s*:\s*\$\s*"
        $imgs = if ($slideImages.ContainsKey($sId)) { $slideImages[$sId] } else { @() }
        $imgIdx = 0

        for ($i=1; $i -lt $parts.Length; $i++) {
            $chunk = $parts[$i]
            if ($chunk -match "^\s*([\d\s,.]+)") {
                $pVal = $matches[1] -replace "\s+", ""
                $nameArea = $parts[$i-1].Trim()
                $skus = [regex]::Matches($nameArea, "\b[A-Z0-9-]{4,}\b")
                if ($skus.Count -gt 0) {
                    $lastSku = $skus[$skus.Count-1].Value
                    $name = $nameArea.Substring(0, $skus[$skus.Count-1].Index).Trim()
                    $name = $name -replace "(?i)pesos$", ""
                    $name = $name -replace "[\d\s,.]+pesos", ""
                    $name = $name -replace $markers, ""
                    $name = [regex]::Replace($name, "\b(\w+)\s+\1\b", '$1', "IgnoreCase")
                    $name = $name.Trim(" :.,-")
                    if ($name.Length -gt 2) {
                        $img = "placeholder.jpg"
                        if ($imgIdx -lt $imgs.Count) { $img = $imgs[$imgIdx]; $imgIdx++ }
                        
                        # Strip non-ASCII junk from name area
                        $name = $name -replace "[^\x20-\x7E\x80-\xFF]", " "
                        $name = $name -replace "\s+", " "
                        
                        $catalog += [PSCustomObject]@{ Cat=$currentCat; Name=$name; SKU=$lastSku; Price=$pVal; Img="images/$img" }
                    }
                }
            }
        }
    }
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("<section id='cat-index'>`n  <div class='index-grid'>")
$cats = $catalog | Group-Object Cat | Sort-Object Name
foreach ($c in $cats) {
    if ($c.Name -ne "General") {
        $slug = $c.Name.ToLower() -replace "[^a-z]", ""
        [void]$sb.AppendLine("    <a href='#$slug' class='index-card'><div class='index-label'>$($c.Name)</div></a>")
    }
}
[void]$sb.AppendLine("  </div>`n</section>")

foreach ($c in $cats) {
    if ($c.Name -ne "General") {
        $slug = $c.Name.ToLower() -replace "[^a-z]", ""
        [void]$sb.AppendLine("<section class='cat-section' id='$slug'>`n  <h2 class='cat-title'>$($c.Name)</h2>`n  <div class='product-grid'>")
        foreach ($p in $c.Group) {
            [void]$sb.AppendLine("    <div class='product-card' data-name='$($p.Name.ToLower())'>")
            [void]$sb.AppendLine("      <img class='product-img' src='$($p.Img)' alt='$($p.Name)'>")
            [void]$sb.AppendLine("      <div class='product-info'>")
            [void]$sb.AppendLine("        <div class='product-name'>$($p.Name)</div>")
            [void]$sb.AppendLine("        <div class='sku'>$($p.SKU)</div>")
            [void]$sb.AppendLine("        <div class='product-price'>$ $($p.Price)</div>")
            [void]$sb.AppendLine("      </div>`n    </div>")
        }
        [void]$sb.AppendLine("  </div>`n</section>")
    }
}

$res = $sb.ToString()
# Final brute-force translation of messy bytes seen in Select-String
$res = $res -replace "\?", "-" -replace "o", [char]0x201C -replace "", [char]0x201D
$res = $res.Replace("Lencera", "Lencería")
$res | Out-File -FilePath $outputPath -Encoding UTF8
Write-Host "Generated $($catalog.Count) products."
