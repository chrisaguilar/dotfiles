title "Installing Miscellaneous Packages"


subtitle "Essentials"
package_install "alsa-plugins alsa-utils autofs avahi bc cpio dosfstools \
                 exfat-utils f2fs-tools fuse fuse-exfat lzop mlocate mtpfs \
                 nss-mdns ntfs-3g openssh p7zip pkgstats pulseaudio \
                 pulseaudio-alsa rsync tree unrar unzip zip"


subtitle "Development"
package_install "dotnet-runtime dotnet-sdk jre9-openjdk-headless jre9-openjdk \
                jdk9-openjdk openjdk9-doc openjdk9-src nginx-mainline nodejs \
                npm python python-pip redis rustup"


subtitle "Books"
package_install "calibre zathura zathura-pdf-mupdf zathura-djvu"


# subtitle "CUPS"
# package_install "cups cups-filters cups-pdf foomatic-db foomatic-db-engine \
#                  foomatic-db-gutenprint-ppds foomatic-db-nonfree \
#                  foomatic-db-nonfree-ppds foomatic-db-ppds ghostscript gsfonts \
#                  gtk3-print-backends gutenprint hplip splix \
#                  system-config-printer"


# subtitle "Office"
# package_install "libreoffice-fresh"


# subtitle "LaTeX"
# package_install "biber texlive-lang texlive-langextra texlive-most texstudio"


subtitle "System"
package_install "htop"


subtitle "Graphics"
package_install "feh simplescreenrecorder guvcview"


subtitle "Internet"
package_install "transmission-gtk wget youtube-dl"


subtitle "Audio"
package_install "gst-libav gst-plugins-bad gst-plugins-base \
                 gst-plugins-base-libs gst-plugins-good gst-plugins-ugly"


subtitle "Video"
package_install "mpv"


subtitle "AUR Packages"
usr "yes | trizen -S capitaine-cursors discord google-chrome gpmdp heroku-cli \
    i3ipc-glib-git ngrok numix-circle-icon-theme-git otf-fira-code peek \
    polybar-git skypeforlinux-preview-bin slack-desktop visual-studio-code-bin \
    xfce-theme-greybird zsh-autosuggestions"
