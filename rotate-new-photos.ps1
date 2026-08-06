Add-Type -AssemblyName System.Drawing

$base = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img\photos"
$files = @("20260722_085326.jpg","20260731_145104.jpg","20260731_145515.jpg")

foreach ($f in $files) {
  $path = Join-Path $base $f
  $img = [System.Drawing.Image]::FromFile($path)
  $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone)

  # Reset EXIF orientation tag to 1 (normal) since pixels are now physically correct
  try {
    $prop = $img.GetPropertyItem(0x0112)
    $prop.Value = [byte[]]@(1,0)
    $img.SetPropertyItem($prop)
  } catch {}

  $outPath = Join-Path $base ("rotated_" + $f)
  $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
  $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]92)
  $img.Save($outPath, $encoder, $encParams)
  $img.Dispose()
  Write-Output "Rotated: $f -> rotated_$f ($($img.Width)x$($img.Height))"
}

