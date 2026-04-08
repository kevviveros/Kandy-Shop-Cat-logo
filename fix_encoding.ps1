$htmlFilePath = "c:\Users\kevin\Documents\002 Kandy Shop\catalogo\index.html"
$html = [System.IO.File]::ReadAllText($htmlFilePath, [System.Text.Encoding]::UTF8)

# We will just replace exactly the bad Unicode mapped characters that PowerShell saw
$html = $html.Replace("â€“", "-")
$html = $html.Replace("Â€“", "-")
$html = $html.Replace("Ã³", "ó")
$html = $html.Replace("Ã©", "é")
$html = $html.Replace("Ã­", "í")
$html = $html.Replace("Ã¡", "á")
$html = $html.Replace("Ãº", "ú")
$html = $html.Replace("Ã±", "ñ")
$html = $html.Replace("Ã ", "Ó")
$html = $html.Replace("Ãš", "Ú")
$html = $html.Replace("Ã‘", "Ñ")
$html = $html.Replace("Â", "")
$html = $html.Replace("Ã", "í")

[System.IO.File]::WriteAllText($htmlFilePath, $html, [System.Text.Encoding]::UTF8)
Write-Host "Replaced!"
