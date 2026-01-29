#!/bin/bash

set -xeuo pipefail

dnf -y install 'dnf5-command(config-manager)'

dnf -y remove \
  console-login-helper-messages \
  sssd* \
  qemu-user-static* \
  toolbox

# These were manually picked out from a Bluefin comparison with `rpm -qa --qf="%{NAME}\n" `
# Installing Flatpak,Distrobox,Bootc (Those are recommended by uupd) here to purge uupd from image
dnf -y install \
  -x PackageKit* \
  NetworkManager \
  NetworkManager-adsl \
  NetworkManager-config-connectivity-fedora \
  NetworkManager-libnm \
  NetworkManager-strongswan \
  NetworkManager-ssh \
  NetworkManager-ssh-selinux \
  NetworkManager-wwan \
  alsa-firmware \
  alsa-sof-firmware \
  alsa-tools-firmware \
  bootc \
  firewalld \
  flatpak \
  distrobox \
  fuse \
  fuse-common \
  fwupd \
  gum \
  gvfs-archive \
  gvfs-mtp \
  gvfs-nfs \
  gvfs-smb \
  jmtpfs \
  libcamera{,-{v4l2,gstreamer,tools}} \
  man-db \
  man-pages \
  mobile-broadband-provider-info \
  plymouth \
  plymouth-system-theme \
  realtek-firmware \
  rsync \
  systemd-container \
  systemd-oomd-defaults \
  tuned \
  tuned-ppd \
  unzip \
  usb_modeswitch \
  zram-generator-defaults


systemctl enable firewalld

sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

systemctl enable bootc-fetch-apply-updates

if [ "$(rpm -E "%{fedora}")" == 43 ] ; then
  dnf -y copr enable ublue-os/flatpak-test
  dnf -y copr disable ublue-os/flatpak-test
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper
  rpm -q flatpak --qf "%{NAME} %{VENDOR}\n" | grep ublue-os
fi
