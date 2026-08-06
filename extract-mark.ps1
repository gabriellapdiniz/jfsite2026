Add-Type -AssemblyName System.Drawing

$imgDir = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img"
$src = Join-Path $imgDir "jf-logo-stacked.png"
$out = Join-Path $imgDir "jf-mark.png"

$bmp = [System.Drawing.Bitmap]::FromFile($src)
$w = $bmp.Width
$h = $bmp.Height
$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$bmpData = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$stride = $bmpData.Stride
$bytes = New-Object byte[] ($stride * $h)
[System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $bytes, 0, $bytes.Length)
$bmp.UnlockBits($bmpData)

$rowHasContent = New-Object bool[] $h
$minX = $w; $maxX = 0

for ($y = 0; $y -lt $h; $y++) {
    $rowOffset = $y * $stride
    $found = $false
    for ($x = 0; $x -lt $w; $x++) {
        $idx = $rowOffset + $x * 4
        $alpha = $bytes[$idx + 3]
        if ($alpha -gt 20) {
            $found = $true
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
        }
    }
    $rowHasContent[$y] = $found
}

# find first content row, then first gap of > 15 empty rows after it -> icon ends there
$minY = 0
while ($minY -lt $h -and -not $rowHasContent[$minY]) { $minY++ }

$gapCount = 0
$iconEndY = $minY
for ($y = $minY; $y -lt $h; $y++) {
    if ($rowHasContent[$y]) {
        $gapCount = 0
        $iconEndY = $y
    } else {
        $gapCount++
        if ($gapCount -gt 15) { break }
    }
}

# recompute minX/maxX restricted to icon rows only
$iMinX = $w; $iMaxX = 0
for ($y = $minY; $y -le $iconEndY; $y++) {
    $rowOffset = $y * $stride
    for ($x = 0; $x -lt $w; $x++) {
        $idx = $rowOffset + $x * 4
        if ($bytes[$idx + 3] -gt 20) {
            if ($x -lt $iMinX) { $iMinX = $x }
            if ($x -gt $iMaxX) { $iMaxX = $x }
        }
    }
}

$pad = 6
$cx0 = [math]::Max(0, $iMinX - $pad)
$cy0 = [math]::Max(0, $minY - $pad)
$cx1 = [math]::Min($w - 1, $iMaxX + $pad)
$cy1 = [math]::Min($h - 1, $iconEndY + $pad)
$cropRect = New-Object System.Drawing.Rectangle $cx0, $cy0, ($cx1 - $cx0), ($cy1 - $cy0)
$icon = $bmp.Clone($cropRect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$icon.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Saved icon mark: $out ($($icon.Width)x$($icon.Height))"
$icon.Dispose()
$bmp.Dispose()

