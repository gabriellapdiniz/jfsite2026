Add-Type -AssemblyName System.Drawing

function Process-Logo {
    param(
        [string]$SrcPath,
        [string]$FullOutPath,
        [string]$MarkOutPath,   # optional, $null to skip
        [int]$TargetWidth = 1400
    )

    $orig = [System.Drawing.Bitmap]::FromFile($SrcPath)
    $ratio = $TargetWidth / $orig.Width
    $targetHeight = [int]([math]::Round($orig.Height * $ratio))

    $resized = New-Object System.Drawing.Bitmap $TargetWidth, $targetHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($resized)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($orig, 0, 0, $TargetWidth, $targetHeight)
    $g.Dispose()
    $orig.Dispose()

    $w = $resized.Width
    $h = $resized.Height
    $rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
    $bmpData = $resized.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $stride = $bmpData.Stride
    $bytes = New-Object byte[] ($stride * $h)
    [System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $bytes, 0, $bytes.Length)

    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0
    $colHasContent = New-Object bool[] $w

    for ($y = 0; $y -lt $h; $y++) {
        $rowOffset = $y * $stride
        for ($x = 0; $x -lt $w; $x++) {
            $idx = $rowOffset + $x * 4
            $b = $bytes[$idx]
            $gr = $bytes[$idx + 1]
            $r = $bytes[$idx + 2]

            if ($r -ge 246 -and $gr -ge 246 -and $b -ge 246) {
                $bytes[$idx + 3] = 0
            } else {
                $bytes[$idx + 3] = 255
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
                $colHasContent[$x] = $true
            }
        }
    }

    [System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $bmpData.Scan0, $bytes.Length)
    $resized.UnlockBits($bmpData)

    $pad = 6
    $cx0 = [math]::Max(0, $minX - $pad)
    $cy0 = [math]::Max(0, $minY - $pad)
    $cx1 = [math]::Min($w - 1, $maxX + $pad)
    $cy1 = [math]::Min($h - 1, $maxY + $pad)
    $cropRect = New-Object System.Drawing.Rectangle $cx0, $cy0, ($cx1 - $cx0), ($cy1 - $cy0)
    $full = $resized.Clone($cropRect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $full.Save($FullOutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "Saved full: $FullOutPath ($($full.Width)x$($full.Height))"
    $full.Dispose()

    if ($MarkOutPath) {
        # find first content run (icon) then a gap of whitespace, then icon ends where gap starts
        $x = $minX
        # skip to end of initial content run allowing tiny gaps (<8px) inside the mark itself
        $gapCount = 0
        $iconEnd = $minX
        for ($x = $minX; $x -le $maxX; $x++) {
            if ($colHasContent[$x]) {
                $gapCount = 0
                $iconEnd = $x
            } else {
                $gapCount++
                if ($gapCount -gt 25) { break }
            }
        }
        $mx0 = [math]::Max(0, $minX - $pad)
        $my0 = [math]::Max(0, $minY - $pad)
        $mx1 = [math]::Min($w - 1, $iconEnd + $pad)
        $my1 = [math]::Min($h - 1, $maxY + $pad)
        $markRect = New-Object System.Drawing.Rectangle $mx0, $my0, ($mx1 - $mx0), ($my1 - $my0)
        $mark = $resized.Clone($markRect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $mark.Save($MarkOutPath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host "Saved mark: $MarkOutPath ($($mark.Width)x$($mark.Height))"
        $mark.Dispose()
    }

    $resized.Dispose()
}

$imgDir = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img"

Process-Logo -SrcPath (Join-Path $imgDir "jf-logo-src-1.png") `
             -FullOutPath (Join-Path $imgDir "jf-logo-horizontal.png") `
             -MarkOutPath (Join-Path $imgDir "jf-mark.png") `
             -TargetWidth 1400

Process-Logo -SrcPath (Join-Path $imgDir "jf-logo-src-2.png") `
             -FullOutPath (Join-Path $imgDir "jf-logo-stacked.png") `
             -MarkOutPath $null `
             -TargetWidth 1000

Write-Host "Done."

