# Function to remove witness files
function Remove-WitnessFiles {
    $witnessDir = "C:\\Witness"
    if (Test-Path $witnessDir) {
        Write-Output "Removing witness files..."
        Remove-Item -Recurse -Force $witnessDir
    } else {
        Write-Output "Witness directory not found. No files to remove."
    }
}

# Function to disable WSL
function Disable-WSL {
    Write-Output "Disabling WSL..."
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
}

# Function to remove WSL distributions
function Remove-WSLDistributions {
    Write-Output "Removing WSL distributions..."
    $distributions = wsl --list --all --quiet
    foreach ($distro in $distributions) {
        Write-Output "Unregistering distribution: $distro"
        wsl --unregister $distro
    }
}

# Main script execution
Remove-WitnessFiles
Disable-WSL
Remove-WSLDistributions

Write-Output "Reversion script completed."
