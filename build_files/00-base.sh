#!/bin/bash

set -xeuo pipefail

systemctl enable systemd-timesyncd
systemctl enable systemd-resolved.service

dnf -y install 'dnf5-command(config-manager)'

# Speeds up local builds
dnf config-manager setopt keepcache=1

dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf config-manager setopt tailscale-stable.enabled=0
dnf -y install --enablerepo='tailscale-stable' tailscale

systemctl enable tailscaled

dnf -y remove \
  console-login-helper-messages \
  chrony \
  sssd* \
  qemu-user-static* \
  toolbox

# These were manually picked out from a Bluefin comparison with `rpm -qa --qf="%{NAME}\n" `
dnf -y install \
  -x PackageKit* \
  NetworkManager \
  NetworkManager-adsl \
  NetworkManager-bluetooth \
  NetworkManager-config-connectivity-fedora \
  NetworkManager-libnm \
  NetworkManager-openconnect \
  NetworkManager-openvpn \
  NetworkManager-strongswan \
  NetworkManager-ssh \
  NetworkManager-ssh-selinux \
  NetworkManager-vpnc \
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
  gvfs-archive \
  gvfs-mtp \
  gvfs-nfs \
  gvfs-smb \
  hplip \
  hyperv-daemons \
  ibus \
  ifuse \
  intel-audio-firmware \
  iwlegacy-firmware \
  iwlwifi-dvm-firmware \
  iwlwifi-mvm-firmware \
  jmtpfs \
  kernel-modules-extra \
  libcamera{,-{v4l2,gstreamer,tools}} \
  libimobiledevice \
  libimobiledevice-utils \
  libratbag-ratbagd \
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
  ptouch-driver \
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
  usb_modeswitch \
  uxplay \
  vpnc \
  whois \
  wireguard-tools \
  zram-generator-defaults

systemctl enable auditd
systemctl enable firewalld

sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

systemctl enable bootc-fetch-apply-updates

tee /usr/lib/systemd/system-preset/91-resolved-default.preset <<'EOF'
enable systemd-resolved.service
EOF
tee /usr/lib/tmpfiles.d/resolved-default.conf <<'EOF'
L /etc/resolv.conf - - - - ../run/systemd/resolve/stub-resolv.conf
EOF

systemctl preset systemd-resolved.service

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

if [ "$(arch)" != "aarch64" ] ; then
  dnf install -y \
    virtualbox-guest-additions \
    thermald \
    powerstat
fi
