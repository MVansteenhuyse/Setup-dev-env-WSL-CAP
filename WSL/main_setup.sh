#!/bin/bash

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

# Ensure necessary tools are installed
install_necessary_tools() {
    check_command wget
    check_command git
    check_command tar
    check_command xz-utils
    check_command nano
    check_command curl
    check_command jq
    check_command fzf
}

# Function to run a setup script
run_script() {
    local script_name="$1"
    local node_version="${2:-}"
    local git_username="${3:-}"
    local git_email="${4:-}"

    echo "Running $script_name..."
    if [ "$script_name" == "setup_node_without_nvm.sh" ]; then
        source "./sub_setup_scripts/$script_name" -v "$node_version"
    elif [ "$script_name" == "setup_git.sh" ]; then
        source "./sub_setup_scripts/$script_name" -u "$git_username" -e "$git_email"
    else
        source "./sub_setup_scripts/$script_name"
    fi
    echo "----------------------Running the next script----------------------------------"
}

# Function to handle command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -nodev)
                NODE_VERSION="$2"
                RUN_NODE=true
                shift
                shift
                ;;
            -git)
                RUN_GIT=true
                GIT_USERNAME="$2"
                GIT_EMAIL="$3"
                shift
                shift
                shift
                ;;
            -npm)
                RUN_NPM=true
                shift
                ;;
            -cf)
                RUN_CF=true
                shift
                ;;
            -btp)
                RUN_BTP=true
                shift
                ;;
            -vscode)
                RUN_VSCODE=true
                shift
                ;;
            -kubectl)
                RUN_KUBECTL=true
                shift
                ;;
            -helm)
                RUN_HELM=true
                shift
                ;;
            -docker)
                RUN_DOCKER=true
                shift
                ;;
            -terraform)
                RUN_TERRAFORM=true
                shift
                ;;
            -all)
                RUN_ALL=true
                NODE_VERSION="$2"
                shift
                shift
                ;;
            *)
                echo "Unknown option $1"
                exit 1
                ;;
        esac
    done
}

# Function to run selected scripts based on flags
run_selected_scripts() {
    local any_flag_set=false

    if [ "$RUN_ALL" = true ]; then
        any_flag_set=true
        run_script "setup_node_without_nvm.sh" "$NODE_VERSION"
        run_script "setup_npm_packages.sh"
        run_script "setup_cloudfoundry.sh"
        run_script "setup_btp.sh"
        run_script "setup_vs_code.sh"
        run_script "setup_kubectl.sh"
        run_script "setup_helm.sh"
        run_script "setup_docker_and_compose.sh"
        run_script "setup_terraform.sh"
    else
        [ "$RUN_NODE" = true ] && { any_flag_set=true; run_script "setup_node_without_nvm.sh" "$NODE_VERSION"; }
        [ "$RUN_GIT" = true ] && { any_flag_set=true; run_script "setup_git.sh" "" "$GIT_USERNAME" "$GIT_EMAIL"; }
        [ "$RUN_NPM" = true ] && { any_flag_set=true; run_script "setup_npm_packages.sh"; }
        [ "$RUN_CF" = true ] && { any_flag_set=true; run_script "setup_cloudfoundry.sh"; }
        [ "$RUN_BTP" = true ] && { any_flag_set=true; run_script "setup_btp.sh"; }
        [ "$RUN_VSCODE" = true ] && { any_flag_set=true; run_script "setup_vs_code.sh"; }
        [ "$RUN_KUBECTL" = true ] && { any_flag_set=true; run_script "setup_kubectl.sh"; }
        [ "$RUN_HELM" = true ] && { any_flag_set=true; run_script "setup_helm.sh"; }
        [ "$RUN_DOCKER" = true ] && { any_flag_set=true; run_script "setup_docker_and_compose.sh"; }
        [ "$RUN_TERRAFORM" = true ] && { any_flag_set=true; run_script "setup_terraform.sh"; }
    fi

    # If no flags were set and RUN_ALL is not true, prompt the user to select scripts
    if [ "$any_flag_set" = false ]; then
        prompt_user_to_select_scripts
    fi
}

# Function to prompt the user to select scripts if no flags are set
prompt_user_to_select_scripts() {
    SELECTED_SCRIPTS=$(printf "%s\n" "${SCRIPTS[@]}" | fzf --multi --header="Select the setup scripts you want to run (Select with tab):")

    if [ -z "$SELECTED_SCRIPTS" ]; then
        echo "No setup scripts selected. Exiting."
        exit 1
    fi

    for SCRIPT in $SELECTED_SCRIPTS; do
        echo "Running $SCRIPT..."
        if [ "$SCRIPT" == "setup_node_without_nvm.sh" ]; then
            read -p "Enter the Node.js version you want to install (or leave blank to select interactively): " NODE_VERSION
            if [ -n "$NODE_VERSION" ]; then
                run_script "$SCRIPT" "$NODE_VERSION"
            else
                run_script "$SCRIPT"
            fi
        elif [ "$SCRIPT" == "setup_git.sh" ]; then
            read -p "Enter your Git username: " GIT_USERNAME
            read -p "Enter your Git email: " GIT_EMAIL
            run_script "$SCRIPT" "" "$GIT_USERNAME" "$GIT_EMAIL"
        else
            run_script "$SCRIPT"
        fi
    done
}

# Main function
main() {
    install_necessary_tools
    parse_arguments "$@"
    run_selected_scripts
    source ~/.bashrc
    echo "Setup complete! Make sure to start a new terminal session; Or source your bashrc file: source ~/.bashrc!"
}

# Default values
NODE_VERSION=""
GIT_USERNAME=""
GIT_EMAIL=""
RUN_ALL=false
RUN_GIT=false
RUN_NODE=false
RUN_NPM=false
RUN_CF=false
RUN_BTP=false
RUN_VSCODE=false
RUN_KUBECTL=false
RUN_HELM=false
RUN_DOCKER=false
RUN_TERRAFORM=false

# List of setup scripts and their corresponding flags
SCRIPTS=("setup_git.sh" "setup_cloudfoundry.sh" "setup_btp.sh" "setup_node_without_nvm.sh" "setup_npm_packages.sh" "setup_vs_code.sh" "setup_kubectl.sh", "setup_helm.sh", "setup_docker_and_compose.sh" "setup_terraform.sh")

# Run the main function
main "$@"
