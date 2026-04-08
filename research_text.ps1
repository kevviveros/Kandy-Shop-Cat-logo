$textPath = "c:\Users\kevin\Documents\002 Kandy Shop\all_slides_text.txt"
$bytes = [System.IO.File]::ReadAllBytes($textPath)
$hex = [System.BitConverter]::ToString($bytes, 0, [math]::Min(1000, $bytes.Length))
Write-Host "Hex: $hex"

$utf8Text = [System.Text.Encoding]::UTF8.GetString($bytes)
Write-Host "`nUTF8 Prefix (1000 chars):"
Write-Host ($utf8Text.Substring(0, [math]::Min(1000, $utf8Text.Length)))

$ansiText = [System.Text.Encoding]::Default.GetString($bytes)
Write-Host "`nANSI/Default Prefix (1000 chars):"
Write-Host ($ansiText.Substring(0, [math]::Min(1000, $ansiText.Length)))
