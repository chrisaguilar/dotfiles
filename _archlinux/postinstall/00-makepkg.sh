title "makepkg Setup"


subtitle "Setting CFLAGS"
sed -i -r -e 's/CFLAGS=.*$/CFLAGS="-march=native -O2 -pipe -fstack-protector-strong -fno-plt"/' /etc/makepkg.conf


subtitle "Setting CXXFLAGS"
sed -i -r -e 's/CXXFLAGS=.*$/CXXFLAGS="${CFLAGS}"/' /etc/makepkg.conf


subtitle "Setting MAKEFLAGS"
sed -i -r -e 's/# ?MAKEFLAGS=.*$/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf


subtitle "Setting BUILDDIR"
sed -i -r -e 's/# ?BUILDDIR/BUILDDIR/' /etc/makepkg.conf

subtitle "Setting COMPRESSXZ"
sed -i -r -e 's/COMPRESSXZ=.*$/COMPRESSXZ=(xz -c -z - --threads=0)/' /etc/makepkg.conf
