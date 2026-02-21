#!/usr/bin/env bash

if [[ ! "${BUILD_FLAVOR}" =~ "nvidia" ]] ; then
    exit 0
fi

set -xeuo pipefail

dnf -y install gcc-c++

dnf install -y --enablerepo=terra terra-release-nvidia
dnf config-manager setopt terra-nvidia.enabled=0
sed -i '/^enabled=/a\priority=90' /etc/yum.repos.d/terra-nvidia.repo
sed -r -i -e "s/(metalink)/#\1/" -e "s/#baseurl/baseurl/" /etc/yum.repos.d/terra-nvidia.repo
dnf -y install --enablerepo=terra-nvidia \
    -x nvidia-container-toolkit \
    dkms-nvidia || :

dnf -y install --enablerepo=terra-nvidia --enablerepo=terra \
    nvidia-driver-cuda libnvidia-fbc libva-nvidia-driver nvidia-driver nvidia-modprobe nvidia-persistenced nvidia-settings

NVIDIA_VERSION="$(basename "$(find /usr/src -iname "*nvidia-*" -type d -maxdepth 1)" | cut -d- -f2)"
# FIXME: remove once nvidia-open builds on 6.19 ootb https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1021#issuecomment-3875691676
if [ "${NVIDIA_VERSION}" == "590.48.01" ] ; then
    cd /usr/src/nvidia-$NVIDIA_VERSION
    curl -fsSLo cachy.patch https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/refs/heads/master/nvidia/nvidia-utils/kernel-6.19.patch
    git apply --stat cachy.patch
    git apply --check cachy.patch
    git apply < cachy.patch 
    cd /
fi

dnf -y install --enablerepo=terra-nvidia \
    nvidia-container-toolkit

curl --retry 3 -L "https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp" -o nvidia-container.pp
semodule -i nvidia-container.pp
rm -f nvidia-container.pp
