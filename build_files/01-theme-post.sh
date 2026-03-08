#!/bin/bash

set -xeuo pipefail

# keep in sync with zirconium preset file
systemctl preset greetd.service
systemctl preset tailscaled.service
systemctl preset --global chezmoi-init.service
systemctl preset --global chezmoi-update.timer
systemctl preset --global dms.service
systemctl preset --global fcitx5.service
systemctl preset --global foot-server.service
systemctl preset --global foot-server.socket
systemctl preset --global gnome-keyring-daemon.service
systemctl preset --global gnome-keyring-daemon.socket
systemctl preset --global gcr-ssh-agent.service
systemctl preset --global gcr-ssh-agent.socket
systemctl preset --global iio-niri.service
systemctl preset --global udiskie.service

install -Dpm0644 -t /usr/share/plymouth/themes/spinner/ /ctx/assets/logos/watermark.png
install -Dpm0644 -t /usr/share/zirconium/skel/Pictures/Wallpapers/ /ctx/assets/wallpapers/*
install -Dpm0644 -t /usr/share/zirconium/pixmaps/ /ctx/assets/logos/logo-z.svg

