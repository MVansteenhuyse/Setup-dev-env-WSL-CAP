# Development Environment Setup Scripts

These scripts automate the setup of development tools required and used at Expertum by CAP (Cloud Application Programming) developers. This collection includes PowerShell and bash scripts designed to configure and install essential tools and applications. While this repository currently focuses on CAP development, a set of scripts for ABAP developers will be added in the future.

## Table of Contents

- [Usage](#usage)
- [PowerShell Scripts](#powershell-scripts)
- [Bash Scripts](#bash-scripts)
- [Contributing](#contributing)
- [License](#license)

## Usage

### PowerShell Scripts

To set up the development environment fully automated, update the config file if you want another version of linux, or node. Run the `main_setup.ps1` script:

```powershell
.\main_setup.ps1
```

### Bash Scripts

If you already have WSL installed, you can run the bash setup scripts independently. You can either use the `main_setup.sh` script with appropriate flags or run it without any flags for interactive mode. Additionally, you can run each subscript directly.

#### Running main_setup.sh with flags

```bash
chmod +x main_setup.sh
./main_setup.sh [options]
```

**Options:**

- `-nodev <version>`: Install a specified Node.js version.
- `-git <username> <email>`: Configure Git with the provided username and email.
- `-npm`: Install global npm packages.
- `-cf`: Install the CloudFoundry CLI and plugins.
- `-btp`: Install the BTP CLI.
- `-vscode`: Install Visual Studio Code and extensions.
- `-kubectl`: Install kubectl and plugins.
- `-helm`: Install Helm.
- `-docker`: Install Docker and Docker Compose.
- `-all <node_version>`: Run all setup scripts with the specified Node.js version.

## PowerShell Scripts

- `main_setup.ps1`: Main script to orchestrate the execution of other setup scripts.
- `setup_wsl_ubuntu.ps1`: Configure WSL with an Ubuntu distribution.
- `wsl_part1.ps1`: First part of WSL setup tasks.
- `wsl_part2.ps1`: Second part of WSL setup tasks.
- `install_vscode_and_extensions.ps1`: Install Visual Studio Code and extensions.
- `config.ps1`: Additional configuration tasks for the setup.

## Bash Scripts

- `main_setup.sh`: Main script to orchestrate the execution of other setup scripts.
- `setup_node_without_nvm.sh`: Install a specified version of Node.js without using NVM.
- `setup_git.sh`: Configure Git with user details and generate SSH keys.
- `setup_npm_packages.sh`: Install global npm packages.
- `setup_cloudfoundry.sh`: Install the CloudFoundry CLI and plugins.
- `setup_btp.sh`: Install the BTP CLI.
- `setup_vs_code.sh`: Install Visual Studio Code and extensions.
- `setup_kubectl.sh`: Install kubectl and plugins.
- `setup_helm.sh`: Install Helm.
- `setup_docker_and_compose.sh`: Install Docker and Docker Compose.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss changes.