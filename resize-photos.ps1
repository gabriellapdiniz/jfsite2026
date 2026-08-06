Add-Type -AssemblyName System.Drawing

function Resize-And-Compress {
    param(
        [string]$SrcPath,
        [string]$OutPath,
        [int]$MaxWidth = 1600,
        [int]$Quality = 78
    )

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

    $size = (Get-Item $OutPath).Length
    Write-Host "$OutPath -> $($w)x$($h), $([math]::Round($size/1KB)) KB"
}

$dir = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"
Get-ChildItem $dir -Filter "*.jpg" | ForEach-Object {
    $tmp = Join-Path $dir ("_" + $_.Name)
    Resize-And-Compress -SrcPath $_.FullName -OutPath $tmp -MaxWidth 1600 -Quality 78
    Move-Item -Force $tmp $_.FullName
}
Write-Host "Done."

