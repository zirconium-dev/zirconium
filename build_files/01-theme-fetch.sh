#!/bin/bash

set -xeuo pipefail

dnf -y copr enable zirconium/packages
dnf -y copr disable zirconium/packages
dnf -y --enablerepo copr:copr.fedorainfracloud.org:zirconium:packages install \
    matugen \
    iio-niri \
    valent-git

dnf -y copr enable yalter/niri-git
dnf -y copr disable yalter/niri-git
dnf -y config-manager setopt copr:copr.fedorainfracloud.org:yalter:niri-git.priority=1
dnf -y --enablerepo copr:copr.fedorainfracloud.org:yalter:niri-git install --setopt=install_weak_deps=False \
    niri
niri --version | grep -i -E "niri [[:digit:]]*\.[[:digit:]]* (.*\.git\..*)"


dnf -y copr enable avengemedia/danklinux
dnf -y copr disable avengemedia/danklinux
dnf -y --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux install quickshell-git

dnf -y copr enable avengemedia/dms-git
dnf -y copr disable avengemedia/dms-git
dnf -y --enablerepo copr:copr.fedorainfracloud.org:avengemedia:dms-git --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux install --setopt=install_weak_deps=False \
    dms \
    dms-cli \
    dms-greeter \
    dgop \
    dsearch

dnf -y install \
    brightnessctl \
    cava \
    chezmoi \
    ddcutil \
    fastfetch \
    fcitx5-mozc \
    flatpak \
    foot \
    fpaste \
    fzf \
    gcr \
    git-core \
    glycin-thumbnailer \
    gnome-disk-utility \
    gnome-keyring \
    gnome-keyring-pam \
    gnupg2-scdaemon \
    greetd \
    greetd-selinux \
    hyfetch \
    input-remapper \
    just \
    kf6-kimageformats \
    khal \
    nautilus \
    nautilus-python \
    openssh-askpass \
    orca \
    pipewire \
    playerctl \
    qt6-qtmultimedia \
    steam-devices \
    tailscale \
    udiskie \
    webp-pixbuf-loader \
    wireplumber \
    wl-clipboard \
    wl-mirror \
    wtype \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    xdg-terminal-exec \
    xdg-user-dirs \
    xwayland-satellite \
    ykman

dnf install -y --setopt=install_weak_deps=False \
    kf6-kirigami \
    qt6ct \
    plasma-breeze \
    kf6-qqc2-desktop-style

# Codecs for video thumbnails on nautilus
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf config-manager setopt fedora-multimedia.enabled=0
dnf -y install --enablerepo=fedora-multimedia \
    -x PackageKit* \
    ffmpeg libavcodec @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl ffmpegthumbnailer

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
yes | dnf -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras} || :
dnf config-manager setopt terra.enabled=0
dnf config-manager setopt terra-extras.enabled=0
dnf install -y --enablerepo=terra maple-fonts

# These need to be here because having them on the layers breaks everything
rm -rf /usr/share/doc/niri
rm -rf /usr/share/doc/just
