#!/bin/bash

cd ../_home

stow -v -R -t "$HOME" .

cd ..

stow -v -R -t "$HOME/.config" .
