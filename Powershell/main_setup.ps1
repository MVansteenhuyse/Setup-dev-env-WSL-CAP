Write-Output "Setting up VScode and extensions"
.\sub_setup_script\install_vscode_and_extensions.ps1

Write-Output "Setting up policies & installing WSL2 Ubuntu LTS after windows restart"
.\sub_setup_script\wsl_part1.ps1