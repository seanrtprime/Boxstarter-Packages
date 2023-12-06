# Description: Boxstarter Script
# Author: Jess Frazelle <jess@linux.com>
# Fork Modifications: Sean Ronald
# Last Updated: 2023-12-06
#
#
# To use:
#   From a fresh box, open Edge browser and enter this URL: https://boxstarter.org/package/url?https://github.com/seanrtprime/Boxstarter-Packages/blob/main/RTP-General.ps1
#
# Install Boxstarter and Chocolatey: -- You might need to set: Set-ExecutionPolicy RemoteSigned--
. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Ensure Chocolatey is in the PATH
$env:Path = "$env:Path;C:\ProgramData\chocolatey\bin"

# Checking if running from the bootstrapper
if (!(Get-Command "Install-BoxstarterPackage" -ErrorAction SilentlyContinue)) {
    # If not, install Boxstarter
    . { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
}
#
# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?<URL-TO-RAW-GIST>
# OR
# 	Install-BoxstarterPackage -PackageName <URL-TO-RAW-GIST> -DisableReboots
#
# Learn more: http://boxstarter.org/Learn/WebLauncher

#---- EXECUTION POLICY ----
Update-ExecutionPolicy Unrestricted -Force

#---- TEMPORARY ----
Disable-UAC
Disable-MicrosoftUpdate

#---- Windows Settings ----
Disable-BingSearch
Disable-GameBarTips
Enable-RemoteDesktop

#---- Quick Access & Taskbar Settings ----
Set-WindowsExplorerOptions -DisableHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -DisableShowFileExtensions -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess -EnableItemCheckBox -EnableExpandToOpenFolder
Set-BoxstarterTaskbarOptions -UnLock -Size Small -Dock Bottom -Combine Always -AlwaysShowIconsOn -NoAutoHide -MultiMonitorOn -MultiMonitorMode All -MultiMonitorCombine Always

#---- Windows Subsystems/Features ----
# choco install Microsoft-Hyper-V-All -source windowsFeatures
# choco install Microsoft-Windows-Subsystem-Linux -source windowsfeatures

#---- Tools ----
# choco install git -params '"/GitAndUnixToolsOnPath /WindowsTerminal"' -y
# choco install poshgit
# choco install sysinternals -y
# choco install vim
choco install vcredist140

#---- Apps ----
choco install googlechrome
choco install office365business
choco install 7zip
choco install foxitreader
choco install freecad
choco install malwarebytes


#---- Uninstall unecessary applications that come with Windows out of the box ----

# 3D Builder
Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage
# Alarms
Get-AppxPackage Microsoft.WindowsAlarms | Remove-AppxPackage
# Autodesk
Get-AppxPackage *Autodesk* | Remove-AppxPackage
# Bing Weather, News, Sports, and Finance (Money):
Get-AppxPackage Microsoft.BingFinance | Remove-AppxPackage
Get-AppxPackage Microsoft.BingNews | Remove-AppxPackage
Get-AppxPackage Microsoft.BingSports | Remove-AppxPackage
Get-AppxPackage Microsoft.BingWeather | Remove-AppxPackage
# BubbleWitch
Get-AppxPackage *BubbleWitch* | Remove-AppxPackage
# Candy Crush
Get-AppxPackage king.com.CandyCrush* | Remove-AppxPackage
# Comms Phone
Get-AppxPackage Microsoft.CommsPhone | Remove-AppxPackage
# Dell
#Get-AppxPackage *Dell* | Remove-AppxPackage
# Dropbox
Get-AppxPackage *Dropbox* | Remove-AppxPackage
# Facebook
Get-AppxPackage *Facebook* | Remove-AppxPackage
# Feedback Hub
Get-AppxPackage Microsoft.WindowsFeedbackHub | Remove-AppxPackage
# Get Started
Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage
# Keeper
Get-AppxPackage *Keeper* | Remove-AppxPackage
# Mail & Calendar
Get-AppxPackage microsoft.windowscommunicationsapps | Remove-AppxPackage
# Maps
Get-AppxPackage Microsoft.WindowsMaps | Remove-AppxPackage
# March of Empires
Get-AppxPackage *MarchofEmpires* | Remove-AppxPackage
# McAfee Security
Get-AppxPackage *McAfee* | Remove-AppxPackage
# Uninstall McAfee Security App
$mcafee = Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object { $_ -match "McAfee Security" } | Select-Object UninstallString
if ($mcafee) {
	$mcafee = $mcafee.UninstallString -Replace "C:\Program Files\McAfee\MSC\mcuihost.exe",""
	Write-Output "Uninstalling McAfee..."
	start-process "C:\Program Files\McAfee\MSC\mcuihost.exe" -arg "$mcafee" -Wait
}

# Messaging
Get-AppxPackage Microsoft.Messaging | Remove-AppxPackage
# Minecraft
Get-AppxPackage *Minecraft* | Remove-AppxPackage
# Netflix
Get-AppxPackage *Netflix* | Remove-AppxPackage
# Office Hub
#Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage
# One Connect
#Get-AppxPackage Microsoft.OneConnect | Remove-AppxPackage
# OneNote
#Get-AppxPackage Microsoft.Office.OneNote | Remove-AppxPackage
# People
Get-AppxPackage Microsoft.People | Remove-AppxPackage
# Phone
Get-AppxPackage Microsoft.WindowsPhone | Remove-AppxPackage
# Photos
Get-AppxPackage Microsoft.Windows.Photos | Remove-AppxPackage
# Plex
Get-AppxPackage *Plex* | Remove-AppxPackage
# Skype (Metro version)
Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage
# Sound Recorder
#Get-AppxPackage Microsoft.WindowsSoundRecorder | Remove-AppxPackage
# Solitaire
Get-AppxPackage *Solitaire* | Remove-AppxPackage
# Spotify
Get-AppxPackage *Spotify* | Remove-AppxPackage
# Sticky Notes
Get-AppxPackage Microsoft.MicrosoftStickyNotes | Remove-AppxPackage
# Sway
Get-AppxPackage Microsoft.Office.Sway | Remove-AppxPackage
# Twitter
Get-AppxPackage *Twitter* | Remove-AppxPackage
# Xbox
Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage
# Zune Music, Movies & TV
Get-AppxPackage Microsoft.ZuneMusic | Remove-AppxPackage
Get-AppxPackage Microsoft.ZuneVideo | Remove-AppxPackage


#---- Windows Settings ----
# Some from: @NickCraver's gist https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9

# Privacy: Let apps use my advertising ID: Disable
If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
}
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0

# WiFi Sense: HotSpot Sharing: Disable
If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
    New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
}
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0

# WiFi Sense: Shared HotSpot Auto-Connect: Disable
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0

# Start Menu: Disable Bing Search Results
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0
# To Restore (Enabled):
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 1

# Disable Xbox Gamebar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

#---- Group Policy Settings ----
#---- Group Policy Changes ----
# Create a temporary security policy file
$securityPolicy = @"
[Unicode]
Unicode=yes
[Version]
signature="$CHICAGO$"
Revision=1
[Privilege Rights]
SeNetworkLogonRight = *S-1-5-32-544, *S-1-5-32-545
SeInteractiveLogonRight = *S-1-5-32-544, *S-1-5-32-545
SeBatchLogonRight = *S-1-5-32-544
SeServiceLogonRight = *S-1-5-32-544
SeBackupPrivilege = *S-1-5-32-544
SeChangeNotifyPrivilege = *S-1-5-32-545
SeCreateGlobalPrivilege = *S-1-5-32-544
SeRemoteShutdownPrivilege = *S-1-5-32-544
SeTakeOwnershipPrivilege = *S-1-5-32-544
SeLoadDriverPrivilege = *S-1-5-32-544
SeBackupPrivilege = *S-1-5-32-544
SeRestorePrivilege = *S-1-5-32-544
[System Access]
MinimumPasswordAge = 0
MaximumPasswordAge = 365
MinimumPasswordLength = 6
PasswordComplexity = 0
PasswordHistorySize = 2
[User Rights]
ForceLogoffWhenHourExpire = 1
"@ 

$securityPolicy | Out-File -FilePath "$env:TEMP\securityPolicy.inf" -Encoding Unicode -Force

# Import the security policy file using secedit
secedit /configure /db %windir%\security\local.sdb /cfg "$env:TEMP\securityPolicy.inf" /areas SECURITYPOLICY
# Remove the temporary security policy file
Remove-Item "$env:TEMP\securityPolicy.inf" -Force
#---- End Group Policy Changes ----


#---- Restore Temporary Settings ----
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
