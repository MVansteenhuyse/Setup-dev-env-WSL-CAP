# Get the current script directory
$currentDir = Get-Location

Write-Output "Setting up VSCode and extensions"

# Construct the absolute path for the script
$vscodeScriptPath = Join-Path $currentDir "sub_setup_script\install_vscode_and_extensions.ps1"
if (Test-Path $vscodeScriptPath) {
    & $vscodeScriptPath
} else {
    Write-Error "Script not found: $vscodeScriptPath"
}

Write-Output "Setting up policies & installing WSL2 Ubuntu LTS after windows restart"

# Construct the absolute path for the script
$wslScriptPath = Join-Path $currentDir "sub_setup_script\wsl_part1.ps1"
if (Test-Path $wslScriptPath) {
    & $wslScriptPath
} else {
    Write-Error "Script not found: $wslScriptPath"
}
