# Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Add Chocolatey to PATH
$chocoPath = Join-Path $env:ProgramData 'chocolatey\bin'
$existingPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine)
if ($existingPath -notcontains $chocoPath) {
    [System.Environment]::SetEnvironmentVariable('PATH', "$existingPath;$chocoPath", [System.EnvironmentVariableTarget]::Machine)
}
