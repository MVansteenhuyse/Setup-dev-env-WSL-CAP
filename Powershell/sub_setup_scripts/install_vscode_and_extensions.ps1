# Function to check if VSCode is installed
function Check-VSCode {
    $vscodePath = "C:\Program Files\Microsoft VS Code\Code.exe"
    if (Test-Path $vscodePath) {
        Write-Output "VSCode is already installed."
        return $true
    } else {
        Write-Output "VSCode is not installed."
        return $false
    }
}

# Function to install VSCode
function Install-VSCode {
    Write-Output "Installing VSCode..."
    $vscodeInstallerUrl = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
    $vscodeInstallerPath = "$env:TEMP\vscode-installer.exe"
    Invoke-WebRequest -Uri $vscodeInstallerUrl -OutFile $vscodeInstallerPath
    Start-Process -FilePath $vscodeInstallerPath -ArgumentList "/VERYSILENT /NORESTART" -Wait
    Remove-Item -Path $vscodeInstallerPath
    Write-Output "VSCode installation completed."
}

# Function to install VSCode extensions
function Install-VSCodeExtensions {
    $extensions = @(
        "apimatic-developers.apimatic-for-vscode",
        "ecmel.vscode-html-css",
        "esbenp.prettier-vscode",
        "file-icons.file-icons",
        "gruntfuggly.todo-tree",
        "humao.rest-client",
        "mechatroner.rainbow-csv",
        "ms-vscode-remote.remote-ssh",
        "ms-vscode-remote.remote-ssh-edit",
        "ms-vscode-remote.remote-wsl",
        "ms-vscode.remote-explorer",
        "ozgurkadir.cds-csv-generator",
        "qwtel.sqlite-viewer",
        "ritwickdey.liveserver",
        "sapos.yeoman-ui",
        "saposs.app-studio-remote-access",
        "saposs.app-studio-toolkit",
        "saposs.sap-guided-answers-extension",
        "saposs.vscode-ui5-language-assistant",
        "saposs.xml-toolkit",
        "sapse.sap-ux-annotation-modeler-extension",
        "sapse.sap-ux-application-modeler-extension",
        "sapse.sap-ux-fiori-tools-extension-pack",
        "sapse.sap-ux-help-extension",
        "sapse.sap-ux-service-modeler-extension",
        "sapse.vscode-cds",
        "sapse.vscode-wing-cds-editor-vsc",
        "zainchen.json"
    )

    foreach ($extension in $extensions) {
        Write-Output "Installing extension: $extension"
        code --install-extension $extension
    }
}

# Main script execution
if (-not (Check-VSCode)) {
    Install-VSCode
}

Install-VSCodeExtensions
