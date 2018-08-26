#!/usr/bin/env bash

. ./common.sh

# Install MongoDB + Tools
package_install mongodb{,-tools}

# Enable the service
sudo systemctl enable --now mongodb
