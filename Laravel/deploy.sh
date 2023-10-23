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
    
# Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
# Success.


# Normally, root should only be allowed to connect from
# 'localhost'. This ensures that someone cannot guess at
 # the root password from the network.

# Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y
# Success.

# By default, MySQL comes with a database named 'test' that
# anyone can access. This is also intended only for testing,
# and should be removed before moving into a production
# environment.


 # Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
# - Dropping test database...
# Success.

 # - Removing privileges on test database...
# Success.

# Reloading the privilege tables will ensure that all changes
# made so far will take effect immediately.

# Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
# Success.

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
    cat << EOF > /etc/apache2/sites-available/laravel.conf 
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
# Define the environment variable values
DB_DATABASE="bog_reaper"
DB_USERNAME="bog_reaper"
DB_PASSWORD="bog_reaper321"

setup_database() {
    echo "Setting up the database..."
    if [ -f /var/www/html/laravel/.env ]; then
        # Load database credentials from .env file
        source /var/www/html/laravel/.env

        # Create the database
        mysql -u root -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_DATABASE;"

        # Grant privileges to the database user
        mysql -u root -p"$DB_PASSWORD" -e "GRANT ALL PRIVILEGES ON $DB_DATABASE.* TO '$DB_USERNAME'@'localhost';"

        # Flush privileges
        mysql -u root -p"$DB_PASSWORD" -e "FLUSH PRIVILEGES;"

        echo "Database setup completed."
    else
        echo ".env file not found. Please make sure it exists."
    fi
    # In this section after the scripts ran you will be required to enter bog_reaper321 three types as the password
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
