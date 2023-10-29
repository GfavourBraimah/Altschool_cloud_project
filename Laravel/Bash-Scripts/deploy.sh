#!/bin/bash

# This script automates the deployment of a LAMP stack and a Laravel application.
# It's designed to run on an Ubuntu-based server.

# Function to install essential packages
install_essentials() {
    echo "Installing essential packages..."
    sudo apt update
    sudo apt install -y wget git apache2 curl
    echo "Essential packages installed."
}

# Function to configure firewall (UFW)
configure_firewall() {
    echo "Configuring firewall (UFW)..."
    sudo apt update
    sudo apt install ufw -y

    # Provide "yes" to the UFW command's prompt
    echo "y" | sudo ufw allow OpenSSH
    echo "y" | sudo ufw allow WWW
    echo "y" | sudo ufw allow 'WWW Full'
    echo "y" | sudo ufw allow 80
    echo "y" | sudo ufw allow 22
    echo "y" | sudo ufw allow 443

    # Automatically enable UFW without prompting
    echo "y" | sudo ufw enable

    echo "Firewall configured."
}

# Function to install and configure Apache
install_apache() {
    echo "Installing and configuring Apache..."
    sudo apt update
    sudo apt install apache2 -y
    echo "Apache installed and configured."
}

# Function to install MySQL
install_mysql() {
    echo "Installing MySQL server..."
    sudo apt-get update
    sudo apt-get install mysql-server -y

    # Run the MySQL secure installation script with predefined answers
    echo "Running MySQL secure installation..."
    echo -e "n\ny\n0\n$DB_PASSWORD\n$DB_PASSWORD\ny\ny\ny\ny\n" | sudo mysql_secure_installation
    echo "MySQL secure installation complete."

    # Optionally, you can set up other MySQL configurations here if needed.
    # For example, you can create additional MySQL users and databases.
}


# Function to install and configure PHP
install_php() {
    echo "Installing and configuring PHP..."
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt-get update
    sudo apt-get install libapache2-mod-php php php-common php-xml php-mysql php-gd php-mbstring php-tokenizer php-json php-bcmath php-curl php-zip unzip -y
    echo "PHP installed and configured."
}

# Function to configure PHP
configure_php() {
    echo "Configuring PHP..."
    # Edit php.ini to set cgi.fix_pathinfo=0
    sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/apache2/php.ini
    # Restart Apache to apply the changes.
    sudo systemctl restart apache2
    echo "PHP configured."
}

# ... (previous functions)

# Function to install Git and Composer
install_git_composer() {
    echo -e "\n\nInstalling Composer\n"
    sudo apt-get update -y < /dev/null
    sudo apt install curl -y < /dev/null
    sudo apt install -y git < /dev/null
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    export COMPOSER_ALLOW_SUPERUSER=1

    composer --version < /dev/null
    echo -e "\n\nComposer successfully installed\n"
}

# Function to configure Apache for Laravel
configure_apache() {
    echo "Configuring Apache for Laravel..."
    # Create a virtual host configuration file using cat
    cat <<-EOF > /etc/apache2/sites-available/laravel.conf
    <VirtualHost *:80>
        ServerAdmin admin@techvblogs.com
        ServerName 192.168.33.100
        DocumentRoot /var/www/html/laravel/public

        <Directory /var/www/html/laravel/public>
            Options +FollowSymlinks
            AllowOverride All
            Require all granted
        </Directory>

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>
EOF
    echo "Apache configured for Laravel."
}


# Function to clone Laravel from GitHub repository
clone_laravel() {
    echo "Cloning Laravel from GitHub repository..."
    sudo mkdir /var/www/html/laravel
    cd /var/www/html/laravel
    sudo git clone https://github.com/laravel/laravel .
    composer install --no-dev
    echo "Laravel application cloned."
}

# Function to set Laravel permissions
set_laravel_permissions() {
    echo "Setting Laravel permissions..."
    # Set ownership to the web server user (www-data)
    sudo chown -R www-data:www-data /var/www/html/laravel

    # Set directory and file permissions
    sudo chmod -R 775 /var/www/html/laravel
    sudo chmod -R 775 /var/www/html/laravel/storage
    sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache
    echo "Laravel permissions set."
}

# Function to configure Laravel .env file
configure_laravel() {
    echo "Configuring Laravel .env file..."
    # Copy the .env example to .env
    cp /var/www/html/laravel/.env.example /var/www/html/laravel/.env

    # Generate an encryption key
    php /var/www/html/laravel/artisan key:generate
    echo "Laravel .env file configured."
}

 # Function to set up the database
setup_database() {
    echo "Setting up the database..."
    if [ -f /var/www/html/laravel/.env ]; then
        # Load database credentials from .env file
        source /var/www/html/laravel/.env

        # Define the new database and user credentials
        NEW_DB_NAME="bog_reaper"
        NEW_DB_USER="bog_reaper"
        NEW_DB_PASS="bog_reaper321"

        # Create the database and user without prompts
        mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS $NEW_DB_NAME;
CREATE USER IF NOT EXISTS '$NEW_DB_USER'@'localhost' IDENTIFIED BY '$NEW_DB_PASS';
GRANT ALL PRIVILEGES ON $NEW_DB_NAME.* TO '$NEW_DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

        # Update the .env file with new MySQL credentials
        sed -i "s/DB_DATABASE=.*/DB_DATABASE=$NEW_DB_NAME/" /var/www/html/laravel/.env
        sed -i "s/DB_USERNAME=.*/DB_USERNAME=$NEW_DB_USER/" /var/www/html/laravel/.env
        sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$NEW_DB_PASS/" /var/www/html/laravel/.env
        echo ".env file updated with new MySQL credentials."

        echo "Database setup completed."
    else
        echo ".env file not found. Please make sure it exists."
    fi
}
# Main script
install_essentials
configure_firewall
install_apache
install_mysql
install_php
configure_php
install_git_composer
configure_apache
clone_laravel
set_laravel_permissions
configure_laravel
setup_database

echo "*** Installation Complete ***"

 
