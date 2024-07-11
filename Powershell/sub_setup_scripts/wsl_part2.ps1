# Load config
. ..\config.ps1

# Remove the scheduled task to avoid running this script again on the next startup
$taskName = "FinishWSLSetup"
schtasks /delete /tn $taskName /f

# Set WSL 2 as the default version
wsl --set-default-version 2

# Install Ubuntu
wsl --install -d $linuxDistro

# Update system and setup user
.\setup_wsl_ubuntu.ps1