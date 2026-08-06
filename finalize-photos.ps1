Add-Type -AssemblyName System.Drawing

$dir = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"

function Resize-And-Compress {
    param([string]$SrcPath, [string]$OutPath, [int]$MaxWidth = 1400, [int]$Quality = 80)
    $orig = [System.Drawing.Bitmap]::FromFile($SrcPath)
    $ratio = [math]::Min(1.0, $MaxWidth / $orig.Width)
    $w = [int]($orig.Width * $ratio)
    $h = [int]($orig.Height * $ratio)
    $resized = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($resized)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($orig, 0, 0, $w, $h)
    $g.Dispose()
    $orig.Dispose()
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
    $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)
    $resized.Save($OutPath, $codec, $encParams)
    $resized.Dispose()
    Write-Host "$OutPath -> $($w)x$($h)"
}

# Crop componentes: remove top banner text (~14%) and right-side clutter (~8%)
$src = Join-Path $dir "jf-tile-componentes.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($src)
$cropY = [int]($bmp.Height * 0.14)
$cropH = $bmp.Height - $cropY
$cropW = [int]($bmp.Width * 0.90)
$rect = New-Object System.Drawing.Rectangle 0, $cropY, $cropW, $cropH
$cropped = $bmp.Clone($rect, $bmp.PixelFormat)
$tmp = Join-Path $dir "_componentes_cropped.jpg"
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]85)
$cropped.Save($tmp, $codec, $encParams)
$bmp.Dispose()
$cropped.Dispose()
Move-Item -Force $tmp $src
Write-Host "Cropped componentes -> $($cropW)x$($cropH)"

# Resize the new fleet replacement photos
foreach ($name in @("jf-fleet-airbus.jpg", "jf-fleet-atr.jpg", "jf-fleet-outros.jpg")) {
    $p = Join-Path $dir $name
    $tmp2 = Join-Path $dir ("_" + $name)
    Resize-And-Compress -SrcPath $p -OutPath $tmp2 -MaxWidth 1400 -Quality 80
    Move-Item -Force $tmp2 $p
}

# Remove the original branded hangar photo (kept only the cropped unbranded version)
Remove-Item -Force (Join-Path $dir "jf-hangar.jpg") -ErrorAction SilentlyContinue

Write-Host "Done."

