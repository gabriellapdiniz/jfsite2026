Add-Type -AssemblyName System.Drawing

function Whiten-DarkPixels {
    param(
        [string]$SrcPath,
        [string]$OutPath
    )

    $bmp = [System.Drawing.Bitmap]::FromFile($SrcPath)
    $w = $bmp.Width
    $h = $bmp.Height
    $rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
    $bmpData = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $stride = $bmpData.Stride
    $bytes = New-Object byte[] ($stride * $h)
    [System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $bytes, 0, $bytes.Length)

    for ($y = 0; $y -lt $h; $y++) {
        $rowOffset = $y * $stride
        for ($x = 0; $x -lt $w; $x++) {
            $idx = $rowOffset + $x * 4
            $b = $bytes[$idx]
            $g = $bytes[$idx + 1]
            $r = $bytes[$idx + 2]
            $a = $bytes[$idx + 3]

            if ($a -gt 10) {
                $maxc = [math]::Max($r, [math]::Max($g, $b))
                $minc = [math]::Min($r, [math]::Min($g, $b))
                $sat = $maxc - $minc
                # charcoal/gray pixels (low saturation) -> push to white; keep saturated (green/red) pixels as-is
                if ($sat -lt 30) {
                    $bytes[$idx] = 255
                    $bytes[$idx + 1] = 255
                    $bytes[$idx + 2] = 255
                }
            }
        }
    }

    [System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $bmpData.Scan0, $bytes.Length)
    $bmp.UnlockBits($bmpData)
    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "Saved: $OutPath"
    $bmp.Dispose()
}

$imgDir = "C:\Users\Luísa\OneDrive\Desktop\JF\websiteJF\assets\img"
Whiten-DarkPixels -SrcPath (Join-Path $imgDir "jf-mark.png") -OutPath (Join-Path $imgDir "jf-mark-white.png")
Whiten-DarkPixels -SrcPath (Join-Path $imgDir "jf-logo-horizontal.png") -OutPath (Join-Path $imgDir "jf-logo-horizontal-white.png")
Write-Host "Done."

