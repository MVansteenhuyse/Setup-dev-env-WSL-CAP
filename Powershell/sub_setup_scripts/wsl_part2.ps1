# Path to witness file
$witnessFile = "C:\Witness\wsl_part2.txt"

# Check if the script has already run
if (Test-Path $witnessFile) {
    Write-Output "wsl_part2.ps1 has already been executed."
    exit
}

# Load config
$config = ".\config.ps1"

. $config

# Set WSL 2 as the default version
wsl --set-default-version 2

# Install Ubuntu
wsl --install -d $linuxDistro

# Update system and setup user
$setup_wsl = ".\setup_wsl_ubuntu.ps1"

. $setup_wsl

New-Item -ItemType File -Path $witnessFile
Write-Output "WSL Part 2 setup completed."