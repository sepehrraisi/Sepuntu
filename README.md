# Sepuntu

Sepuntu is a script designed to set up Ubuntu with preferred configurations and tools. It automates the installation of essential packages, user creation, and configuration of the Zsh shell with Oh My Zsh and Powerlevel10k theme.

## Features

- Creates a user named `sepehr` with sudo privileges.
- Installs essential packages like `zsh` and `git`.
- Sets up Oh My Zsh with plugins and Powerlevel10k theme.
- Configures `.zshrc` and `.p10k.zsh` for a customized shell experience.

## Prerequisites

- Ubuntu operating system.
- Internet connection for downloading scripts and packages.

## Installation

To run the setup script, open your terminal and execute the following command:
sh -c "$(curl -fsSL https://raw.githubusercontent.com/sepehrraisi/sepuntu/main/sepehr.sh)"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/sepehrraisi/sepuntu/main/DjPub.sh)"

## Script Details

### User Setup

- The script checks if it is run as root. If not, it prompts the user to run it with sudo.
- It creates a user named `sepehr` or updates the password if the user already exists.
- Adds the user to the sudo group and configures passwordless sudo access.

### Package Installation

- Updates package lists and installs `zsh` and `git`.
- Uses a function `install_package` to handle package installations.

### Zsh and Oh My Zsh Configuration

- Installs Oh My Zsh for the `sepehr` user.
- Clones `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins.
- Clones the `powerlevel10k` theme.
- Downloads and updates `.zshrc` and `.p10k.zsh` configuration files.

### Permissions

- Ensures correct ownership and permissions for the `.p10k.zsh` file.

## Additional Scripts

### Django_publish.sh

- Checks and installs `nginx` if not already installed.
- Updates package lists and installs Python 3.12 if not installed.

## Configuration Files

- `.p10k.zsh`: Configuration for Powerlevel10k theme.
- `.zshrc`: Configuration for Zsh shell with Oh My Zsh.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

