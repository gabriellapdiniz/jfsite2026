Add-Type -AssemblyName System.Drawing

$base = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"
$src = New-Object System.Drawing.Bitmap((Join-Path $base "jf-fleet-boeing.jpg"))
$w = $src.Width; $h = $src.Height
Write-Output "source: $w x $h"

# Crop focused on just the nose cone, portrait 3:4 (avoid airline livery text further back)
$cropX = 0
$cropW = 430
$cropH = [int]($cropW / 0.75)
$cropY = 60

$cropRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
$cropped = New-Object System.Drawing.Bitmap($cropW, $cropH)
$g1 = [System.Drawing.Graphics]::FromImage($cropped)
$g1.DrawImage($src, (New-Object System.Drawing.Rectangle(0,0,$cropW,$cropH)), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
$g1.Dispose()
$src.Dispose()

$outW = 900
$outH = [int]([double]$outW * $cropH / $cropW)
$final = New-Object System.Drawing.Bitmap($outW, $outH)
$g2 = [System.Drawing.Graphics]::FromImage($final)
$g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g2.DrawImage($cropped, 0, 0, $outW, $outH)
$g2.Dispose()
$cropped.Dispose()

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]85)
$outPath = Join-Path $base "jf-fleet-boeing-crop.jpg"
$final.Save($outPath, $encoder, $encParams)
$final.Dispose()
Write-Output "Saved: jf-fleet-boeing-crop.jpg ($outW x $outH)"

