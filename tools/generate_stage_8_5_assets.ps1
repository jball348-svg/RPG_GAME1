Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$repoRoot = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $repoRoot "assets\\art\\generated\\stage_8_5"
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

function Save-Bitmap {
	param(
		[Parameter(Mandatory = $true)]
		[System.Drawing.Bitmap]$Bitmap,

		[Parameter(Mandatory = $true)]
		[string]$RelativePath
	)

	$targetPath = Join-Path $outputDir $RelativePath
	$targetDir = Split-Path -Parent $targetPath
	New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
	$Bitmap.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
	$Bitmap.Dispose()
}

function New-PixelBitmap {
	param(
		[int]$Width,
		[int]$Height
	)

	$bitmap = New-Object System.Drawing.Bitmap $Width, $Height
	for ($y = 0; $y -lt $Height; $y++) {
		for ($x = 0; $x -lt $Width; $x++) {
			$bitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
		}
	}
	return $bitmap
}

function Fill-Rect {
	param(
		[System.Drawing.Bitmap]$Bitmap,
		[int]$X,
		[int]$Y,
		[int]$Width,
		[int]$Height,
		[System.Drawing.Color]$Color
	)

	for ($yy = $Y; $yy -lt ($Y + $Height); $yy++) {
		for ($xx = $X; $xx -lt ($X + $Width); $xx++) {
			if ($xx -lt 0 -or $yy -lt 0 -or $xx -ge $Bitmap.Width -or $yy -ge $Bitmap.Height) {
				continue
			}
			$Bitmap.SetPixel($xx, $yy, $Color)
		}
	}
}

function New-FighterMapSprite {
	$bmp = New-PixelBitmap -Width 32 -Height 32
	$outline = [System.Drawing.Color]::FromArgb(255, 24, 26, 31)
	$steel = [System.Drawing.Color]::FromArgb(255, 176, 176, 176)
	$cloth = [System.Drawing.Color]::FromArgb(255, 132, 120, 104)
	$accent = [System.Drawing.Color]::FromArgb(255, 228, 208, 166)
	$shadow = [System.Drawing.Color]::FromArgb(255, 72, 72, 82)

	Fill-Rect $bmp 11 2 10 5 $outline
	Fill-Rect $bmp 12 3 8 3 $steel
	Fill-Rect $bmp 9 7 14 7 $outline
	Fill-Rect $bmp 10 8 12 5 $steel
	Fill-Rect $bmp 8 11 16 10 $outline
	Fill-Rect $bmp 10 12 12 8 $cloth
	Fill-Rect $bmp 12 12 8 2 $accent
	Fill-Rect $bmp 6 12 3 8 $outline
	Fill-Rect $bmp 23 12 3 8 $outline
	Fill-Rect $bmp 7 13 1 6 $steel
	Fill-Rect $bmp 24 13 1 6 $steel
	Fill-Rect $bmp 11 20 4 8 $outline
	Fill-Rect $bmp 17 20 4 8 $outline
	Fill-Rect $bmp 12 21 2 6 $shadow
	Fill-Rect $bmp 18 21 2 6 $shadow
	return $bmp
}

function New-BattlemageMapSprite {
	$bmp = New-PixelBitmap -Width 32 -Height 32
	$outline = [System.Drawing.Color]::FromArgb(255, 24, 26, 31)
	$robe = [System.Drawing.Color]::FromArgb(255, 110, 108, 132)
	$trim = [System.Drawing.Color]::FromArgb(255, 191, 176, 110)
	$hat = [System.Drawing.Color]::FromArgb(255, 92, 88, 118)
	$staff = [System.Drawing.Color]::FromArgb(255, 120, 82, 48)
	$orb = [System.Drawing.Color]::FromArgb(255, 180, 222, 236)

	Fill-Rect $bmp 8 2 16 3 $outline
	Fill-Rect $bmp 10 3 12 1 $hat
	Fill-Rect $bmp 10 5 12 3 $outline
	Fill-Rect $bmp 11 6 10 2 $hat
	Fill-Rect $bmp 11 8 10 4 $outline
	Fill-Rect $bmp 12 9 8 2 $robe
	Fill-Rect $bmp 9 12 14 12 $outline
	Fill-Rect $bmp 10 13 12 10 $robe
	Fill-Rect $bmp 12 13 8 2 $trim
	Fill-Rect $bmp 7 10 2 14 $staff
	Fill-Rect $bmp 6 8 4 3 $outline
	Fill-Rect $bmp 7 9 2 1 $orb
	Fill-Rect $bmp 11 24 4 6 $outline
	Fill-Rect $bmp 17 24 4 6 $outline
	Fill-Rect $bmp 12 25 2 4 $trim
	Fill-Rect $bmp 18 25 2 4 $trim
	return $bmp
}

function New-NpcMapSprite {
	$bmp = New-PixelBitmap -Width 32 -Height 32
	$outline = [System.Drawing.Color]::FromArgb(255, 24, 26, 31)
	$tunic = [System.Drawing.Color]::FromArgb(255, 118, 138, 102)
	$belt = [System.Drawing.Color]::FromArgb(255, 120, 88, 52)
	$hair = [System.Drawing.Color]::FromArgb(255, 92, 66, 48)

	Fill-Rect $bmp 11 3 10 4 $outline
	Fill-Rect $bmp 12 4 8 2 $hair
	Fill-Rect $bmp 10 7 12 5 $outline
	Fill-Rect $bmp 11 8 10 3 $tunic
	Fill-Rect $bmp 8 12 16 10 $outline
	Fill-Rect $bmp 10 13 12 8 $tunic
	Fill-Rect $bmp 11 16 10 1 $belt
	Fill-Rect $bmp 11 22 4 7 $outline
	Fill-Rect $bmp 17 22 4 7 $outline
	Fill-Rect $bmp 12 23 2 5 $hair
	Fill-Rect $bmp 18 23 2 5 $hair
	return $bmp
}

function New-WeaponOverlay {
	$bmp = New-PixelBitmap -Width 24 -Height 24
	$outline = [System.Drawing.Color]::FromArgb(255, 24, 26, 31)
	$blade = [System.Drawing.Color]::FromArgb(255, 218, 224, 232)
	$edge = [System.Drawing.Color]::FromArgb(255, 166, 182, 204)
	$hilt = [System.Drawing.Color]::FromArgb(255, 123, 88, 52)
	$pommel = [System.Drawing.Color]::FromArgb(255, 214, 180, 96)

	Fill-Rect $bmp 10 2 3 10 $outline
	Fill-Rect $bmp 11 3 1 8 $blade
	Fill-Rect $bmp 10 4 1 6 $edge
	Fill-Rect $bmp 12 4 1 6 $edge
	Fill-Rect $bmp 8 11 7 2 $outline
	Fill-Rect $bmp 9 12 5 1 $pommel
	Fill-Rect $bmp 10 13 3 5 $outline
	Fill-Rect $bmp 11 14 1 3 $hilt
	Fill-Rect $bmp 10 18 3 2 $outline
	Fill-Rect $bmp 11 19 1 1 $pommel
	return $bmp
}

function New-ShamanPortrait {
	$bitmap = New-Object System.Drawing.Bitmap 128, 128
	$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
	$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
	$graphics.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))

	$backgroundRect = New-Object System.Drawing.Rectangle 0, 0, 128, 128
	$backgroundBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
		$backgroundRect,
		[System.Drawing.Color]::FromArgb(255, 44, 34, 24),
		[System.Drawing.Color]::FromArgb(255, 18, 22, 24),
		90.0
	)
	$graphics.FillRectangle($backgroundBrush, $backgroundRect)

	$mistBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(62, 98, 132, 104))
	$graphics.FillEllipse($mistBrush, 10, 20, 108, 78)

	$hoodBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 68, 78, 58))
	$graphics.FillPie($hoodBrush, 18, 12, 92, 94, 205, 130)
	$graphics.FillRectangle($hoodBrush, 32, 56, 64, 40)

	$faceBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 136, 114, 88))
	$graphics.FillEllipse($faceBrush, 38, 34, 40, 48)

	$shadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(170, 28, 24, 20))
	$graphics.FillEllipse($shadowBrush, 34, 40, 48, 24)

	$eyeBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 220, 236, 178))
	$graphics.FillEllipse($eyeBrush, 46, 52, 6, 4)
	$graphics.FillEllipse($eyeBrush, 62, 52, 6, 4)

	$staffBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 116, 82, 46))
	$graphics.FillRectangle($staffBrush, 92, 18, 6, 86)
	$orbBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 158, 208, 184))
	$graphics.FillEllipse($orbBrush, 84, 8, 22, 22)

	$framePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 182, 154, 102)), 4
	$graphics.DrawRectangle($framePen, 2, 2, 123, 123)

	$orbBrush.Dispose()
	$staffBrush.Dispose()
	$eyeBrush.Dispose()
	$shadowBrush.Dispose()
	$faceBrush.Dispose()
	$hoodBrush.Dispose()
	$mistBrush.Dispose()
	$framePen.Dispose()
	$backgroundBrush.Dispose()
	$graphics.Dispose()
	return $bitmap
}

Save-Bitmap -Bitmap (New-FighterMapSprite) -RelativePath "map_fighter.png"
Save-Bitmap -Bitmap (New-BattlemageMapSprite) -RelativePath "map_battlemage.png"
Save-Bitmap -Bitmap (New-NpcMapSprite) -RelativePath "map_npc.png"
Save-Bitmap -Bitmap (New-WeaponOverlay) -RelativePath "weapon_overlay.png"
Save-Bitmap -Bitmap (New-ShamanPortrait) -RelativePath "shaman_portrait.png"
