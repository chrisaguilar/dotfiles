#!/bin/bash

# mkdir -p "$HOME/.config"

# stow -v -R -t "$HOME/.config" .

cd _home

stow -v -R -t "$HOME" .

cd ..
