#!/bin/bash

cd ../_home

stow -v -R -t "$HOME" .

cd ..
