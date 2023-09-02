#!/bin/bash

# Update package lists
sudo apt update

# Install Apache2
sudo apt install apache2 -y

# Install MySQL Server
sudo apt install mysql-server -y

# Prompt the user to create a MySQL user
read -p "Create a MySQL user (yes/no)? " create_mysql_user

if [[ "$create_mysql_user" == "yes" ]]; then
    read -p "Enter MySQL username: " mysql_username
    read -sp "Enter MySQL password: " mysql_password
    echo

    # Create MySQL user
    sudo mysql -e "CREATE USER '${mysql_username}'@'localhost' IDENTIFIED BY '${mysql_password}';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${mysql_username}'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"
    echo "MySQL user '${mysql_username}' has been successfully created."
fi

# Prompt the user to select a PHP version
echo "Select the PHP version you want to install:"
echo "1) PHP 7.4"
echo "2) PHP 8.0"
echo "3) PHP 8.1"
echo "4) PHP 8.2"
read -p "Enter the version number (1/2/3/4): " php_version_choice

# Default PHP version (PHP 7.4)
PHP_VERSION="8.1"

case $php_version_choice in
    2)
        PHP_VERSION="8.0"
        ;;
    3)
        PHP_VERSION="8.1"
        ;;
    4)
        PHP_VERSION="8.2"
        ;;
    *)
        echo "Using PHP 8.1 (default)"
        ;;
esac

# Install PHP and required extensions
sudo apt install php${PHP_VERSION} php${PHP_VERSION}-mysql php${PHP_VERSION}-curl php${PHP_VERSION}-json php${PHP_VERSION}-cgi php${PHP_VERSION}-common php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-gd php${PHP_VERSION}-dev -y

# Install Composer
EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" = "$ACTUAL_SIGNATURE" ]; then
    php composer-setup.php --quiet
    sudo mv composer.phar /usr/local/bin/composer
else
    >&2 echo 'ERROR: Invalid composer installer signature'
    rm composer-setup.php
    exit 1
fi

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Start Apache2 and MySQL
sudo systemctl start apache2
sudo systemctl start mysql

# Enable Apache2 and MySQL to start on boot
sudo systemctl enable apache2
sudo systemctl enable mysql

echo "Installation is complete."