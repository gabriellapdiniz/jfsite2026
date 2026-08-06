Add-Type -AssemblyName System.Drawing

$base = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"

function Crop-Resize {
  param(
    [string]$srcFile,
    [string]$outFile,
    [int]$cropX, [int]$cropY, [int]$cropW, [int]$cropH,
    [int]$outW
  )
  $srcPath = Join-Path $base $srcFile
  $outPath = Join-Path $base $outFile
  $src = [System.Drawing.Image]::FromFile($srcPath)

  $cropRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
  $cropped = New-Object System.Drawing.Bitmap($cropW, $cropH)
  $g1 = [System.Drawing.Graphics]::FromImage($cropped)
  $g1.DrawImage($src, (New-Object System.Drawing.Rectangle(0,0,$cropW,$cropH)), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
  $g1.Dispose()
  $src.Dispose()

  $outH = [int]([double]$outW * $cropH / $cropW)
  $final = New-Object System.Drawing.Bitmap($outW, $outH)
  $g2 = [System.Drawing.Graphics]::FromImage($final)
  $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g2.DrawImage($cropped, 0, 0, $outW, $outH)
  $g2.Dispose()
  $cropped.Dispose()

  $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
  $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]85)
  $final.Save($outPath, $encoder, $encParams)
  $final.Dispose()
  Write-Output "Saved: $outFile ($outW x $outH)"
}

Crop-Resize -srcFile "rotated_20260722_085326.jpg" -outFile "jf-real-pintura-prep.jpg" -cropX 0 -cropY 1400 -cropW 2252 -cropH 1200 -outW 1800
Crop-Resize -srcFile "20260514_084750.jpg" -outFile "jf-real-hangar-inspecao.jpg" -cropX 200 -cropY 0 -cropW 1689 -cropH 2252 -outW 900
Crop-Resize -srcFile "rotated_20260731_145104.jpg" -outFile "jf-real-componente-painel.jpg" -cropX 0 -cropY 500 -cropW 2252 -cropH 3003 -outW 900
Crop-Resize -srcFile "20260731_145349.jpg" -outFile "jf-real-atr-pintado.jpg" -cropX 250 -cropY 0 -cropW 3003 -cropH 2252 -outW 900

