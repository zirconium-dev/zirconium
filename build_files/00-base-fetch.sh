#!/bin/bash

set -xeuo pipefail

dnf install -y epel-release && dnf update -y

# These were manually picked out from a Bluefin comparison with `rpm -qa --qf="%{NAME}\n" `
dnf -y install \
  -x PackageKit* \
  NetworkManager \
  NetworkManager-adsl \
  NetworkManager-bluetooth \
  NetworkManager-wifi \
  NetworkManager-wwan \
  alsa-firmware \
  alsa-sof-firmware \
  alsa-tools-firmware \
  atheros-firmware \
  audispd-plugins \
  audit \
  brcmfmac-firmware \
  cifs-utils \
  cups \
  cups-pk-helper \
  dymo-cups-drivers \
  firewalld \
  fprintd \
  fprintd-pam \
  fuse \
  fuse-common \
  fwupd \
  gum \
  gvfs-mtp \
  gvfs-smb \
  hplip \
  hyperv-daemons \
  ibus \
  ifuse \
  intel-audio-firmware \
  iwlegacy-firmware \
  iwlwifi-dvm-firmware \
  iwlwifi-mvm-firmware \
  kernel-modules-extra \
  libcamera{,-{v4l2,gstreamer,tools}} \
  libimobiledevice \
  libimobiledevice-utils \
  man-db \
  man-pages \
  mobile-broadband-provider-info \
  mt7xxx-firmware \
  nxpwireless-firmware \
  open-vm-tools \
  open-vm-tools-desktop \
  openconnect \
  pam_yubico \
  pcsc-lite \
  plymouth \
  plymouth-system-theme \
  printer-driver-brlaser \
  qemu-guest-agent \
  realtek-firmware \
  rsync \
  spice-vdagent \
  steam-devices \
  switcheroo-control \
  system-config-printer-libs \
  system-config-printer-udev \
  systemd-container \
  systemd-oomd-defaults \
  tiwilink-firmware \
  tuned \
  tuned-ppd \
  unzip \
  whois \
  wireguard-tools \
  NetworkManager-openconnect \
  NetworkManager-openvpn \
  NetworkManager-libnm



  # WALL OF UNAVAILABLE
  # NetworkManager-config-connectivity-fedora \
  # NetworkManager-strongswan \
  # NetworkManager-ssh \
  # NetworkManager-ssh-selinux \
  # NetworkManager-vpnc \
  # usb_modeswitch \
  # uxplay \
  # vpnc \
  # zram-generator-defaults
  # ptouch-driver \
  # libratbag-ratbagd \
  # jmtpfs \
  # gvfs-nfs \
  # gvfs-archive \

dnf -y copr enable ublue-os/packages
dnf -y copr disable ublue-os/packages
dnf -y --enablerepo copr:copr.fedorainfracloud.org:ublue-os:packages install uupd ublue-os-udev-rules

if [ "$(rpm -E "%{fedora}")" == 43 ] ; then
  dnf -y copr enable ublue-os/flatpak-test
  dnf -y copr disable ublue-os/flatpak-test
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper
  rpm -q flatpak --qf "%{NAME} %{VENDOR}\n" | grep ublue-os
fi

# if [ "$(arch)" != "aarch64" ] ; then
#   dnf install -y \
#     virtualbox-guest-additions \
#     thermald \
#     powerstat
# fi

# THIS IS SO ANNOYING
# It just fails for whatever damn reason, other stuff is going to lock it if it actually fails
# yes | dnf -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras,-mesa} || :
# dnf config-manager setopt terra.enabled=0
# dnf config-manager setopt terra-extras.enabled=0
# dnf config-manager setopt terra-mesa.enabled=0

