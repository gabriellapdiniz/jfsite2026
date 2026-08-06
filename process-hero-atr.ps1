Add-Type -AssemblyName System.Drawing

$dir = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"
$src = Join-Path $dir "2299d470-12fa-4186-9e94-bb05eaaa8658.png"
$out = Join-Path $dir "jf-real-hero-atr.jpg"

$bmp = [System.Drawing.Bitmap]::FromFile($src)
$maxW = 1920
$ratio = [math]::Min(1.0, $maxW / $bmp.Width)
$w = [int]($bmp.Width * $ratio)
$h = [int]($bmp.Height * $ratio)
$resized = New-Object System.Drawing.Bitmap $w, $h
$g = [System.Drawing.Graphics]::FromImage($resized)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, 0, 0, $w, $h)
$g.Dispose()
$bmp.Dispose()

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]85)
$resized.Save($out, $codec, $encParams)
$resized.Dispose()

Write-Host "Saved: $out -> $($w)x$($h)"

