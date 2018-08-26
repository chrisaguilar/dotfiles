#!/usr/bin/env bash

. ./common.sh

# Install PostgreSQL
package_install postgresql

# Change Password for User `postgres`
sudo passwd postgres

# Initialize Database Cluster
su - postgres -c "initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'"

# Enable and Start the PostgreSQL Service
enable_service postgresql.service

# Create First Database and User
su - postgres -c "createuser --interactive"

# Initialize User Database
createdb "$(whoami)"
