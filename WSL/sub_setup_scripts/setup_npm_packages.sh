#!/bin/bash
# FLAGS: -npm
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

# Ensure npm is installed
check_command npm
check_command make

# Function to install npm packages with error handling
install_npm_package() {
    if npm list -g --depth=0 "$1" &> /dev/null; then
        echo "$1 is already installed globally."
    else
        if ! npm install -g "$1"; then
            echo "Failed to install $1"
            exit 1
        fi
    fi
}

# Install UI5 Tooling and other CLI tools
echo "Installing UI5 Tooling and other CLI tools..."
install_npm_package "@ui5/cli@latest"
install_npm_package "yo"
install_npm_package "generator-easy-ui5"
install_npm_package "@sap/cds-dk"
install_npm_package "hana-cli"
install_npm_package "expressui5"
install_npm_package "@ui5/linter"
install_npm_package "mbt"

# Verify installations
echo "Verifying installations..."
ui5 --version
cds --version
hana-cli version
yo --version
mbt --version
