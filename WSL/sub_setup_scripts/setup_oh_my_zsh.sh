#!/bin/bash
# FLAGS: -zsh
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

# Function to install zsh
install_zsh() {
    if command -v zsh &> /dev/null; then
        echo "zsh is already installed."
    else
        echo "Installing zsh..."
        sudo apt-get update
        sudo apt-get install -y zsh

        # Set zsh as default shell
        chsh -s "$(command -v zsh)"

        # Verify installation
        if ! command -v zsh; then
            echo "zsh installation failed"
            exit 1
        fi
    fi
}

# Function to install oh-my-zsh
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh is already installed."
    else
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

        # Verify installation
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            echo "Oh My Zsh installation failed"
        fi
    fi
}

# Main script execution
main() {
    check_command curl
    install_zsh
    install_oh_my_zsh
    echo "zsh and Oh My Zsh setup complete!"
}

main "$@"
