title "PostgreSQL Setup"


subtitle "Installing Packages"
package_install "postgresql"


subtitle "Setting Password for User postgres"
passwd postgres


subtitle "Initializing PostgreSQL Data Directory"
su - postgres -c "initdb --locale ${LANG} -E UTF8 -D '/var/lib/postgres/data'"


subtitle "Enabling PostgreSQL"
enable_services "postgresql.service"


subtitle "Creating Default PostgreSQL User"
su - postgres -c "createuser --interactive"
