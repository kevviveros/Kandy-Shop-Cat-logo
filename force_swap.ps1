$filePath = "c:\Users\kevin\Documents\002 Kandy Shop\catalogo\index.html"
$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

$oldFragment = @"
        <div class="product-card" data-name="wanachi mini massager . largo 20 cm ancho 3.3 cm">
          <img class="product-img" src="images/image452.jpg" alt="Wanachi Mini Massager . Largo 20 Cm Ancho 3.3 Cm">
          <div class="product-info">
            <div class="sku">PD3027-1219</div>
            <div class="product-name">Wanachi Mini Massager . Largo 20 Cm Ancho 3.3 Cm</div>
            <div class="product-price">$735.00</div>
          </div>
        </div>
        <div class="product-card" data-name="masajeador 10x mini silicone wand">
          <img class="product-img" src="images/image451.jpeg" alt="Masajeador 10X Mini Silicone Wand">
          <div class="product-info">
            <div class="sku">AH205</div>
            <div class="product-name">Masajeador 10X Mini Silicone Wand</div>
            <div class="product-price">$720.00</div>
          </div>
        </div>
"@

$newFragment = @"
        <div class="product-card" data-name="masajeador 10x mini silicone wand">
          <img class="product-img" src="images/image451.jpeg" alt="Masajeador 10X Mini Silicone Wand">
          <div class="product-info">
            <div class="sku">AH205</div>
            <div class="product-name">Masajeador 10X Mini Silicone Wand</div>
            <div class="product-price">$720.00</div>
          </div>
        </div>
        <div class="product-card" data-name="wanachi mini massager . largo 20 cm ancho 3.3 cm">
          <img class="product-img" src="images/image452.jpg" alt="Wanachi Mini Massager . Largo 20 Cm Ancho 3.3 Cm">
          <div class="product-info">
            <div class="sku">PD3027-1219</div>
            <div class="product-name">Wanachi Mini Massager . Largo 20 Cm Ancho 3.3 Cm</div>
            <div class="product-price">$735.00</div>
          </div>
        </div>
"@

if ($content.Contains($oldFragment)) {
    $content = $content.Replace($oldFragment, $newFragment)
    [System.IO.File]::WriteAllText($filePath, $content, [System.Text.Encoding]::UTF8)
    Write-Host "Success: Content replaced."
} else {
    Write-Host "Error: Fragment not found."
}
