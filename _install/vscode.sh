#!/usr/bin/env bash

pacaur -Syu --needed visual-studio-code

# from `code --list-extensions`
extensions="
    christian-kohler.path-intellisense
    dbaeumer.vscode-eslint
    donjayamanne.python
    EditorConfig.EditorConfig
    eg2.tslint
    eg2.vscode-npm-script
    esbenp.prettier-vscode
    formulahendry.code-runner
    HookyQR.beautify
    humao.rest-client
    joelday.docthis
    msjsdiag.debugger-for-chrome
    octref.vetur
    robertohuertasm.vscode-icons
    shinnn.stylelint
    zhuangtongfa.Material-theme
"
for extension in $extensions; do
    code --install-extension "$extension"
done
