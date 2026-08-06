Add-Type -AssemblyName System.Drawing

$dir = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"

function Resize-Save {
    param([System.Drawing.Bitmap]$Bmp, [string]$OutPath, [int]$MaxWidth = 1600, [int]$Quality = 82)
    $ratio = [math]::Min(1.0, $MaxWidth / $Bmp.Width)
    $w = [int]($Bmp.Width * $ratio)
    $h = [int]($Bmp.Height * $ratio)
    $resized = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($resized)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($Bmp, 0, 0, $w, $h)
    $g.Dispose()
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
    $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)
    $resized.Save($OutPath, $codec, $encParams)
    Write-Host "$OutPath -> $($w)x$($h)"
    $resized.Dispose()
}

function Adjust-Brightness-Contrast {
    param([System.Drawing.Bitmap]$Bmp, [float]$Brightness = 1.15, [float]$Contrast = 1.12)
    $b = $Brightness
    $c = $Contrast
    $t = (1.0 - $c) / 2.0
    $cm = New-Object System.Drawing.Imaging.ColorMatrix
    $cm.Matrix00 = $c; $cm.Matrix11 = $c; $cm.Matrix22 = $c
    $cm.Matrix33 = 1.0
    $cm.Matrix40 = $t + ($b - 1.0); $cm.Matrix41 = $t + ($b - 1.0); $cm.Matrix42 = $t + ($b - 1.0); $cm.Matrix44 = 1.0
    $ia = New-Object System.Drawing.Imaging.ImageAttributes
    $ia.SetColorMatrix($cm)
    $out = New-Object System.Drawing.Bitmap $Bmp.Width, $Bmp.Height
    $g = [System.Drawing.Graphics]::FromImage($out)
    $rect = New-Object System.Drawing.Rectangle 0, 0, $Bmp.Width, $Bmp.Height
    $g.DrawImage($Bmp, $rect, 0, 0, $Bmp.Width, $Bmp.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $g.Dispose()
    return $out
}

# 1) Manutenção — engine + technicians (already correct orientation)
$b1 = [System.Drawing.Bitmap]::FromFile((Join-Path $dir "jf (1).png"))
Resize-Save -Bmp $b1 -OutPath (Join-Path $dir "jf-real-manutencao.jpg") -MaxWidth 1600 -Quality 84
$b1.Dispose()

# 2) ATR in hangar at night — brighten/enhance
$b2 = [System.Drawing.Bitmap]::FromFile((Join-Path $dir "jf (3).png"))
$b2enh = Adjust-Brightness-Contrast -Bmp $b2 -Brightness 1.22 -Contrast 1.1
Resize-Save -Bmp $b2enh -OutPath (Join-Path $dir "jf-real-hangar-atr.jpg") -MaxWidth 1600 -Quality 84
$b2.Dispose()
$b2enh.Dispose()

# 3) Paint job — rotate to correct orientation
$b3 = [System.Drawing.Bitmap]::FromFile((Join-Path $dir "jf (1).jpg"))
$b3.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone)
Resize-Save -Bmp $b3 -OutPath (Join-Path $dir "jf-real-pintura.jpg") -MaxWidth 1600 -Quality 84
$b3.Dispose()

Write-Host "Done."

