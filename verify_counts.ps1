$textPath = "c:\Users\kevin\Documents\002 Kandy Shop\all_slides_text.txt"
$mapPath = "c:\Users\kevin\Documents\002 Kandy Shop\slide_images_map.txt"

# Load Maps
$slideImages = @{}
$mapLines = [System.IO.File]::ReadAllText($mapPath)
foreach ($line in ($mapLines -split "`r?`n")) {
    if ($line -match "^slide(\d+)\s*:\s*(.*)$") {
        $sId = $matches[1]
        $imgs = $matches[2] -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ -notlike "*image1.png*" }
        $slideImages[$sId] = $imgs
    }
}

$content = [System.IO.File]::ReadAllText($textPath, [System.Text.Encoding]::UTF8)
$slides = $content -split "=== slide"

foreach ($s in $slides) {
    if ($s -match "(?s)^\s*(\d+)\s*===\s*(.*)") {
        $sId = $matches[1]
        $body = $matches[2]
        
        # Clean body
        $body = [regex]::Replace($body, "(?s)KANDY SEX SHOP.*?CATÁLOGO 202\s*[56]", "")
        $body = [regex]::Replace($body, "HOJA \d+", "")
        $body = [regex]::Replace($body, "[\r\n]+", " ")
        
        # Find prices
        $prices = [regex]::Matches($body, "Precio\s*:\s*\$\s*([\d\s,.]+)")
        $imgCount = if ($slideImages.ContainsKey($sId)) { $slideImages[$sId].Count } else { 0 }
        
        Write-Host "Slide $sId : $($prices.Count) products found vs $imgCount images."
        if ($prices.Count -ne $imgCount) {
             # Write-Host "  TEXT: $body" -ForegroundColor Yellow
        }
    }
}
