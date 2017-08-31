#!/usr/bin/env bash

pacaur -Syu postgresql

echo "Set the password for the new 'postgres' user (root):"
sudo passwd postgres

echo "Initialize the database (postgres):"
sudo -u postgres initdb --locale $LANG -E UTF8 -D '/var/lib/postgres/data'

echo "Start the systemd service (root):"
sudo systemctl start postgresql

echo "Create your PostgreSQL user (postgres):"
sudo -u postgres createuser --interactive
