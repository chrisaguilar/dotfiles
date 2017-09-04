#!/usr/bin/env bash

set -e

# Set the keymap to us
loadkeys us

# Ensure the system clock is accurate
timedatectl set-ntp true

# List disks available for partitioning
lsblk
