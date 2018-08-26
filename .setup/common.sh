#!/usr/bin/env bash

function package_install() {
    yay -S --needed "$@"
}

function enable_service() {
    sudo systemctl enable --now "$@"
}
