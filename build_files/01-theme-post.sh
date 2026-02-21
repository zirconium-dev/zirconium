#!/bin/bash

set -xeuo pipefail

install -d /usr/share/zirconium/


install -Dpm0644 -t /usr/lib/pam.d/ /usr/share/quickshell/dms/assets/pam/* # Fixes long login times on fingerprint auth

# we already have a service for handling fcitx5
rm -f /usr/share/applications/fcitx5-wayland-launcher.desktop
rm -f /usr/share/applications/org.fcitx.Fcitx5*.desktop

sed --sandbox -i -e '/gnome_keyring.so/ s/-auth/auth/ ; /gnome_keyring.so/ s/-session/session/' /etc/pam.d/greetd


# keep in sync with zirconium preset file
systemctl preset greetd.service
systemctl preset tailscaled.service
systemctl preset --global chezmoi-init.service
systemctl preset --global chezmoi-update.timer
systemctl preset --global dms.service
#systemctl preset --global fcitx5.service
#systemctl preset --global foot-server.service
#systemctl preset --global foot-server.socket
systemctl preset --global gnome-keyring-daemon.service
systemctl preset --global gnome-keyring-daemon.socket
systemctl preset --global iio-niri.service
#systemctl preset --global udiskie.service

# Sane default for firewall
cp /ctx/FedoraWorkstation.xml /usr/lib/firewalld/zones/FedoraWorkstation.xml
grep -F -e '<port protocol="udp" port="1025-65535"/>' /usr/lib/firewalld/zones/FedoraWorkstation.xml
sed -i 's|^DefaultZone=.*|DefaultZone=FedoraWorkstation|g' /etc/firewalld/firewalld.conf
sed -i 's|^IPv6_rpfilter=.*|IPv6_rpfilter=loose|g' /etc/firewalld/firewalld.conf
grep -F -e "DefaultZone=FedoraWorkstation" /etc/firewalld/firewalld.conf
grep -F -e "IPv6_rpfilter=loose" /etc/firewalld/firewalld.conf

# ZramGenerator config
cp /ctx/zram-generator.conf /usr/lib/systemd/zram-generator.conf
grep -F -e "zram-size =" /usr/lib/systemd/zram-generator.conf

install -Dpm0644 -t /usr/share/plymouth/themes/spinner/ /ctx/assets/logos/watermark.png
install -Dpm0644 -t /usr/share/zirconium/skel/Pictures/Wallpapers/ /ctx/assets/wallpapers/*
install -Dpm0644 -t /usr/share/zirconium/pixmaps/ /ctx/assets/logos/logo-z.svg

fc-cache --force --really-force --system-only --verbose # recreate font-cache to pick up the added fonts

echo 'source /usr/share/zirconium/shell/pure.bash' | tee -a "/etc/bashrc"

install -d /usr/share/bash-completion/completions /usr/share/zsh/site-functions /usr/share/fish/vendor_completions.d/
just --completions bash | sed -E 's/([\(_" ])just/\1zjust/g' > /usr/share/bash-completion/completions/zjust
just --completions zsh | sed -E 's/([\(_" ])just/\1zjust/g' > /usr/share/zsh/site-functions/_zjust
just --completions fish | sed -E 's/([\(_" ])just/\1zjust/g' > /usr/share/fish/vendor_completions.d/zjust.fish

