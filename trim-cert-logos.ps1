Add-Type -AssemblyName System.Drawing

$base = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"
$outDir = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\certs"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

function Trim-Image {
  param([string]$srcFile, [string]$outFile, [int]$pad = 20, [switch]$hasAlpha)

  $src = New-Object System.Drawing.Bitmap((Join-Path $base $srcFile))
  $w = $src.Width; $h = $src.Height

  $minX = $w; $minY = $h; $maxX = 0; $maxY = 0
  $found = $false

  for ($y = 0; $y -lt $h; $y += 2) {
    for ($x = 0; $x -lt $w; $x += 2) {
      $p = $src.GetPixel($x, $y)
      $isBg = $false
      if ($hasAlpha) {
        if ($p.A -lt 10) { $isBg = $true }
      } else {
        if ($p.R -gt 245 -and $p.G -gt 245 -and $p.B -gt 245) { $isBg = $true }
      }
      if (-not $isBg) {
        $found = $true
        if ($x -lt $minX) { $minX = $x }
        if ($x -gt $maxX) { $maxX = $x }
        if ($y -lt $minY) { $minY = $y }
        if ($y -gt $maxY) { $maxY = $y }
      }
    }
  }

  if (-not $found) { $minX=0; $minY=0; $maxX=$w; $maxY=$h }

  $minX = [Math]::Max(0, $minX - $pad)
  $minY = [Math]::Max(0, $minY - $pad)
  $maxX = [Math]::Min($w, $maxX + $pad)
  $maxY = [Math]::Min($h, $maxY + $pad)

  $cropW = $maxX - $minX
  $cropH = $maxY - $minY

  $cropRect = New-Object System.Drawing.Rectangle($minX, $minY, $cropW, $cropH)
  $format = if ($hasAlpha) { [System.Drawing.Imaging.PixelFormat]::Format32bppArgb } else { [System.Drawing.Imaging.PixelFormat]::Format24bppRgb }
  $cropped = New-Object System.Drawing.Bitmap($cropW, $cropH, $format)
  $g = [System.Drawing.Graphics]::FromImage($cropped)
  $g.DrawImage($src, (New-Object System.Drawing.Rectangle(0,0,$cropW,$cropH)), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  $src.Dispose()

  $cropped.Save((Join-Path $outDir $outFile), [System.Drawing.Imaging.ImageFormat]::Png)
  $cropped.Dispose()
  Write-Output "Trimmed: $srcFile -> certs/$outFile ($cropW x $cropH)"
}

Trim-Image -srcFile "Agencia-Nacional-de-Aviacao-Civil-ANAC.jpg" -outFile "jf-cert-anac.png" -pad 20
Trim-Image -srcFile "EASA_Logo.png" -outFile "jf-cert-easa.png" -pad 20 -hasAlpha

