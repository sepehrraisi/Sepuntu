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

# Function to create PostgreSQL user and database
create_postgres_db() {
    local project_name=$1
    local db_name="${project_name}_db"
    local db_user="${project_name}_user"
    local db_password=$(openssl rand -base64 12)

    log "Creating PostgreSQL user and database"
    # Change to a directory accessible by the postgres user
    cd /tmp
    sudo -u postgres psql <<EOF
CREATE USER $db_user WITH PASSWORD '$db_password';
CREATE DATABASE $db_name;
GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;
EOF

    # Store the database credentials in the home directory
    store_db_credentials "$project_name" "$db_name" "$db_user" "$db_password"
}

# Function to store database credentials
store_db_credentials() {
    local project_name=$1
    local db_name=$2
    local db_user=$3
    local db_password=$4

    # Check if SUDO_USER is set, otherwise default to the current user
    local user_home
    if [ -n "$SUDO_USER" ]; then
        user_home=$(eval echo "~$SUDO_USER")
    else
        user_home="/home/sepehr"
    fi

    local credentials_file="$user_home/${project_name}_credentials.txt"
    log "Storing database credentials in $credentials_file"
    {
        echo "Database Name: $db_name"
        echo "Database User: $db_user"
        echo "Database Password: $db_password"
    } > "$credentials_file"
}

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

# Function to start and enable a service
start_and_enable_service() {
    local service=$1
    log "Starting and enabling $service service"
    sudo systemctl enable --now "$service"
}

# Check if required packages are installed
required_packages=("nginx" "python3.12" "postgresql")
missing_packages=()

for package in "${required_packages[@]}"; do
    if ! dpkg -l | grep -q "$package"; then
        missing_packages+=("$package")
    fi
done

# If any packages are missing, prompt the user to install them
if [ ${#missing_packages[@]} -ne 0 ]; then
    log "The following packages are not installed: ${missing_packages[*]}"
    log "Do you want to install them? (y/n)"
    read install_choice
    if [ "$install_choice" == "y" ]; then
        for package in "${missing_packages[@]}"; do
            case $package in
                "nginx")
                    sudo apt-get install -y nginx
                    ;;
                "python3.12")
                    sudo add-apt-repository -y ppa:deadsnakes/ppa
                    sudo apt-get update
                    sudo apt-get install -y python3.12
                    ;;
                "postgresql")
                    sudo apt-get install -y postgresql postgresql-contrib
                    ;;
            esac
        done
    else
        log "Skipping installation of missing packages."
    fi
else
    log "All required packages are already installed."
fi

# Start and enable services if installed
if dpkg -l | grep -q "nginx"; then
    start_and_enable_service "nginx"
    # Open nginx ports
    log "Opening nginx ports 80 and 443"
    sudo ufw allow 'Nginx Full'
    sudo ufw reload
fi

if dpkg -l | grep -q "postgresql"; then
    start_and_enable_service "postgresql"
fi

# Ask if the project is new or existing
while true; do
    log "Is this a new or existing project? (1 for new, 2 for existing)"
    read project_type
    if [ "$project_type" == "1" ] || [ "$project_type" == "2" ]; then
        break
    else
        log "Invalid input. Please enter '1' for new or '2' for existing."
    fi
done

if [ "$project_type" == "1" ]; then
    log "Enter the name of the new project:"
    read project_name
    log "Enter the GitHub link of the new project:"
    read github_link
    create_postgres_db "$project_name"
elif [ "$project_type" == "2" ]; then
    log "Do you want to create a PostgreSQL database? (1 for yes, 2 for no)"
    read create_db
    if [ "$create_db" == "1" ]; then
        log "Enter the name of the existing project:"
        read project_name
        create_postgres_db "$project_name"
    else
        log "Skipping database creation."
    fi
fi




