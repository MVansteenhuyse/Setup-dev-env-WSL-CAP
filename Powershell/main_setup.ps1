# Paths to witness files
$witnessDir = "C:\Witness"
$witnessFiles = @(
    "$witnessDir\setup_wsl_ubuntu.txt",
    "$witnessDir\wsl_part1.txt",
    "$witnessDir\wsl_part2.txt",
    "$witnessDir\install_vscode_and_extensions.txt"
)

# Create witness directory if it doesn't exist
if (-Not (Test-Path $witnessDir)) {
    New-Item -ItemType Directory -Path $witnessDir
}

# Check and run each script based on the presence of its witness file
if (-Not (Test-Path $witnessFiles[0])) {
    .\setup_wsl_ubuntu.ps1
}

if (-Not (Test-Path $witnessFiles[1])) {
    .\wsl_part1.ps1
}

if (-Not (Test-Path $witnessFiles[2])) {
    .\wsl_part2.ps1
}

if (-Not (Test-Path $witnessFiles[3])) {
    .\install_vscode_and_extensions.ps1
}
