# Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# Enable Hyper-V
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart

# Schedule the next script to run after restart
$scriptPath = (Get-Location).Path + "sub_setup_scripts\wsl_part2.ps1"
$taskName = "FinishWSLSetup"

# Create a scheduled task to run PowerShell visibly
$scheduleTaskCommand = schtasks /create /tn $taskName /tr "powershell.exe -ExecutionPolicy Bypass -File `"$scriptPath`"" /sc onstart /ru System

# Execute the task creation command
Invoke-Expression $scheduleTaskCommand

# Check if the task scheduling succeeded
if ($LASTEXITCODE -eq 0) {
    Write-Output "Scheduled task created successfully. Restarting the computer..."
    Start-Sleep -Seconds 5

    # Restart the computer to apply changes
    Restart-Computer
} else {
    Write-Error "Failed to create scheduled task. The computer will not restart."
}
