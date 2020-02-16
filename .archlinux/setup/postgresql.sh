#!/usr/bin/env bash

yay -S --noconfirm postgresql

sudo echo "postgres:a" | chpasswd

su - postgres -c "initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'"

sudo systemctl enable --now postgresql.service

su - postgres -c "createuser --interactive"

createdb "$(whoami)"
