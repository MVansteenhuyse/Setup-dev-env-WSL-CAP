#!/bin/bash
# FLAGS: -cf
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

# Ensure wget is installed
check_command wget

# Install CloudFoundry CLI if not already installed
if command -v cf &> /dev/null; then
    echo "CloudFoundry CLI is already installed."
else
    echo "Installing CloudFoundry CLI..."
    wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
    echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
    sudo apt-get update

    if ! sudo apt-get install -y cf8-cli; then
        echo "Failed to install CloudFoundry CLI"
        exit 1
    fi

    # Verify installation
    if ! cf --version; then
        echo "CloudFoundry CLI installation failed"
        exit 1
    fi
fi

# Install CF MTA plugin if not already installed
if cf plugins | grep -q "multiapps"; then
    echo "CF MTA plugin is already installed."
else
    echo "Installing CF MTA plugin..."
    echo "y" | cf install-plugin multiapps

    # Verify installation
    if ! cf plugins | grep -q "multiapps"; then
        echo "CF MTA plugin installation failed"
        exit 1
    fi
fi

# Install CF service push plugin if not already installed
if cf plugins | grep -q "Create-Service-Push"; then
    echo "CF create-service-push plugin is already installed."
else
    echo "Installing CF create-service-push plugin..."
    echo "y" | cf install-plugin Create-Service-Push

    # Verify installation
    if ! cf plugins | grep -q "Create-Service-Push"; then
        echo "CF create-service-push plugin installation failed"
        exit 1
    fi
fi

echo "CloudFoundry CLI and CF plugins setup complete!"

