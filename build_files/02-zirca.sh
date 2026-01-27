#!/bin/bash

set -ouex pipefail

### Install Starship
dnf -y copr enable atim/starship
dnf -y install starship
dnf -y copr disable atim/starship

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

### Install LACT
dnf -y copr enable ilyaz/LACT
dnf -y install lact
systemctl enable lactd
dnf -y copr disable ilyaz/LACT

### Install Gpu Screen Recorder
dnf -y copr enable brycensranch/gpu-screen-recorder-git
dnf -y install gpu-screen-recorder-ui
dnf -y copr disable brycensranch/gpu-screen-recorder-git

### Instal Hblock
dnf -y copr enable pesader/hblock
dnf -y install hblock
systemctl enable hblock.timer
dnf -y copr disable pesader/hblock

### Install Falcon Gamemode and Mesa from Terra
dnf -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras,-mesa} 
dnf -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade scx-tools scx-scheds steam python3-protobuf zlib-devel"  
dnf -y config-manager setopt "terra-mesa".enabled=true   
dnf -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*" 
dnf -y swap --repo=terra-mesa mesa-filesystem mesa-filesystem 
dnf -y install falcond falcond-profiles falcond-gui
# Not being added into falcond group hope this helps
getent group 'falcond' >/dev/null || groupadd -f -r 'falcond' || :
usermod -aG 'falcond' root || :


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

echo 'LANG=pt_BR.UTF-8' | tee -a "/etc/locale.conf"
