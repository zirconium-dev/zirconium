#!/bin/bash

set -xeuo pipefail

# dnf -y copr enable zirconium/packages
# dnf -y copr disable zirconium/packages
# dnf -y --enablerepo copr:copr.fedorainfracloud.org:zirconium:packages install \
#     matugen \
#     iio-niri \
#     valent-git

dnf config-manager --set-enabled crb

dnf -y copr enable yalter/niri-git
dnf -y copr disable yalter/niri-git

dnf -y copr enable yselkowitz/wlroots-epel
dnf -y copr disable yselkowitz/wlroots-epel

dnf -y copr enable ligenix/enterprise-cosmic rhel+epel-10-x86_64
dnf -y copr disable ligenix/enterprise-cosmic

dnf install -y greetd --repo=copr:copr.fedorainfracloud.org:ligenix:enterprise-cosmic

# dnf -y config-manager setopt copr:copr.fedorainfracloud.org:yalter:niri-git.priority=1
dnf -y --enablerepo copr:copr.fedorainfracloud.org:yalter:niri-git install --setopt=install_weak_deps=False \
    niri

dnf -y copr enable avengemedia/danklinux
dnf -y copr disable avengemedia/danklinux
dnf -y --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux install quickshell-git

dnf -y copr enable avengemedia/dms-git
dnf -y copr disable avengemedia/dms-git
dnf -y --enablerepo copr:copr.fedorainfracloud.org:avengemedia:dms-git --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux install --setopt=install_weak_deps=False \
    dms \
    dms-cli \
    dms-greeter \
    matugen \
    dgop \
    danksearch

dnf -y install --enablerepo copr:copr.fedorainfracloud.org:yselkowitz:wlroots-epel \
    chezmoi \
    ddcutil \
    fastfetch \
    flatpak \
    ptyxis \
    fpaste \
    fzf \
    git-core \
    gnome-disk-utility \
    gnome-keyring \
    gnome-keyring-pam \
    greetd \
    greetd-selinux \
    just \
    nautilus \
    nautilus-python \
    openssh-askpass \
    orca \
    pipewire \
    qt6-qtmultimedia \
    steam-devices \
    webp-pixbuf-loader \
    wireplumber \
    wl-clipboard \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    xdg-terminal-exec \
    xdg-user-dirs \
    xwayland-satellite \
    wtype \
    brightnessctl \
    playerctl \
    wl-mirror

# Missing:
# cava \
# hyfetch \
# input-remapper \
# fcitx5-mozc \
# foot (replace by ptyxis)
# glycin-thumbnailer \
# gnupg2-scdaemon \
# khal \
# tailscale \
# udiskie \
# ykman

dnf install -y --setopt=install_weak_deps=False \
    kf6-kirigami \
    qt6ct \
    plasma-breeze \
    kf6-qqc2-desktop-style

# Codecs for video thumbnails on nautilus //TODO
# dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
# dnf config-manager setopt fedora-multimedia.enabled=0
# dnf -y install --enablerepo=fedora-multimedia \
#     -x PackageKit* \
#     ffmpeg libavcodec @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl ffmpegthumbnailer

# Sacrificed to the :steamhappy: emoji old god
dnf install -y \
    default-fonts-core-emoji \
    google-noto-color-emoji-fonts \
    google-noto-emoji-fonts \
    glibc-all-langpacks \
    default-fonts

git clone "https://github.com/zirconium-dev/zdots.git" /usr/share/zirconium/zdots

XDG_EXT_TMPDIR="$(mktemp -d)"
curl -fsSLo - "$(curl -fsSL https://api.github.com/repos/tulilirockz/xdg-terminal-exec-nautilus/releases/latest | jq -rc .tarball_url)" | tar -xzvf - -C "${XDG_EXT_TMPDIR}"
install -Dpm0644 -t "/usr/share/nautilus-python/extensions/" "${XDG_EXT_TMPDIR}"/*/xdg-terminal-exec-nautilus.py
rm -rf "${XDG_EXT_TMPDIR}"

# THIS IS SO ANNOYING
# It just fails for whatever damn reason, other stuff is going to lock it if it actually fails
# yes | dnf -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras,-mesa} || :
# dnf config-manager setopt terra.enabled=0
# dnf config-manager setopt terra-extras.enabled=0
# dnf config-manager setopt terra-mesa.enabled=0
# dnf install -y --enablerepo=terra maple-fonts

# These need to be here because having them on the layers breaks everything
rm -rf /usr/share/doc/niri
rm -rf /usr/share/doc/just
