#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$DIR/.."

stow -v -R -t "$HOME/.config" .

cd _home

stow -v -R -t "$HOME" .
