#!/bin/bash
# FLAGS: -docker
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

# Function to install Docker
install_docker() {
    if command -v docker &> /dev/null; then
        echo "Docker is already installed."
    else
        echo "Installing Docker..."
        sudo apt-get update
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common

        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"

        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io

        # Verify installation
        if ! docker --version; then
            echo "Docker installation failed"
            exit 1
        fi
    fi
}

# Function to install Docker Compose
install_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        echo "Docker Compose is already installed."
    else
        echo "Installing Docker Compose..."
        DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
        sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        # Verify installation
        if ! docker-compose --version; then
            echo "Docker Compose installation failed"
            exit 1
        fi
    fi
}

# Main script execution
main() {
    ensure_not_root
    check_command curl
    check_command jq
    install_docker
    install_docker_compose
    echo "Docker and Docker Compose setup complete!"
}

main "$@"
