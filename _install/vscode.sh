#!/usr/bin/env bash

pacaur -Syu visual-studio-code

# from `code --list-extensions`
extensions="
    donjayamanne.python
    robertohuertasm.vscode-icons
    zhuangtongfa.Material-theme
"
for extension in $extensions; do
    code --install-extension "$extension" || true
done
