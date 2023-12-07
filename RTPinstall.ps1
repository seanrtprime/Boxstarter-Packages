# Description: Boxstarter Script
# Author: Igor Borges <igor@borges.dev>
# Last Updated: 2022-12-07
#
########################   How To Use   ########################
# 
# 1.  Install most recent version of Chocolatey, by running the following on admin PowerShell:
#       Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#
# 2.  Restart PowerShell as admin, install Boxstarter by running the following command:
#       choco install boxstarter
#
# 3.  Run the following in BoxstarterShell or admin PowerShell:
#       Set-ExecutionPolicy RemoteSigned
#       Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/seanrtprime/Boxstarter-Packages/main/RTPinstall.ps1
#
# 
#
# References:
# Igor Borges <igor@borges.dev>
# https://github.com/bltavares/windows-devbox/blob/master/install.ps1
# https://gist.github.com/mrichards42/fa7eb6dbb5994855552a1d964d4754de
# https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9
# https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
# https://gist.github.com/zloeber/9c2d659a2a8f063af26c9ba0285c7e78


#------------------------------------------------------------------------------
# TEMPORARY
#------------------------------------------------------------------------------
Disable-UAC


#------------------------------------------------------------------------------
# Uninstall unnecessary applications that come with Windows out of the box
#------------------------------------------------------------------------------

# To list store apps: Get-AppxPackage | sort -property Name | Select-Object Name, PackageFullName, Version | Format-Table -AutoSize

# Remove junk
function removeApp {
    Param ([string]$appName)
    Write-Output "Trying to remove $appName"
    Get-AppxPackage $appName -AllUsers | Remove-AppxPackage
    Get-AppXProvisionedPackage -Online | Where DisplayNam -like $appName | Remove-AppxProvisionedPackage -Online
}

$applicationList = @(
    "*MarchofEmpires*"
    "*Autodesk*"
    "*BubbleWitch*"
    "*garden*"
    "*hidden*"
    "*deezer*"
    "*phototastic*"
    "*tunein*"
    "king.com*"
    "G5*"
    "*Facebook*"
    "*Keeper*"
    "*.EclipseManager"
    "ActiproSoftwareLLC.562882FEEB491" # Code Writer
    "*DolbyAccess*"
    "*disney*"
    "*HiddenCityMysteryofShadows*"
#    "*Dell*"
    "*Dropbox*"
    "*Facebook*"
    "*Keeper*"
    "*McAfee*"
    "*Minecraft*"
    "*Twitter*"

#    "*outlook*"
#    "*onedrive*"
#    "*onenote*"
    "Microsoft.*advertising*"
    "Microsoft.*3D*"
    "Microsoft.Bing*"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
#    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.Music*"
#    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
#    "Microsoft.OneConnect"
#    "Microsoft.OneDriveSync"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
#    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
#    "Microsoft.WindowsSoundRecorder"
    "microsoft.windowscommunicationsapps"
    "Microsoft.Zune*"
#    "MicrosoftTeams"
);

foreach ($app in $applicationList) {
    removeApp $app
}

# Uninstall McAfee Security App
$mcafee = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "McAfee Security" } | select UninstallString
if ($mcafee) {
    $mcafee = $mcafee.UninstallString -Replace "C:\Program Files\McAfee\MSC\mcuihost.exe",""
    Write "Uninstalling McAfee..."
    start-process "C:\Program Files\McAfee\MSC\mcuihost.exe" -arg "$mcafee" -Wait
}


#------------------------------------------------------------------------------
# Windows Settings
#------------------------------------------------------------------------------

try {
    Update-ExecutionPolicy Unrestricted
    Set-ExplorerOptions -DisableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -DisableShowFileExtensions -EnableItemCheckBox
    Set-TaskbarSmall
    Enable-RemoteDesktop
    Disable-BingSearch
    Disable-GameBarTips

	## Opens PC to This PC, not quick access
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1

	## Disable Quick Access: Recent Files
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 0

	## Disable Quick Access: Frequent Folders
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 0

	## Dock
	Set-BoxstarterTaskbarOptions -Size Small -Dock Bottom -Combine Always -AlwaysShowIconsOn -MultiMonitorOn -MultiMonitorMode All -MultiMonitorCombine Always

	## Privacy: Let apps use my advertising ID: Disable	
	If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {	
	    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null	
	}	
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0	

	## Privacy: SmartScreen Filter for Store Apps: Disable	
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Name EnableWebContentEvaluation -Type DWord -Value 0	

	## WiFi Sense: HotSpot Sharing: Disable	
	If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {	
	    New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null	
	}	
	Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0	

	## WiFi Sense: Shared HotSpot Auto-Connect: Disable	
	Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0	

	## Start Menu: Disable Bing Search Results	
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0	

	## Turn off People in Taskbar	
	If (-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {	
	    New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null	
	}	
	Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0
} catch {}

#------------------------------------------------------------------------------
# Software
#------------------------------------------------------------------------------

# Apps

$applicationList = @(
  "googlechrome"
  "7zip"
  "freecad"
  "foxitreader"
  "paint.net"
  "googledrive"
  "malwarebytes"
);

foreach ($app in $applicationList) {
    choco install -y $app
}


#Time Settings
w32TM /config /syncfromflags:manual /manualpeerlist:time.google.com
w32tm /config /update
w32tm /resync

#------------------------------------------------------------------------------
# Restore Temporary Settings
#------------------------------------------------------------------------------
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
