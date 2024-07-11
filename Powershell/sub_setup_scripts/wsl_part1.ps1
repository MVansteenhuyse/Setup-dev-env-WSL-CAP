# Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# Enable Hyper-V
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart

# Schedule the next script to run after restart
$scriptPath = "./wsl_part2.ps1"
$taskName = "FinishWSLSetup"

# Create a scheduled task
schtasks /create /tn $taskName /tr "powershell -ExecutionPolicy Bypass -File $scriptPath" /sc onstart /ru System

# Restart the computer to apply changes
Restart-Computer
