#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

echo "Starting: Update package lists"
# Update package lists
apt update
echo "Finished: Update package lists"

# Prompt for the password for the new user
read -sp "Enter password for new user 'sepehr': " password
echo

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

echo "Starting: Switch to the user 'sepehr'"
# Switch to the user 'sepehr'
su - sepehr
echo "Finished: Switch to the user 'sepehr'"

echo "Starting: Install zsh"
# Install zsh
apt install -y zsh
echo "Finished: Install zsh"

echo "Starting: Install git"
# Install git
apt install -y git
echo "Finished: Install git"

echo "Starting: Install Oh My Zsh"
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Finished: Install Oh My Zsh"

echo "Starting: Clone zsh-autosuggestions plugin"
# Clone zsh-autosuggestions plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
echo "Finished: Clone zsh-autosuggestions plugin"

echo "Starting: Clone zsh-syntax-highlighting plugin"
# Clone zsh-syntax-highlighting plugin
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "Finished: Clone zsh-syntax-highlighting plugin"

echo "Starting: Clone powerlevel10k theme"
# Clone powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo "Finished: Clone powerlevel10k theme"

echo "Starting: Update .zshrc to include the new plugins"
# Update .zshrc to include the new plugins
sed -i '/^plugins=(git/ c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' /home/sepehr/.zshrc
echo "Finished: Update .zshrc to include the new plugins"

echo "Starting: Update .zshrc to set the ZSH_THEME to powerlevel10k"
# Update .zshrc to set the ZSH_THEME to powerlevel10k
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /home/sepehr/.zshrc
echo "Finished: Update .zshrc to set the ZSH_THEME to powerlevel10k"

echo "Starting: Copy and replace the .p10k.zsh file"
# Copy and replace the .p10k.zsh file
wget -O /home/sepehr/.p10k.zsh https://raw.githubusercontent.com/sepehrraisi/sepuntu/main/.p10k.zsh

echo "Starting: Ensure the correct ownership and permissions"
# Ensure the correct ownership and permissions
chown sepehr:sepehr /home/sepehr/.p10k.zsh
chmod 644 /home/sepehr/.p10k.zsh
echo "Finished: Ensure the correct ownership and permissions"

echo "Summary: Installed zsh, git, Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting, and powerlevel10k theme. Updated .zshrc and .p10k.zsh, and set correct ownership and permissions."