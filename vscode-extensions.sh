#!/usr/bin/env bash

extensions="
    EditorConfig.EditorConfig
    James-Yu.latex-workshop
    donjayamanne.githistory
    donjayamanne.python
    eg2.tslint
    esbenp.prettier-vscode
    joelday.docthis
    robertohuertasm.vscode-icons
    zhuangtongfa.Material-theme
"

for extension in ${extensions}; do
    code --install-extension "${extension}"
done
