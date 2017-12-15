#!/usr/bin/env bash

for extension in `cat ./extensions`; do
    code --install-extension "${extension}"
done
