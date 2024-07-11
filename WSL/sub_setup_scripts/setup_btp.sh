#!/bin/bash
# FLAGS: -btp
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

# Ensure curl is installed
check_command curl

# Install BTP CLI if not already installed
if command -v /opt/linux-amd64/btp &> /dev/null; then
    echo "BTP CLI is already installed."
else
    echo "Installing BTP CLI..."
    BTP_CLI_URL=$(curl -s https://tools.hana.ondemand.com/#cloud-btpcli | grep -oP 'additional/btp-cli-linux-amd64-[\d\.]+.tar.gz' | head -n 1)
    if [ -z "$BTP_CLI_URL" ]; then
        echo "Failed to fetch BTP CLI URL."
        exit 1
    fi

    # Use temporary directory for downloading and extracting
    temp_dir=$(mktemp -d)
    trap 'rm -rf -- "$temp_dir"' EXIT

    curl -L -o "$temp_dir/btp-cli.tar.gz" --cookie "eula_3_2_agreed=tools.hana.ondemand.com/developer-license-3_2.txt" "https://tools.hana.ondemand.com/$BTP_CLI_URL"
    sudo tar -vzxf "$temp_dir/btp-cli.tar.gz" -C /opt/

    # Add BTP CLI to PATH if not already added
    if ! grep -Fxq "export PATH=\$PATH:/opt/linux-amd64" ~/.bashrc; then
        echo 'export PATH=$PATH:/opt/linux-amd64' >> ~/.bashrc
        echo "BTP CLI installed successfully. Please run 'source ~/.bashrc' or open a new terminal to update your PATH."
    else 
        echo 'Path variable already exists, no need to re-add.'
    fi

    # Verify if the installation was successful
    if /opt/linux-amd64/btp --version; then
        echo "BTP CLI installed successfully."
    else
        echo "BTP CLI installation failed."
        exit 1
    fi
fi
