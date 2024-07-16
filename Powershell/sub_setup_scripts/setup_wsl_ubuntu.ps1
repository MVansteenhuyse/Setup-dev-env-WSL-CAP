# Path to witness file
$witnessFile = "C:\Witness\setup_wsl_ubuntu.txt"

# Check if the script has already run
if (Test-Path $witnessFile) {
    Write-Output "setup_wsl_ubuntu.ps1 has already been executed."
    exit
}

# Load configuration
Write-Output "Loading configuration..."
$config = ".\config.ps1"

. $config


# Install necessary packages
Write-Output "Installing necessary packages..."
wsl sudo apt-get update
wsl sudo apt-get install -y sudo

# Create a new user
Write-Output "Creating a new user..."
wsl sudo useradd -m -s /bin/bash $userName

# Set the user's password
Write-Output "Setting the user's password..."
wsl bash -c "echo '${userName}:${password}' | sudo chpasswd"

# Add the new user to the sudoers file
Write-Output "Adding the user to the sudoers file..."
wsl sudo usermod -aG sudo $userName

# Ensure the new user can run sudo commands without a password
wsl bash -c "echo '${userName} ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers"

# Change the ownership of the home directory to the new user
Write-Output "Changing the ownership of the home directory..."
wsl sudo chown -R ${userName}:${userName} /home/$userName

# Ensure main_setup.sh is present in the home directory
Write-Output "Copying main_setup.sh to the new user's home directory..."
wsl sudo cp -r ../../WSL /home/$userName/
wsl sudo chmod +x /home/$userName/WSL/main_setup.sh

# Find the path to 1password CLI
$pathTo1PassWindows = where.exe op.exe

# Convert the Windows path to a WSL-compatible path
$pathTo1PassWSL = $pathTo1PassWindows -replace '\\', '/' -replace 'C:', '/mnt/c'

# Construct the alias command
$aliasCommand = "alias op=\"$pathTo1PassWSL\""

# Run the command in WSL to add the alias to ~/.bashrc
wsl bash -c "echo '$aliasCommand' >> ~/.bashrc"

Write-Output "Alias for 1password CLI added to ~/.bashrc in WSL"

# Switch to the new user and run the main setup script with parameters
Write-Output "Switching to the new user and running the main setup script..."
wsl sudo -u $userName bash -c "/home/$userName/WSL/main_setup.sh -all $nodeVersion"

Write-Output "Setup complete!"

New-Item -ItemType File -Path $witnessFile
