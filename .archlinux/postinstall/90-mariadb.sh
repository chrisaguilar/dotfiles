title "MariaDB Setup"


subtitle "Installing Packages"
package_install "mariadb mysql-workbench"


subtitle "Initializing MariaDB Database"
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql >> "${LOG}" 2>&1


subtitle "Starting MariaDB"
enable_services "mariadb.service"


subtitle "MariaDB Secure Installation"
mysql_secure_installation
