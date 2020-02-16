#!/usr/bin/env bash

yay -S --noconfirm mariadb mysql-workbench

sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

sudo systemctl enable --now mariadb.service

sudo mysql_secure_installation
