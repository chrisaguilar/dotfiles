function reflect() {
    sudo reflector --save /etc/pacman.d/mirrorlist --verbose --sort rate -f 25 -a 6 -p http -p https
}
