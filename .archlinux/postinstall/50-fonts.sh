title "Font Setup"


subtitle "Installing Packages"
package_install "cairo fontconfig freetype2 noto-fonts noto-fonts-cjk \
                 noto-fonts-emoji noto-fonts-extra otf-fira-mono otf-font-awesome \
                 ttf-liberation"


subtitle "Creating Symbolic Links from /etc/fonts/conf.avail -> /etc/fonts/conf.d"
ln -sf /etc/fonts/conf.avail/10-{hinting-slight,sub-pixel-rgb}.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
ln -sf /etc/fonts/conf.avail/66-noto-{color-emoji,mono,sans,serif}.conf /etc/fonts/conf.d/


subtitle "Creating /etc/fonts/local.conf"
cat << EOF > /etc/fonts/local.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>Noto Sans</family>
            <family>Noto Color Emoji</family>
            <family>Noto Emoji</family>
        </prefer>
    </alias>

    <alias>
        <family>serif</family>
        <prefer>
            <family>Noto Serif</family>
            <family>Noto Color Emoji</family>
            <family>Noto Emoji</family>
        </prefer>
    </alias>

    <alias>
        <family>monospace</family>
        <prefer>
            <family>Fira Code</family>
            <family>Noto Color Emoji</family>
            <family>Noto Emoji</family>
        </prefer>
    </alias>

</fontconfig>
EOF


subtitle "Modifying freetype2.sh"
sed -i -r -e 's/# ?export/export/' /etc/profile.d/freetype2.sh


subtitle "Regenerating the Font Cache"
fc-cache -f
