<#
.SYNOPSIS
The setup scripts by Boxstarter.
#>

Set-StrictMode -Version Latest

###########################################################################
### Constants

Get-CimInstance Win32_ComputerSystem `
| Select-Object -ExpandProperty SystemType `
| Set-Variable -Name ARCH -Option Constant -Scope local
Get-CimInstance win32_OperatingSystem `
| Select-Object -ExpandProperty Version `
| Set-Variable -Name WINVER -Option Constant -Scope local
Join-Path $env:TEMP 'rtp.setup.windows.tmp' `
| Set-Variable -Name RUNNING_FILE -Option Constant -Scope local

$ARCH -like 'ARM64*' `
| Set-Variable -Name IS_ARM64 -Option Constant -Scope local
$WINVER -match '^1(0|1)\.' `
| Set-Variable -Name IS_WIN1X -Option Constant -Scope local

$global:CHOCO_INSTALLS = @()

###########################################################################
### Functions

# RTP-General -------------------------------------------------------------
function Add-RtpGeneral()
{
  $global:CHOCO_INSTALLS += , @(
  'vcredist-all', 
  'googlechrome', 
  'office365business', 
  '7zip',
  'foxitreader'
  'freecad', 
  'malwarebytes'
  )
  <#
  .SYNOPSIS
  Add the queue of audio and broadcasting tools to install.
  #>
}

function Add-FontsInstallation()
{
#  $global:CHOCO_INSTALLS += , @(
#    'cascadiafonts',
#    'firacode',
#    'font-hackgen',
#    'font-hackgen-nerd',
#    'lato'
#  )
  <#
  .SYNOPSIS
  Add the queue of fonts to install.
  #>
}

function Add-ShellExtensionsInstallation()
{
  $global:CHOCO_INSTALLS += @(
    @('powershell'), # !! DEPENDENCIES
    @(
      'pwsh',
      '--install-arguments="ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=1 USE_MU=1 ENABLE_MU=1"',
      '--packageparameters "/CleanUpPath"'
    ),
    @(
      'oh-my-posh',
      'poshgit' # ! <- CLI ERROR (but not stack)
    )
  )
  <#
  .SYNOPSIS
  Add the queue of shell extensions to install.
  #>
}

# Get ---------------------------------------------------------------------
function Get-OpenSSHInstalls()
{
  Get-WindowsCapability -Online `
  | Where-Object -Property Name -Match OpenSSH `
  | Where-Object -Property State -EQ Installed `
  | Measure-Object `
  | Select-Object -ExpandProperty Count
  <#
  .SYNOPSIS
  Get the number of OpenSSH installations.
  #>
}

# Install -----------------------------------------------------------------
function Install-ChocoPackages()
{
  $global:CHOCO_INSTALLS | ForEach-Object {
    choco install @_
  }
  <#
  .SYNOPSIS
  Install the queued packages with Chocolatey.
  #>
}

function Install-SomeWindowsCapability()
{
  $installList = @(
    # Languages and fonts
    'en-US',
    'es-ES',
    'fr-FR',
    'zh-CN',
#    'Language.Basic.*ja-JP', # ! ERROR?? on Vagrant Win10 (intel)
#    'Language.Fonts.Jpan'

    # Others
    'DirectX'
#    'OpenSSH',
 #   'ShellComponents',
    # 'StorageManagement', # ! ERROR?? on Vagrant Win11 (intel)
#    'Tools.DeveloperMode.Core',
#    'XPS.Viewer'
  )

  $caps = Get-WindowsCapability -Online `
  | Where-Object -Property State -NE Installed
  $installList | ForEach-Object {
    $target = $_
    $caps `
    | Where-Object -Property Name -Match $target `
    | Select-Object -ExpandProperty Name
  } | ForEach-Object {
    Write-BoxstarterMessage ('installing {0}...' -f $_)
    Add-WindowsCapability `
      -Name $_ `
      -ErrorAction:SilentlyContinue `
      -Online
  }

  <#
  .SYNOPSIS
  Install the queued Windows capabilities.
  #>
}

function Install-SomeWindowsFeatures()
{
  $installList = @(
    # Virtualization
#    'Microsoft-Hyper-V-All',
#    'VirtualMachinePlatform',
#    'HypervisorPlatform',
#    'Microsoft-Windows-Subsystem-Linux',

    # NFS
#    'ServicesForNFS-ClientOnly',
#    'ClientForNFS-Infrastructure',
#    'NFS-administration',

    # Connection
#    'TelnetClient',
#    'TFTP',

    # Others
#    'NetFx3',
#    'TIFFIFilter',
    'Windows-Defender-ApplicationGuard'
  )
  try
  {
    $disabledFeatures = choco find -s windowsfeatures `
    | Select-String Disabled `
    | Select-Object -ExpandProperty Line `
    | Select-String -Pattern '^[A-Za-z0-9-]+' `
    | Select-Object -ExpandProperty Matches `
    | Select-Object -ExpandProperty Value
    $diff = Compare-Object `
      -ReferenceObject $installList `
      -DifferenceObject $disabledFeatures `
      -PassThru `
      -IncludeEqual `
      -ExcludeDifferent
    choco install @diff -s windowsfeatures
  }
  catch
  {
    Write-BoxstarterMessage `
      -message 'Notice: Chocolatey search for Windows features failed so it will install all listed components. So slightly increases the installation process but does not affect the installation results.' `
      -nologo `
      -color DarkYellow
    choco install @installList -s windowsfeatures
  }
  <#
  .SYNOPSIS
  Install some Windows features.
  #>
}

# Pop ---------------------------------------------------------------------
function Pop-Preparation()
{
  Remove-Item $RUNNING_FILE -Force
  Enable-UAC
  <#
  .SYNOPSIS
  Remove the preparation settings.
  #>
}

# Push --------------------------------------------------------------------
function Push-Preparation()
{
  New-Item -Type File $RUNNING_FILE -Force | Out-Null
  Disable-UAC
  <#
  .SYNOPSIS
  Set the preparation settings.
  #>
}

# Remove ------------------------------------------------------------------
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

# Set ---------------------------------------------------------------------
function Set-ChocoFeatures()
{
  choco feature disable -n=skipPackageUpgradesWhenNotInstalled
  choco feature enable -n=useRememberedArgumentsForUpgrades
  <#
  .SYNOPSIS
  Set the Chocolatey features.
  #>
}

function Set-CleanManagerSageSet()
{
  $baseUri = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\'
  $keys = @(
    'Active Setup Temp Folders',
    'BranchCache',
    'D3D Shader Cache',
    'Delivery Optimization Files',
    'Diagnostic Data Viewer database files',
    'Downloaded Program Files',
    'Internet Cache Files',
    'Old ChkDsk Files',
    'Recycle Bin',
    'RetailDemo Offline Content',
    'Setup Log Files',
    'System error memory dump files',
    'System error minidump files',
    'Temporary Files',
    'Thumbnail Cache',
    'Update Cleanup',
    'User file versions',
    'Windows Defender',
    'Windows Error Reporting Files'
  )
  $keys | ForEach-Object {
    New-ItemProperty `
      -Path ($baseUri + $_) `
      -Name StateFlags0001 `
      -PropertyType DWord `
      -Value 2 `
      -Force `
    | Out-Null
  }
  <#
  .SYNOPSIS
  Set the CleanManager SageSet.
  #>
}

function Set-WindowsOptions()
{
#  Set-CornerNavigationOptions -EnableUpperLeftCornerSwitchApps -EnableUsePowerShellOnWinX
  Set-WindowsExplorerOptions -DisableHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -DisableShowFileExtensions -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess -EnableItemCheckBox -EnableExpandToOpenFolder
#  Set-StartScreenOptions -DisableBootToDesktop -EnableShowStartOnActiveScreen -EnableShowAppsViewOnStartScreen -EnableSearchEverywhereInAppsView -DisableListDesktopAppsFirst
  Set-BoxstarterTaskbarOptions -UnLock -Size Small -Dock Bottom -Combine Always -AlwaysShowIconsOn -NoAutoHide -MultiMonitorOn -MultiMonitorMode All -MultiMonitorCombine Always
  Enable-RemoteDesktop
  Disable-BingSearch
  Disable-GameBarTips

  ### Explorer options
#  Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
#  Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name SeparateProcess -Value 1
  Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCompColor -Value 1

  ### Taskbar options
#  Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -Value 1
  <#
  .SYNOPSIS
  Set the Windows options.
  #>
}

###########################################################################
### Main

Push-Preparation
Set-ChocoFeatures
choco install boxstarter chocolatey

###########################################################################
### Windows Features

Remove-SomeAppx
Set-WindowsOptions

Set-CleanManagerSageSet
cleanmgr /dc /sagerun:1

Install-SomeWindowsCapability
Install-SomeWindowsFeatures

###########################################################################
### Install apps via Chocolatey

Add-RtpGeneral
Add-ShellExtensionsInstallation
Add-FontsInstallation

Install-ChocoPackages

###########################################################################
### Install apps via without Chocolatey

#Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression

###########################################################################

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

##########################################################################

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

###########################################################################
### Update
Enable-MicrosoftUpdate
Install-WindowsUpdate

###########################################################################
### Teardown
Pop-Preparation
