#!/bin/bash
# FLAGS: -nodev
# PARAMS: NODE_VERSION

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

# Ensure fzf and jq are installed
check_command fzf
check_command jq

# Function to sort versions in descending order
sort_versions() {
    if [ -z "${1:-}" ]; then
        echo "No versions provided to sort."
        exit 1
    fi
    echo "$1" | tr ' ' '\n' | sort -rV
}

# Fetch available Node.js versions
fetch_node_versions() {
    local versions
    versions=$(curl -s https://nodejs.org/dist/index.json)
    if [ -z "$versions" ]; then
        echo "Failed to fetch Node.js versions."
        exit 1
    fi
    # Check if the fetched data is JSON
    if ! echo "$versions" | jq empty > /dev/null 2>&1; then
        echo "Fetched data is not valid JSON."
        exit 1
    fi
    echo "$versions"
}

# Extract and sort LTS versions
extract_lts_versions() {
    local node_versions="$1"
    local lts_versions
    lts_versions=$(echo "$node_versions" | jq -r '.[] | select(.lts != false) | .version')
    if [ -z "$lts_versions" ]; then
        echo "No LTS versions found."
        exit 1
    fi
    sort_versions "$lts_versions" | head -n 3
}

# Extract and sort non-LTS versions
extract_non_lts_versions() {
    local node_versions="$1"
    local non_lts_versions
    non_lts_versions=$(echo "$node_versions" | jq -r '.[] | select(.lts == false) | .version')
    if [ -z "$non_lts_versions" ]; then
        echo "No non-LTS versions found."
        exit 1
    fi
    sort_versions "$non_lts_versions" | head -n 3
}

# Combine LTS and non-LTS versions
combine_versions() {
    local lts_versions="$1"
    local non_lts_versions="$2"
    echo -e "LTS versions:\n$lts_versions\nNon-LTS versions:\n$non_lts_versions"
}

# Prompt user to select a Node.js version
prompt_node_version() {
    local all_versions="$1"
    echo "Available Node.js versions (LTS and latest 3 non-LTS):"
    echo -e "$all_versions" | fzf --header="Select the Node.js version you want to install:"
}

# Main script execution
main() {
    local specified_version="${1:-}"

    if [ -n "$specified_version" ]; then
        node_version="$specified_version"
    else
        local node_versions
        local lts_versions
        local non_lts_versions
        local all_versions
        local selected_version

        node_versions=$(fetch_node_versions)
        lts_versions=$(extract_lts_versions "$node_versions")
        non_lts_versions=$(extract_non_lts_versions "$node_versions")
        all_versions=$(combine_versions "$lts_versions" "$non_lts_versions")
        selected_version=$(prompt_node_version "$all_versions")
        node_version=$(echo "$selected_version" | grep -oP 'v[\d\.]+')
    fi

    if [ -z "$node_version" ]; then
        echo "No valid Node.js version selected."
        exit 1
    fi

    # Check if the selected Node.js version is already installed
    if [ -d "/opt/node-$node_version-linux-x64" ]; then
        echo "Node.js $node_version is already installed."
        return
    fi

    # Install selected Node.js version
    echo "Installing Node.js $node_version..."
    local node_url="https://nodejs.org/dist/$node_version/node-$node_version-linux-x64.tar.xz"

    # Use temporary directory for downloading and extracting
    local temp_dir
    temp_dir=$(mktemp -d)
    trap 'rm -rf -- "$temp_dir"' EXIT

    wget -O "$temp_dir/node.tar.xz" "$node_url"
    sudo tar -vJxf "$temp_dir/node.tar.xz" -C /opt/

    local node_dir="/opt/node-$node_version-linux-x64/bin"

    # Add Node.js to PATH if not already added
    if ! grep -Fxq "export PATH=\$PATH:$node_dir" ~/.bashrc; then
        echo "export PATH=\$PATH:$node_dir" >> ~/.bashrc
        echo "Node.js $node_version installed successfully. Please run 'source ~/.bashrc' or open a new terminal to update your PATH."
    else
        echo "Path variable already exists, no need to re-add."
    fi
}

# Parse command line arguments
while getopts "v:" opt; do
    case $opt in
        v) NODE_VERSION="$OPTARG" ;;
        \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    esac
done

# Run the main function with the specified version, if provided
main "${NODE_VERSION:-}"
