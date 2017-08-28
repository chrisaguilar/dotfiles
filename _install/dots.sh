#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$DIR/.."

mkdir -p "$HOME/.config"

stow -v -R -t "$HOME/.config" .

cd _home

stow -v -R -t "$HOME" .

cd ..
