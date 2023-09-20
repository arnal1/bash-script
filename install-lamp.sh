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

# Function to install SQLite 3
install_sqlite() {
    sudo apt install sqlite3 -y
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
            sudo apt install php${PHP_VERSION} libapache2-mod-php php${PHP_VERSION}-mysql php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-sqlite3 -y
            ;;
        3)
            PHP_VERSION="8.1"
            sudo apt install php${PHP_VERSION} libapache2-mod-php php${PHP_VERSION}-mysql php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-bcmath -y
            ;;
        4)
            PHP_VERSION="8.2"
            sudo apt install php${PHP_VERSION} libapache2-mod-php php${PHP_VERSION}-mysql php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-sqlite3 -y
            ;;
        *)
            echo "Using PHP 8.1 (default)"
            PHP_VERSION="8.1"
            sudo apt install php${PHP_VERSION} libapache2-mod-php php${PHP_VERSION}-mysql php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-sqlite3 -y
            ;;
    esac
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
    echo "1) Node.js (16)"
    echo "2) Node.js (18) (Default)"
    echo "3) Node.js (20)"
    read -p "Enter the version number (1/2/3): " nodejs_version_choice

    case $nodejs_version_choice in
        1)
            NODE_MAJOR=16
            ;;
        2)
            NODE_MAJOR=18
            ;;
        3)
            NODE_MAJOR=20
            ;;
        *)
            NODE_MAJOR=18
            echo "Invalid option (use default version 18)"
            ;;
    esac

    sudo apt install curl

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

    source ~/.bashrc

    nvm install ${NODE_MAJOR}
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
echo "4) Install SQLite 3"
echo "5) Select PHP version"
echo "6) Install Composer"
echo "7) Install Node.js"
echo "8) Install all components"
read -p "Enter the option number (1/2/3/4/5/6/7/8): " install_option

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
        install_sqlite
        ;;
    5)
        select_php_version
        ;;
    6)
        install_composer
        ;;
    7)
        install_nodejs
        ;;
    8)
        install_apache
        install_mysql
        create_mysql_user
        install_sqlite
        select_php_version
        install_composer
        install_nodejs
        ;;
    *)
        echo "Invalid option"
        ;;
esac