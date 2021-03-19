#!/usr/bin/env bash
# Prepare Arch Linux container environments

REPO_NAME='drawsta'

GPGKEY='0AD759F2FE27647D'

# makepkg config
# see: /etc/makepkg.conf
MAKEPKG_CONF="
CFLAGS='-march=x86-64 -O2 -pipe -fno-plt'
CXXFLAGS='-march=x86-64 -O2 -pipe -fno-plt'
MAKEFLAGS='-j$(nproc)'
BUILDENV=(!distcc !color !ccache !check sign)
COMPRESSZST=(zstd -z -c -q -T0 -18 -)
PACKAGER='drawsta <lmeex07@gmail.com>'
PKGDEST=''
PKGEXT='.pkg.tar.zst'
GPGKEY='$GPGKEY'
"
echo $MAKEPKG_CONF >> /etc/makepkg.conf

pacman -Syu sudo rsync --noconfirm --needed --noprogressbar

useradd -m -G wheel aurbot
sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

su aurbot -c "mkdir -p ~aurbot/.cache/pkg"
if [[ ! -f ~aurbot/.cache/pkg/$REPO_NAME.db.tar.gz ]]; then
  su aurbot -c "repo-add -s -k $GPGKEY ~aurbot/.cache/pkg/$REPO_NAME.db.tar.gz"
fi

cat >> /etc/pacman.conf <<EOF
[$REPO_NAME]
Server = file:///home/aurbot/.cache/pkg
SigLevel = Optional TrustAll
EOF
