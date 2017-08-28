#!/usr/bin/env bash

# Set the keymap to us
loadkeys us

# Ensure the system clock is accurate
timedatectl set-ntp true

# List disks available for partitioning
lsblk
