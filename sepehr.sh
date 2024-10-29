#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    log "Please run this script as root or with sudo."
    exit 1
fi

# Prompt for the password for the user 'sepehr'
read -sp "Enter password for user 'sepehr': " password
echo

# Check if the user 'sepehr' already exists
if id "sepehr" &>/dev/null; then
    log "User 'sepehr' already exists. Setting new password."
    echo "sepehr:$password" | chpasswd
else
    log "Creating user 'sepehr'."
    useradd -m -s /bin/bash sepehr
    echo "sepehr:$password" | chpasswd
    usermod -aG sudo sepehr
    echo "sepehr ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/sepehr
fi

# Function to install packages
install_package() {
    log "Installing $1"
    apt-get install -y "$1"
}

# Update package lists
log "Updating package lists"
apt-get update

# Install necessary packages
install_package zsh
install_package git

# Function to run commands as 'sepehr'
run_as_sepehr() {
    su - sepehr -c "$1"
}

# Install Oh My Zsh and plugins
log "Installing Oh My Zsh"
run_as_sepehr 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'

log "Cloning zsh-autosuggestions plugin"
run_as_sepehr 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'

log "Cloning zsh-syntax-highlighting plugin"
run_as_sepehr 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

log "Cloning powerlevel10k theme"
run_as_sepehr 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'

# Update .zshrc and .p10k.zsh
log "Updating .zshrc"
run_as_sepehr 'wget -O ~/.zshrc https://raw.githubusercontent.com/sepehrraisi/sepuntu/main/.zshrc'

log "Updating .p10k.zsh"
run_as_sepehr 'wget -O ~/.p10k.zsh https://raw.githubusercontent.com/sepehrraisi/sepuntu/main/.p10k.zsh'

# Ensure correct ownership and permissions
log "Setting ownership and permissions for .p10k.zsh"
chown sepehr:sepehr /home/sepehr/.p10k.zsh
chmod 644 /home/sepehr/.p10k.zsh

log "Summary: Installed zsh, git, Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting, and powerlevel10k theme. Updated .zshrc and .p10k.zsh, and set correct ownership and permissions."