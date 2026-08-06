Add-Type -AssemblyName System.Drawing

$base = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"
$src = New-Object System.Drawing.Bitmap((Join-Path $base "03.JPG"))
$w = $src.Width; $h = $src.Height
Write-Output "source: $w x $h"

$outW = 1800
$outH = [int]([double]$outW * $h / $w)

$final = New-Object System.Drawing.Bitmap($outW, $outH)
$g = [System.Drawing.Graphics]::FromImage($final)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Grayscale color matrix
$row0 = [float[]]@(0.299,0.299,0.299,0,0)
$row1 = [float[]]@(0.587,0.587,0.587,0,0)
$row2 = [float[]]@(0.114,0.114,0.114,0,0)
$row3 = [float[]]@(0,0,0,1,0)
$row4 = [float[]]@(0,0,0,0,1)
$matrixArray = New-Object 'float[][]' 5
$matrixArray[0] = $row0
$matrixArray[1] = $row1
$matrixArray[2] = $row2
$matrixArray[3] = $row3
$matrixArray[4] = $row4
$grayMatrix = New-Object System.Drawing.Imaging.ColorMatrix (,$matrixArray)
$attrs = New-Object System.Drawing.Imaging.ImageAttributes
$attrs.SetColorMatrix($grayMatrix)
$destRect = New-Object System.Drawing.Rectangle(0, 0, $outW, $outH)
$g.DrawImage($src, $destRect, 0, 0, $w, $h, [System.Drawing.GraphicsUnit]::Pixel, $attrs)
$g.Dispose()
$src.Dispose()

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]85)
$outPath = Join-Path $base "jf-real-servicos-header.jpg"
$final.Save($outPath, $encoder, $encParams)
$final.Dispose()
Write-Output "Saved: jf-real-servicos-header.jpg ($outW x $outH)"

