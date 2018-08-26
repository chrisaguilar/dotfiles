#!/usr/bin/env bash

. ./common.sh

# Install MariaDB
package_install mariadb mysql-workbench

# Install the Database
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# Start the MariaDB Service
enable_service mariadb.service

# Run Secure Installation
sudo mysql_secure_installation
