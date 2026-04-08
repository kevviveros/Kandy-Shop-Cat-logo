$path = "c:\Users\kevin\Documents\002 Kandy Shop\all_slides_text.txt"
$bytes = [System.IO.File]::ReadAllBytes($path)
$hex = [System.BitConverter]::ToString($bytes, 0, [math]::Min(2000, $bytes.Length))
Write-Host "HEX DUMP (First 2000 bytes):`n$hex"

$utf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
Write-Host "`nUTF8 REPRESENTATION:`n$($utf8.Substring(0, [math]::Min(1000, $utf8.Length)))"

$win1252 = [System.Text.Encoding]::GetEncoding(1252).GetString($bytes)
Write-Host "`nWINDOWS-1252 REPRESENTATION:`n$($win1252.Substring(0, [math]::Min(1000, $win1252.Length)))"
