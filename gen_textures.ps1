Add-Type -AssemblyName System.Drawing

function New-Tex {
    param($Path, $Size, $PixelFunc)
    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    for ($y = 0; $y -lt $Size; $y++) {
        for ($x = 0; $x -lt $Size; $x++) {
            $bmp.SetPixel($x, $y, (& $PixelFunc $x $y $Size))
        }
    }
    $dir = Split-Path $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "OK $Path"
}

$root = "C:\Users\mihai\OneDrive\Desktop\open code\wireless-me\src\main\resources\assets\wirelessme"

# ---- Block: wireless_cable (16x16) ----
# Тёмный корпус ME-стиля + светящийся циановый "сигнал" волнами по центру
New-Tex "$root\textures\block\wireless_cable.png" 16 {
    param($x, $y, $s)
    $edge = ($x -eq 0 -or $y -eq 0 -or $x -eq 15 -or $y -eq 15)
    $base  = [System.Drawing.Color]::FromArgb(255, 40, 46, 64)     # тёмно-синий корпус
    $plate = [System.Drawing.Color]::FromArgb(255, 60, 68, 92)     # плата
    $glow  = [System.Drawing.Color]::FromArgb(255, 30, 224, 240)   # циановый свет
    $white = [System.Drawing.Color]::FromArgb(255, 220, 245, 255)

    if ($edge) { return $base }

    # центральный "экран" 8x6 (x 4..11, y 5..10)
    if ($x -ge 4 -and $x -le 11 -and $y -ge 5 -and $y -le 10) {
        # две волны сигнала: симметричные дуги
        $dx = [Math]::Abs($x - 7.5)
        $dy = [Math]::Abs($y - 8) 
        switch ($y) {
            5 { if ($dx -ge 3.5 -or $x -eq 4 -or $x -eq 11) { return $glow } }
            6 { if ($dx -eq 0 -or $dx -eq 3.5) { return $white } if ($dy -eq 2) {} }
            7 { if ($x -ge 4 -and $x -le 5 -or $x -ge 10 -and $x -le 11) { return $white } }
            8 { if ($x -eq 7 -or $x -eq 8) { return $glow } }
            9 { if ($x -eq 7 -or $x -eq 8) { return $glow } }
            10 { if ($x -ge 5 -and $x -le 10) { return $glow } }
        }
        return $plate
    }
    # угловые антенны сверху и снизу
    if (($y -eq 2 -or $y -eq 13) -and ($x -ge 2 -and $x -le 3 -or $x -ge 12 -and $x -le 13)) { return $glow }
    if (($y -eq 3 -or $y -eq 12) -and ($x -eq 2 -or $x -eq 3 -or $x -eq 12 -or $x -eq 13)) { return $plate }
    return $base
}

# ---- Item: wireless_linker (16x16) ----
# "Ремень" wand: металлический стержень с циановым кристаллом-сигналом сверху
New-Tex "$root\textures\item\wireless_linker.png" 16 {
    param($x, $y, $s)
    $stick  = [System.Drawing.Color]::FromArgb(255, 120, 94, 62)   # рукоять
    $stickD = [System.Drawing.Color]::FromArgb(255, 88, 66, 40)
    $steel  = [System.Drawing.Color]::FromArgb(255, 178, 190, 205) # металл
    $steelD = [System.Drawing.Color]::FromArgb(255, 130, 142, 158)
    $glow   = [System.Drawing.Color]::FromArgb(255, 30, 224, 240)
    $glowD  = [System.Drawing.Color]::FromArgb(255, 20, 150, 170)
    $clear  = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)

    $transparent = $true

    # кристалл (диагонали y 1..4, x 8..11 region)
    if ($y -ge 1 -and $y -le 4 -and $x -ge 7 -and $x -le 10) {
        if ($y -eq 1 -and ($x -eq 8)) { return $glowD }
        if ($y -eq 2 -and $x -ge 8 -and $x -le 9) { return $glow }
        if ($y -eq 3 -and $x -ge 8 -and $x -le 9) { return $glowD }
        if ($y -eq 4) { return $clear }
    }
    # антенна-переход
    if ($y -eq 5 -and $x -eq 8) { return $steel }
    # металлический стержень по диагонали x≈y-3
    if ($y -ge 6 -and $y -le 13) {
        $cx = $y - 2
        if ($x -eq $cx)     { return $steel }
        if ($x -eq $cx + 1) { return $steelD }
    }
    # рукоять снизу
    if ($y -ge 13 -and $y -le 15) {
        $cx = 11
        if ($x -ge $cx - 1 -and $x -le $cx + 1) { if ($y -eq 15) { return $stickD } else { return $stick } }
    }
    return $clear
}

# ---- Icon (64x64) ----
New-Tex "C:\Users\mihai\OneDrive\Desktop\open code\wireless-me\src\main\resources\assets\wirelessme\icon.png" 64 {
    param($x, $y, $s)
    $back = [System.Drawing.Color]::FromArgb(255, 26, 30, 44)
    $glow = [System.Drawing.Color]::FromArgb(255, 30, 224, 240)
    $white= [System.Drawing.Color]::FromArgb(255, 235, 250, 255)
    # тёмный фон со скруглением
    $cx = [Math]::Abs($x - 32); $cy = [Math]::Abs($y - 32)
    if ($cx -gt 26 -or $cy -gt 26) { return [System.Drawing.Color]::FromArgb(0,0,0,0) }
    # антенна: точка + расходящиеся кольца сигнала
    $d = [Math]::Sqrt($cx*$cx + $cy*$cy)
    if ($cx -le 3 -and $cy -le 3) { return $white }
    if ($d -lt 34 -and $d -gt 26 -and ($cx / [Math]::Max($cy,1)) -gt 0.9) { return $glow }
    if ($d -lt 22 -and $d -gt 15 -and ($cx / [Math]::Max($cy,1)) -gt 0.9) { return $glow }
    return $back
}
