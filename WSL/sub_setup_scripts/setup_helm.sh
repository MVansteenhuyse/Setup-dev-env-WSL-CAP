#!/bin/bash
# FLAGS: -helm
# PARAMS: 

set -euo pipefail

# Ensure script isn't run as root
ensure_not_root() {
    if [ "$EUID" -eq 0 ]; then
        echo "This script should not be run as root or with sudo."
        exit 1
    fi
}

# Function to install Helm
install_helm() {
    if command -v helm &> /dev/null; then
        echo "Helm is already installed."
    else
        echo "Installing Helm..."
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 get_helm.sh
        ./get_helm.sh
        rm get_helm.sh

        # Verify installation
        if ! helm version; then
            echo "Helm installation failed"
            exit 1
        fi
    fi
}

# Main script execution
main() {
    ensure_not_root
    install_helm
    echo "Helm setup complete!"
}

main "$@"
