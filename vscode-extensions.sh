#!/usr/bin/env bash

extensions="
    abusaidm.html-snippets
    CoenraadS.bracket-pair-colorizer
    dbaeumer.vscode-eslint
    donjayamanne.githistory
    eamodio.gitlens
    EditorConfig.EditorConfig
    eg2.tslint
    esbenp.prettier-vscode
    formulahendry.auto-close-tag
    formulahendry.auto-rename-tag
    formulahendry.code-runner
    HookyQR.beautify
    humao.rest-client
    joelday.docthis
    ms-python.python
    msjsdiag.debugger-for-chrome
    PeterJausovec.vscode-docker
    redhat.java
    robertohuertasm.vscode-icons
    robinbentley.sass-indented
    shinnn.stylelint
    vscjava.vscode-java-debug
    vscjava.vscode-java-pack
    wayou.vscode-todo-highlight
    zhuangtongfa.Material-theme
    Zignd.html-css-class-completion
"

for extension in ${extensions}; do
    code --install-extension "${extension}"
done
