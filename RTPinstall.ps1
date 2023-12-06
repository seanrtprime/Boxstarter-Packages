<#
.SYNOPSIS
The setup scripts by Boxstarter.
#>

# RTPinstall.ps1

##############################################################
## FUNCTIONS

function Remove-SomeAppx()
{
  @(
    '*BubbleWitch*',
    '*DisneyMagicKingdom*',
    '*DolbyAccess*',
    'king.com.CandyCrush*',
    '*HiddenCityMysteryofShadows*',
    '*MarchofEmpires*',
    '*Netflix*',
    '*Spotify*',
    '*Facebook*',
    '*McAfee*',
    'Microsoft.BingFinance',
    'Microsoft.BingNews',
    'Microsoft.BingSports',
    'Microsoft.BingWeather',
    'Microsoft.MicrosoftOfficeHub'
  ) | ForEach-Object { Get-AppxPackage $_ | Remove-AppxPackage }
  <#
  .SYNOPSIS
  Remove some Appx packages.
  #>
}
#############################################################
## MAIN

# Set execution policy
Set-ExecutionPolicy Unrestricted -Force

# Temporarily disable Windows updates and UAC
Disable-WindowsUpdate
Disable-UAC

# Remove Bloat
Remove-SomeAppx

# Install specified packages
choco install vcredist-all
choco install googlechrome
choco install office365business
choco install 7zip
choco install foxitreader
choco install freecad
choco install malwarebytes

# Change Windows settings
Set-WindowsExplorerOptions -DisableHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -DisableShowFileExtensions -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess -EnableItemCheckBox -EnableExpandToOpenFolder
Set-BoxstarterTaskbarOptions -UnLock -Size Small -Dock Bottom -Combine Always -AlwaysShowIconsOn -NoAutoHide -MultiMonitorOn -MultiMonitorMode All -MultiMonitorCombine Always
Enable-RemoteDesktop
Disable-BingSearch
Disable-GameBarTips

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

# Re-enable Windows updates
Enable-WindowsUpdate
Enable-UAC
Install-WindowsUpdate

# Restart to apply changes
Restart-Computer -Force
