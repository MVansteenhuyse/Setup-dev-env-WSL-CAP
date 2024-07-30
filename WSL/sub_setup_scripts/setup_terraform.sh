#!/bin/bash
# FLAGS: -terraform
# PARAMS: 

set -euo pipefail

# Ensure script isn't run as root
ensure_not_root() {
    if [ "$EUID" -eq 0 ]; then
        echo "This script should not be run as root or with sudo."
        exit 1
    fi
}

# Function to check if a command exists and install it if not
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 could not be found, installing..."
        sudo apt-get install -y "$1"
    fi
}

# Function to install Terraform
install_terraform() {
    if command -v terraform &> /dev/null; then
        echo "Terraform is already installed."
    else
        echo "Installing Terraform..."
        
        # Update system and install required packages
        sudo apt-get update
        sudo apt-get install -y gnupg software-properties-common curl
        
        # Install HashiCorp GPG key
        wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
        
        # Verify the key's fingerprint
        gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint
        
        # Add HashiCorp repository
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
        
        # Update package information
        sudo apt-get update
        
        # Install Terraform
        sudo apt-get install -y terraform
        
        # Verify installation
        if ! terraform --version; then
            echo "Terraform installation failed"
            exit 1
        fi
    fi
}

# Main script execution
main() {
    ensure_not_root
    check_command wget
    install_terraform
    echo "Terraform setup complete!"
}

main "$@"