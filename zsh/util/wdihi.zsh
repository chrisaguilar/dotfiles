function wdihi() {
    expac -HM '%011m\t%-20n' $(comm -23 <(pacman -Qqe | sort) <(pacman -Qqg base base-devel $@ | sort)) | sort -rn | less
}
