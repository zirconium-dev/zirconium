#!/bin/bash

set -ouex pipefail

### Install Kernel Cachyos (Stole From Piperita)
for pkg in kernel kernel-core kernel-modules kernel-modules-core; do
  rpm --erase $pkg --nodeps
done

pushd /usr/lib/kernel/install.d
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x  05-rpmostree.install 50-dracut.install
popd

dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr disable bieszczaders/kernel-cachyos-lto
dnf -y --enablerepo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto install \
  kernel-cachyos-lto

dnf -y copr enable bieszczaders/kernel-cachyos-addons
dnf -y copr disable bieszczaders/kernel-cachyos-addons
dnf -y --enablerepo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-addons swap zram-generator-defaults cachyos-settings
dnf -y --enablerepo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-addons install \
  scx-scheds-git \
  scx-manager
  
tee /usr/lib/modules-load.d/ntsync.conf <<'EOF'
ntsync
EOF

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
export DRACUT_NO_XATTR=1
depmod -a "$(ls -1 /lib/modules/ | tail -1)"
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"

### Enable Nobara and install things
dnf -y copr enable gloriouseggroll/nobara-43
dnf -y --setopt=install_weak_deps=False install gpu-screen-recorder-ui falcond falcond-profiles falcond-gui mangohud mangojuice starship
dnf -y copr disable gloriouseggroll/nobara-43

### Lact from nobara is weird
dnf -y copr enable ilyaz/LACT
dnf -y install lact
dnf -y copr disable ilyaz/LACT

### Add mesa from negativo
dnf config-manager setopt fedora-multimedia.enabled=1
dnf -y swap --repo=fedora-multimedia mesa-filesystem mesa-filesystem 

### Add steam into base image
### I was using an container to install Steam but after an shower thinking its kinda dumb this image is to provide me an stable base
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo
dnf config-manager setopt fedora-steam.enabled=0
dnf -y  --setopt=install_weak_deps=False install --enablerepo=fedora-steam \
    -x PackageKit* \
    steam

### TODO: Move this to cleanup
dnf config-manager setopt fedora-multimedia.enabled=0

### Instal Hblock
dnf -y copr enable pesader/hblock
dnf -y install hblock
systemctl enable hblock.timer
dnf -y copr disable pesader/hblock

### Cachy firefox settings
mkdir -p /usr/lib/firefox/browser/defaults/preferences/
curl -X 'GET' 'https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/refs/heads/master/cachyos-firefox-settings/cachyos.js' > /usr/lib/firefox/browser/defaults/preferences/cachyos.js
mkdir -p /etc/firefox/policies/
curl -X 'GET' 'https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/refs/heads/master/cachyos-firefox-settings/policies.json' > /etc/firefox/policies/policies.json

### Install packages from repos
dnf -y --setopt=install_weak_deps=False install \
	kitty 	\
	neovim   \
	openrgb	  \
	openrgb-udev-rules \
	firefox

systemctl enable openrgb
systemctl enable lactd

echo 'LANG=pt_BR.UTF-8' | tee -a "/etc/locale.conf"
