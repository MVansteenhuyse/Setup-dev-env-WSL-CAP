# setup_1pass_cli.ps1

# Install 1password CLI
Write-Output "Installing 1password CLI..."
winget install 1password-cli

# Verify installation
Write-Output "Verifying 1password CLI installation..."
$reloadShellCommand = "op --version"
Invoke-Expression $reloadShellCommand

# Create the witness file
New-Item -ItemType File -Path "C:\\Witness\\setup_1pass_cli.txt"