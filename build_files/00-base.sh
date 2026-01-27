#!/bin/bash

set -xeuo pipefail

dnf -y install 'dnf5-command(config-manager)'

dnf -y remove \
  console-login-helper-messages \
  sssd* \
  qemu-user-static* \
  toolbox

# These were manually picked out from a Bluefin comparison with `rpm -qa --qf="%{NAME}\n" `
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
  firewalld \
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
  pam_yubico \
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

sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

dnf -y copr enable ublue-os/packages
dnf -y copr disable ublue-os/packages
dnf -y --enablerepo copr:copr.fedorainfracloud.org:ublue-os:packages install uupd ublue-os-udev-rules

# ts so annoying :face_holding_back_tears: :v: 67
sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service

systemctl enable uupd.timer


if [ "$(rpm -E "%{fedora}")" == 43 ] ; then
  dnf -y copr enable ublue-os/flatpak-test
  dnf -y copr disable ublue-os/flatpak-test
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper
  rpm -q flatpak --qf "%{NAME} %{VENDOR}\n" | grep ublue-os
fi
