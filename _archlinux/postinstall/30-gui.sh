title "Graphical Environment Setup"


subtitle "Installing Graphics Drivers"
package_install "mesa xf86-video-intel vulkan-intel vulkan-icd-loader \
                libva-intel-driver libvdpau-va-gl libva-vdpau-driver"


subtitle "Installing Xorg"
package_install "xorg-server xorg-xinit"


subtitle "Configuring Xorg Modules"
mkdir -p /etc/X11/xorg.conf.d
cat << EOF > /etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "AccelMethod" "sna"
    Option "TearFree" "true"
EndSection
EOF

cat << EOF > /etc/X11/xorg.conf.d/30-touchpad.conf
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "AccelProfile" "adaptive"
    Option "AccelSpeed" "0"
    Option "ButtonMapping" "1 0 3"
    Option "ClickMethod" "clickfinger"
    Option "DisableWhileTyping" "true"
    Option "HorizontalScrolling" "true"
    Option "MiddleEmulation" "false"
    Option "NaturalScrolling" "false"
    Option "ScrollMethod" "twofinger"
    Option "SendEventsMode" "disabled-on-external-mouse"
    Option "Tapping" "true"
    Option "TappingButtonMap" "lrm"
    Option "TappingDrag" "true"
EndSection
EOF


subtitle "Installing Desktop Environment"
package_install "blueman compton curl geoip geoip-database-extra gnome-themes-standard \
                 i3-wm i3lock jsoncpp maim numlockx pavucontrol polkit-gnome \
                 python-gobject python-xdg xdg-utils redshift rofi \
                 xdotool xfce4-notifyd xorg-xprop xorg-xwininfo"

package_install "termite" "stubborn"
