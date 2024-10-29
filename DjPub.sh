#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Prompt for the GitHub link of the project
log "Enter the GitHub link of the project:"
read github_link

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    log "Please run this script as root or with sudo."
    exit 1
fi

# Function to check and install a package if not installed
check_and_install() {
    local package=$1
    local install_cmd=$2
    if ! dpkg -l | grep -q "$package"; then
        log "$package is not installed. Installing $package..."
        eval "$install_cmd"
    else
        log "$package is already installed."
    fi
}

# Update package lists
log "Updating package lists"
sudo apt-get update

# Check and install nginx
check_and_install "nginx" "sudo apt-get install -y nginx"

# Check and install Python 3.12
check_and_install "python3.12" "sudo add-apt-repository -y ppa:deadsnakes/ppa && sudo apt-get update && sudo apt-get install -y python3.12"

# Open nginx ports
log "Opening nginx ports 80 and 443"
sudo ufw allow 'Nginx Full'
sudo ufw reload


