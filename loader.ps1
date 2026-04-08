$bytes = [System.IO.File]::ReadAllBytes('c:\Users\kevin\Documents\002 Kandy Shop\catalogo\build_from_scratch.ps1')
$bom = [byte[]](0xEF, 0xBB, 0xBF)

# Make sure we don't double BOM
if ($bytes.Length -gt 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    # already has bom
} else {
    [System.IO.File]::WriteAllBytes('c:\Users\kevin\Documents\002 Kandy Shop\catalogo\build_from_scratch.ps1', $bom + $bytes)
}

& 'c:\Users\kevin\Documents\002 Kandy Shop\catalogo\build_from_scratch.ps1'
