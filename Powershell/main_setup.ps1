# Paths to witness files
$witnessDir = "C:\\Witness"
$witnessConditions = @(
    @{Name = "VSCODE" ; ScriptStep = '1'; Path = "$witnessDir\\install_vscode_and_extensions.txt"; Condition = {-Not (Test-Path "$witnessDir\\install_vscode_and_extensions.txt")}; Script = ".\\sub_setup_scripts\\install_vscode_and_extensions.ps1" },
    @{Name = "WSL PART 1" ; ScriptStep = '2'; Path = "$witnessDir\\wsl_part1.txt"; Condition = { (Test-Path "$witnessDir\\install_vscode_and_extensions.txt") -and (-Not (Test-Path "$witnessDir\\wsl_part1.txt")) }; Script = ".\\sub_setup_scripts\\wsl_part1.ps1" },
    @{Name = "WSL PART 2" ; ScriptStep = '3'; Path = "$witnessDir\\wsl_part2.txt"; Condition = { (Test-Path "$witnessDir\\wsl_part1.txt") -and (-Not (Test-Path "$witnessDir\\wsl_part2.txt")) }; Script = ".\\sub_setup_scripts\\wsl_part2.ps1" },
    @{Name = "WSL UBUNTU CONFIG" ; ScriptStep = '4'; Path = "$witnessDir\\setup_wsl_ubuntu.txt"; Condition = { (Test-Path "$witnessDir\\wsl_part1.txt") -and (Test-Path "$witnessDir\\wsl_part2.txt") -and (-Not (Test-Path "$witnessDir\\setup_wsl_ubuntu.txt")) }; Script = ".\\sub_setup_scripts\\setup_wsl_ubuntu.ps1" }
)

# Create witness directory if it doesn't exist
if (-Not (Test-Path $witnessDir)) {
    New-Item -ItemType Directory -Path $witnessDir
}

# Iterate through the conditions and execute the corresponding scripts
foreach ($condition in $witnessConditions) {
    if (& $condition.Condition) {
        Write-Output "$($condition.Name): this is step[$($condition.ScriptStep)]"
        & $condition.Script
    }
}
