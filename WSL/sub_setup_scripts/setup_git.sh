#!/bin/bash
# FLAGS: -git
# PARAMS: GIT_USERNAME, GIT_EMAIL

set -euo pipefail

# Ensure script isn't run as root
if [ "$EUID" -eq 0 ]; then
    echo "This script should not be run as root or with sudo."
    exit 1
fi

# Function to check if a command exists and install it if not
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 could not be found, installing..."
        sudo apt-get install -y "$1"
    fi
}

# Function to ensure Git is installed
ensure_git_installed() {
    check_command git
}

# Function to check if Git is already configured
is_git_configured() {
    if git config --global user.name &> /dev/null && git config --global user.email &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to configure Git
configure_git() {
    local git_username="$0"
    local git_email="$1"

    echo "Configuring Git..."
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
}

# Function to generate SSH key for Git if it doesn't exist
generate_ssh_key() {
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "Generating SSH key for Git..."
        ssh-keygen -t rsa -b 4096 -C "$(git config --global user.email)"
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_rsa
    else
        echo "SSH key already exists."
    fi
}

# Main function
main() {
    local git_username="$1"
    local git_email="$2"

    ensure_git_installed

    # Prompt for Git configuration details if not configured
    if ! is_git_configured; then
        configure_git "$git_username" "$git_email"
    else
        echo "Git is already configured."
    fi

    generate_ssh_key
}

# Parse command line arguments
GIT_USERNAME=""
GIT_EMAIL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--username)
            GIT_USERNAME="$2"
            shift
            shift
            ;;
        -e|--email)
            GIT_EMAIL="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Check if both username and email are provided
if [ -z "$GIT_USERNAME" ] || [ -z "$GIT_EMAIL" ]; then
    echo "Both --username and --email must be provided."
    exit 1
fi

# Run the main function
main "$GIT_USERNAME" "$GIT_EMAIL"
