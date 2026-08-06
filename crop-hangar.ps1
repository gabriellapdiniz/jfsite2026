Add-Type -AssemblyName System.Drawing

$dir = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"
$src = Join-Path $dir "jf-hangar.jpg"
$out = Join-Path $dir "jf-hangar-crop.jpg"

$bmp = [System.Drawing.Bitmap]::FromFile($src)
Write-Host "Original size: $($bmp.Width)x$($bmp.Height)"

$cropY = [int]($bmp.Height * 0.52)
$cropH = $bmp.Height - $cropY
$rect = New-Object System.Drawing.Rectangle 0, $cropY, $bmp.Width, $cropH

$cropped = $bmp.Clone($rect, $bmp.PixelFormat)
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]82)
$cropped.Save($out, $codec, $encParams)
Write-Host "Saved crop: $out -> $($cropped.Width)x$($cropped.Height)"

$bmp.Dispose()
$cropped.Dispose()

