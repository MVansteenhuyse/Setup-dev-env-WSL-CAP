#!/bin/bash
# FLAGS: -vscode
# PARAMS: 

set -euo pipefail

# Ensure script isn't run as root
if [ "$EUID" -eq 0 ]; then
    echo "This script should not be run as root or with sudo."
    exit 1
fi

# Function to check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 could not be found, installing..."
        sudo apt-get install -y "$1"
    fi
}

# Ensure wget and apt-transport-https are installed
check_command wget
check_command apt-transport-https

# Function to install VS Code
install_vscode() {
    if ! command -v code &> /dev/null; then
        echo "VS Code not found. Installing the latest version..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt-get update
        sudo apt-get install -y code
        rm -f packages.microsoft.gpg
    fi
}

# Function to install openvscodeserver
install_openvscodeserver() {
    if ! command -v openvscodeserver &> /dev/null; then
        echo "openvscodeserver not found. Installing the latest version..."
        wget -qO- https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v1.91.0/openvscode-server-v1.91.0-linux-x64.tar.gz | tar -xz -C /tmp/
        sudo mv /tmp/openvscode-server-v1.91.0-linux-x64 /usr/local/bin/
        sudo ln -sf /usr/local/bin/openvscode-server/openvscodeserver /usr/local/bin/openvscodeserver
    fi
}

# Install VS Code
install_vscode

# Install openvscodeserver
install_openvscodeserver

# List of VS Code extensions to install
EXTENSIONS=(
    "apimatic-developers.apimatic-for-vscode"
    "ecmel.vscode-html-css"
    "esbenp.prettier-vscode"
    "file-icons.file-icons"
    "gruntfuggly.todo-tree"
    "humao.rest-client"
    "joaompinto.vscode-graphviz"
    "mechatroner.rainbow-csv"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode.remote-explorer"
    "ms-vscode-remote.remote-wsl"
    "ozgurkadir.cds-csv-generator"
    "qwtel.sqlite-viewer"
    "ritwickdey.liveserver"
    "sapos.yeoman-ui"
    "saposs.app-studio-remote-access"
    "saposs.app-studio-toolkit"
    "saposs.sap-guided-answers-extension"
    "saposs.vscode-ui5-language-assistant"
    "saposs.xml-toolkit"
    "sapse.sap-ux-annotation-modeler-extension"
    "sapse.sap-ux-application-modeler-extension"
    "sapse.sap-ux-fiori-tools-extension-pack"
    "sapse.sap-ux-help-extension"
    "sapse.sap-ux-service-modeler-extension"
    "sapse.vscode-cds"
    "sapse.vscode-wing-cds-editor-vsc"
    "zainchen.json"
)

# Function to check if an extension is installed
is_extension_installed() {
    code --list-extensions | grep -q "$1"
}

# Install the extensions if not already installed
for extension in "${EXTENSIONS[@]}"; do
    if is_extension_installed "$extension"; then
        echo "VS Code extension $extension is already installed."
    else
        echo "Installing VS Code extension: $extension"
        if code --install-extension "$extension"; then
            echo "Successfully installed $extension"
        else
            echo "Failed to install $extension" >&2
        fi
    fi
done

echo "VS Code and openvscodeserver setup complete!"
