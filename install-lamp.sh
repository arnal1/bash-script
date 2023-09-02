#!/bin/bash

# Function to update package lists
update_packages() {
    sudo apt update
}

# Function to install Apache2
install_apache() {
    sudo apt install apache2 -y
}

# Function to install MySQL Server
install_mysql() {
    sudo apt install mysql-server -y
}

# Function to create a MySQL user
create_mysql_user() {
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
}

# Function to select PHP version
select_php_version() {
    echo "Select the PHP version you want to install:"
    echo "1) PHP 7.4"
    echo "2) PHP 8.0"
    echo "3) PHP 8.1"
    echo "4) PHP 8.2"
    read -p "Enter the version number (1/2/3/4): " php_version_choice

    # Default PHP version (PHP 8.1)
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
    sudo apt install php${PHP_VERSION} libapache2-mod-php php${PHP_VERSION}-mysql php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-zip -y
}

# Function to install Composer
install_composer() {
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
}

# Function to install Node.js
install_nodejs() {
    echo "Select the Node.js version you want to install:"
    echo "1) Node.js (16.x)"
    echo "2) Node.js (18.x)"
    echo "3) Node.js (20.x)"
    read -p "Enter the version number (1/2/3): " nodejs_version_choice

    sudo apt-get install -y ca-certificates curl gnupg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

    NODE_MAJOR=$nodejs_version_choice
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

    sudo apt-get update
    sudo apt-get install nodejs -y
}

# Function to clean up and start services
cleanup_and_start_services() {
    sudo apt autoremove -y
    sudo apt clean

    # Start Apache2 and MySQL
    sudo systemctl start apache2
    sudo systemctl start mysql

    # Enable Apache2 and MySQL to start on boot
    sudo systemctl enable apache2
    sudo systemctl enable mysql

    echo "Installation is complete."
}

# Main script execution

echo "Choose installation option:"
echo "1) Install Apache2"
echo "2) Install MySQL Server"
echo "3) Create a MySQL user"
echo "4) Select PHP version"
echo "5) Install Composer"
echo "6) Install Node.js"
echo "7) Install all components"
read -p "Enter the option number (1/2/3/4/5/6/7): " install_option

case $install_option in
    1)
        install_apache
        ;;
    2)
        install_mysql
        ;;
    3)
        create_mysql_user
        ;;
    4)
        select_php_version
        ;;
    5)
        install_composer
        ;;
    6)
        install_nodejs
        ;;
    7)
        install_apache
        install_mysql
        create_mysql_user
        select_php_version
        install_composer
        install_nodejs
        ;;
    *)
        echo "Invalid option"
        ;;
esac