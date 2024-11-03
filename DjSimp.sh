#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if the script is run as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log "Please run this script as root or with sudo."
        exit 1
    fi
}

# Install a package if it's not installed
install_package() {
    local package=$1
    if ! dpkg -l | grep -q "$package"; then
        log "$package is not installed. Installing $package..."
        sudo apt-get install -y "$package"
    else
        log "$package is already installed."
    fi
}

# Setup Python 3.12
setup_python() {
    if ! dpkg -l | grep -q "python3.12"; then
        log "Python 3.12 is not installed. Installing Python 3.12 and python3.12-dev..."
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get update
        sudo apt-get install -y python3.12 python3.12-dev
    else
        log "Python 3.12 is already installed."
        install_package "python3.12-dev"
    fi
}

# Create a virtual environment using Python 3.12 as the sepehr user
create_virtualenv() {
    log "Creating a virtual environment using Python 3.12 as the sepehr user..."
    sudo -u sepehr python3.12 -m venv .venv
    log "Virtual environment created successfully."
}

# Activate the virtual environment as the sepehr user
activate_virtualenv() {
    log "Activating the virtual environment..."
    sudo -u sepehr bash -c "source .venv/bin/activate"
    log "Virtual environment activated successfully."
}

# Install the required packages from requirements.txt
install_requirements() {
    log "Installing the required packages from requirements.txt..."
    sudo -u sepehr bash -c ". .venv/bin/activate && pip install -r ./requirements.txt"
    log "Required packages installed successfully."
}

# Install gunicorn in the virtual environment
install_gunicorn() {
    log "Installing gunicorn in the virtual environment..."
    sudo -u sepehr bash -c ". .venv/bin/activate && pip install gunicorn"
    log "Gunicorn installed successfully."
}

# Ensure nginx is installed
setup_nginx() {
    install_package "nginx"
    if ! systemctl is-enabled --quiet nginx; then
        log "Enabling nginx service..."
        sudo systemctl enable nginx
    fi
    if ! systemctl is-active --quiet nginx; then
        log "Starting nginx service..."
        sudo systemctl start nginx
    fi
    log "nginx is installed, enabled, and running."
}

# Find the project name by locating the folder containing settings.py in depth 1
find_project_name() {
    log "Finding the project name by locating the folder containing settings.py in depth 1..."
    project_name=$(find . -maxdepth 1 -type d -exec test -e "{}/settings.py" \; -print | head -n 1 | sed 's|^\./||')
    if [ -z "$project_name" ]; then
        log "Could not find a folder containing settings.py in depth 1."
        exit 1
    else
        log "Project name found: $project_name"
    fi
}

# Create the gunicorn service file for the project
create_gunicorn_service() {
    log "Creating gunicorn service file for $project_name..."
    service_file_content="[Unit]
Description=gunicorn daemon for $project_name
After=network.target

[Service]
User=sepehr
Group=www-data
WorkingDirectory=/home/sepehr/$project_name
ExecStart=/home/sepehr/$project_name/.venv/bin/gunicorn \\
          --access-logfile - \\
          --workers 3 \\
          --bind unix:/home/sepehr/$project_name/Shop.sock \\
          $project_name.wsgi:application

[Install]
WantedBy=multi-user.target"
    echo "$service_file_content" | sudo tee /etc/systemd/system/gunicorn_$project_name.service > /dev/null
}

# Reload systemd to apply the new service
reload_systemd() {
    log "Reloading systemd to apply the new service..."
    sudo systemctl daemon-reload
}

# Enable the gunicorn service
enable_gunicorn_service() {
    log "Enabling the gunicorn service..."
    sudo systemctl enable gunicorn_$project_name
}

# Start the gunicorn service
start_gunicorn_service() {
    log "Starting the gunicorn service..."
    sudo systemctl start gunicorn_$project_name
}

# Create the nginx configuration file for the project
create_nginx_config() {
    log "Creating nginx configuration file for $project_name..."
    nginx_config="server {
        server_name $domain_names;

        # Charset for Persian characters
        charset utf-8;
        client_max_body_size 100M;

        # Serve favicon.ico without logging
        location = /favicon.ico { access_log off; log_not_found off; }

        # Serve static files
        location /static/ {
            alias /home/sepehr/$project_name/staticfiles/;
        }

        # Serve media files
        location /media/ {
            alias /home/sepehr/$project_name/media/;
        }

        # Proxy pass to Gunicorn
        location / {
            include proxy_params;
            proxy_pass http://unix:/home/sepehr/$project_name/Shop.sock;
        }
    }"
    echo "$nginx_config" | sudo tee /etc/nginx/sites-available/$project_name > /dev/null
}

# Enable the nginx configuration by creating a symbolic link
enable_nginx_config() {
    log "Enabling the nginx configuration..."
    sudo ln -s /etc/nginx/sites-available/$project_name /etc/nginx/sites-enabled/
}

# Test the nginx configuration for syntax errors
test_nginx_config() {
    log "Testing the nginx configuration for syntax errors..."
    sudo nginx -t
}

# Reload nginx to apply the new configuration
reload_nginx() {
    log "Reloading nginx to apply the new configuration..."
    sudo systemctl reload nginx
}

# Create the nginx configuration file for the project
create_nginx_config() {
    log "Creating nginx configuration file for $project_name..."
    nginx_config="server {
        server_name $domain_names;

        # Charset for Persian characters
        charset utf-8;
        client_max_body_size 100M;

        # Serve favicon.ico without logging
        location = /favicon.ico { access_log off; log_not_found off; }

        # Serve static files
        location /static/ {
            alias /home/sepehr/$project_name/staticfiles/;
        }

        # Serve media files
        location /media/ {
            alias /home/sepehr/$project_name/media/;
        }

        # Proxy pass to Gunicorn
        location / {
            include proxy_params;
            proxy_pass http://unix:/home/sepehr/$project_name/Shop.sock;
        }
    }"
    echo "$nginx_config" | sudo tee /etc/nginx/sites-available/$project_name > /dev/null
}

# Enable the nginx configuration by creating a symbolic link
enable_nginx_config() {
    log "Enabling the nginx configuration..."
    sudo ln -s /etc/nginx/sites-available/$project_name /etc/nginx/sites-enabled/
}

# Test the nginx configuration for syntax errors
test_nginx_config() {
    log "Testing the nginx configuration for syntax errors..."
    sudo nginx -t
}

# Reload nginx to apply the new configuration
reload_nginx() {
    log "Reloading nginx to apply the new configuration..."
    sudo systemctl reload nginx
}

# Install Certbot and the Nginx plugin
install_certbot() {
    log "Installing Certbot and the Nginx plugin..."
    sudo apt-get install -y certbot python3-certbot-nginx
}

# Obtain SSL certificates using Certbot
obtain_ssl_certs() {
    log "Obtaining SSL certificates for $domain_names..."
    sudo certbot --nginx -d $domain_names
}

# Set up automatic certificate renewal
setup_automatic_cert_renewal() {
    log "Setting up automatic certificate renewal..."
    sudo systemctl enable certbot.timer
    sudo systemctl start certbot.timer
}

# Main function
main() {
    check_root
    setup_python
    create_virtualenv
    activate_virtualenv
    install_requirements
    install_gunicorn
    setup_nginx
    find_project_name
    create_gunicorn_service
    reload_systemd
    enable_gunicorn_service
    start_gunicorn_service
    create_nginx_config
    enable_nginx_config
    test_nginx_config
    reload_nginx
    install_certbot
    obtain_ssl_certs
    setup_automatic_cert_renewal
    log "SSL certificates obtained and automatic renewal set up successfully."
}

# Call the main function
main
