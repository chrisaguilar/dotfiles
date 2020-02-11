#!/usr/bin/env bash

yay -S --noconfirm docker

sudo systemctl enable docker.service

sudo usermod -aG docker chris
