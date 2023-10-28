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
    sudo ufw allow OpenSSH
    sudo ufw allow WWW
    sudo ufw allow 'WWW Full'
    sudo ufw allow 80
    sudo ufw allow 22
    sudo ufw allow 443
    sudo ufw enable
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

    # Run the MySQL secure installation script
    echo "Running MySQL secure installation..."
    sudo mysql_secure_installation
    echo "MySQL secure installation complete."

    # Optionally, you can set up other MySQL configurations here if needed.
    # For example, you can create additional MySQL users and databases.
    # You can also skip the installation of the 'VALIDATE PASSWORD' plugin
    # (Type 'N' when prompted) if you don't need it.
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

# Function to install Git and Composer
install_git_composer() {
    echo "Installing Git and Composer..."
    sudo apt update
    sudo apt install -y git
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    composer --version
    echo "Git and Composer installed."
}

# Function to configure Apache for Laravel
configure_apache() {
    echo "Configuring Apache for Laravel..."
    # Create a virtual host configuration file
    sudo tee /etc/apache2/sites-available/laravel.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@techvblogs.com
    ServerName  192.168.33.100
    DocumentRoot /var/www/html/your-project-name/public

    <Directory /var/www/html/your-project-name/public>
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
# Default MySQL root password
db_password="bog_reaper321"

# Function to set up the database
setup_database() {
    echo "Setting up the database..."
    if [ -z "$db_password" ]; then
        read -s -p "Enter your MySQL root password: " db_password
    fi
    mysql -u root -p$db_password -e "CREATE DATABASE bog_reaper;"
    mysql -u root -p$db_password -e "GRANT ALL PRIVILEGES ON bog_reaper.* TO 'bog_reaper@'localhost';"
    mysql -u root -p$db_password -e "FLUSH PRIVILEGES;"
    echo "Database setup completed."
}

# Define the environment variable values
DB_DATABASE="bog_reaper"
DB_USERNAME="bog_reaper"
DB_PASSWORD="bog_reaper321"

# Laravel .env file path
ENV_FILE="/var/www/html/laravel/.env"

# Check if the .env file exists
if [ -f "$ENV_FILE" ]; then
    # Use sed to find and replace the values in the .env file
  sudo  sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_DATABASE/" "$ENV_FILE"
   sudo  sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" "$ENV_FILE"
    sudo sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" "$ENV_FILE"
    echo "Updated .env file with database credentials."

    # Check if Laravel is properly installed before migrating the database
    if [ -d "/var/www/html/laravel" ]; then
        # Migrate the database
        cd /var/www/html/laravel
        php artisan migrate

        # Activate the Laravel virtual host
        sudo a2ensite laravel.conf

        # Restart Apache
        sudo service apache2 restart
    else
        echo "Laravel is not properly installed. Please check your installation."
    fi
else
    echo ".env file not found. Please make sure the file exists."
fi

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
