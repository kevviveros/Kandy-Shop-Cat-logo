$ErrorActionPreference = "Stop"
$textPath = "c:\Users\kevin\Documents\002 Kandy Shop\all_slides_text.txt"
$rawText = [System.IO.File]::ReadAllText($textPath, [System.Text.Encoding]::UTF8)

$matches = [regex]::Matches($rawText, '(?i)Precio')
Write-Host "Total 'Precio' occurrences: $($matches.Count)"

$slides = $rawText -split "=== (slide\d+) ==="
$parsedCount = 0
for ($i=1; $i -lt $slides.Length; $i+=2) {
    $slideId = $slides[$i]
    $text = $slides[$i+1]
    $parts = $text -split '(?i)Precio\s*:\s*\$?\s*([\d\.,\s]+)(?:pesos?)?\s*'
    $num = [math]::Floor($parts.Length / 2)
    $parsedCount += $num
    
    $rawCount = ([regex]::Matches($text, '(?i)Precio')).Count
    if ($num -ne $rawCount) {
        Write-Host "Discrepancy at ${slideId}: Parsed $num, Raw $rawCount"
        # Print the text to see why
        Write-Host "Text: $text"
        $parts | ForEach-Object { Write-Host "Part: [$_]" }
    }
}
Write-Host "Total parsed: $parsedCount"
