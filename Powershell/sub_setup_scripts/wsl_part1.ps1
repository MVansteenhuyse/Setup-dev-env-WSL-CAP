# Path to witness file
$witnessFile = "C:\Witness\wsl_part1.txt"

# Check if the script has already run
if (Test-Path $witnessFile) {
    Write-Output "wsl_part1.ps1 has already been executed."
    exit
}

# Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# Enable Hyper-V
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart

# Set the witness file
New-Item -ItemType File -Path $witnessFile

# Check if the file was created, if yes reboot
if (Test-Path $witnessFile) {
    Start-Sleep -Seconds 50
    Restart-Computer
} else {
    Write-Error "Failed to create witness files. The computer will not restart."
}
