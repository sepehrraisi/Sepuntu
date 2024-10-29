#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Prompt for the password for the user 'sepehr'
read -sp "Enter password for user 'sepehr': " password
echo

# Check if the user 'sepehr' already exists
if id "sepehr" &>/dev/null; then
    echo "User 'sepehr' already exists."
    echo "Starting: Set the new password for 'sepehr'"
    # Set the new password for 'sepehr'
    echo "sepehr:$password" | chpasswd
    echo "Finished: Set the new password for 'sepehr'"
else
    echo "Starting: Create the user 'sepehr'"
    # Create the user 'sepehr'
    useradd -m -s /bin/bash sepehr
    echo "Finished: Create the user 'sepehr'"

    echo "Starting: Set the password for 'sepehr'"
    # Set the password for 'sepehr'
    echo "sepehr:$password" | chpasswd
    echo "Finished: Set the password for 'sepehr'"

    echo "Starting: Add 'sepehr' to the sudo group"
    # Add 'sepehr' to the sudo group
    usermod -aG sudo sepehr
    echo "Finished: Add 'sepehr' to the sudo group"

    echo "Starting: Configure sudoers to allow 'sepehr' to run sudo without a password"
    # Configure sudoers to allow 'sepehr' to run sudo without a password
    echo "sepehr ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/sepehr
    echo "Finished: Configure sudoers to allow 'sepehr' to run sudo without a password"
fi

echo "Starting: Update package lists"
# Update package lists
apt-get update
echo "Finished: Update package lists"

echo "Starting: Install zsh"
# Install zsh
apt-get install -y zsh
echo "Finished: Install zsh"

echo "Starting: Install git"
# Install git
apt-get install -y git
echo "Finished: Install git"

echo "Starting: Install Oh My Zsh"
# Install Oh My Zsh
su - sepehr -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
echo "Finished: Install Oh My Zsh"

echo "Starting: Clone zsh-autosuggestions plugin"
# Clone zsh-autosuggestions plugin
su - sepehr -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
echo "Finished: Clone zsh-autosuggestions plugin"

echo "Starting: Clone zsh-syntax-highlighting plugin"
# Clone zsh-syntax-highlighting plugin
su - sepehr -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
echo "Finished: Clone zsh-syntax-highlighting plugin"

echo "Starting: Clone powerlevel10k theme"
# Clone powerlevel10k theme
su - sepehr -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'
echo "Finished: Clone powerlevel10k theme"

echo "Starting: Update .zshrc to include the new plugins"
# Update .zshrc to include the new plugins
su - sepehr -c 'wget -O ~/.zshrc https://raw.githubusercontent.com/sepehrraisi/sepuntu/main/.zshrc'
echo "Finished: Update .zshrc to set the ZSH_THEME to powerlevel10k"

echo "Starting: Copy and replace the .p10k.zsh file"
# Copy and replace the .p10k.zsh file
su - sepehr -c 'wget -O ~/.p10k.zsh https://raw.githubusercontent.com/sepehrraisi/sepuntu/main/.p10k.zsh'

echo "Starting: Ensure the correct ownership and permissions"
# Ensure the correct ownership and permissions
chown sepehr:sepehr /home/sepehr/.p10k.zsh
chmod 644 /home/sepehr/.p10k.zsh
echo "Finished: Ensure the correct ownership and permissions"

echo "Summary: Installed zsh, git, Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting, and powerlevel10k theme. Updated .zshrc and .p10k.zsh, and set correct ownership and permissions."