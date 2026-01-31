#!/bin/bash

set -xeuo pipefail

install -d /usr/share/zirconium/

dnf -y copr enable zirconium/packages
dnf -y copr disable zirconium/packages
dnf -y --enablerepo copr:copr.fedorainfracloud.org:zirconium:packages install \
    matugen \
    iio-niri \
    valent-git

dnf -y copr enable yalter/niri-git
dnf -y copr disable yalter/niri-git
echo "priority=1" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri-git.repo
dnf -y --enablerepo copr:copr.fedorainfracloud.org:yalter:niri-git \
    install --setopt=install_weak_deps=False \
    niri
rm -rf /usr/share/doc/niri

dnf -y copr enable avengemedia/danklinux
dnf -y copr disable avengemedia/danklinux
dnf -y --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux install quickshell-git

dnf -y copr enable shadowblip/InputPlumber
dnf -y copr disable shadowblip/InputPlumber
# FIXME: remove once https://github.com/ShadowBlip/InputPlumber/pull/481 is merged and published to COPR
dnf -y --enablerepo copr:copr.fedorainfracloud.org:shadowblip:InputPlumber \
    install --setopt=install_weak_deps=False \
    inputplumber || true
inputplumber --version | grep -E -e "inputplumber [[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*"

dnf -y copr enable avengemedia/dms-git
dnf -y copr disable avengemedia/dms-git
dnf -y \
    --enablerepo copr:copr.fedorainfracloud.org:avengemedia:dms-git \
    --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux \
    install --setopt=install_weak_deps=False \
    dms \
    dms-cli \
    dms-greeter \
    dgop \
    dsearch
install -Dpm0644 -t /usr/lib/pam.d/ /usr/share/quickshell/dms/assets/pam/* # Fixes long login times on fingerprint auth

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
    git-core \
    glycin-thumbnailer \
    gnome-disk-utility \
    gnome-keyring \
    gnome-keyring-pam \
    greetd \
    greetd-selinux \
    hyfetch \
    input-remapper \
    just \
    nautilus \
    nautilus-python \
    openssh-askpass \
    orca \
    pipewire \
    playerctl \
    qt6-qtmultimedia \
    steam-devices \
    udiskie \
    webp-pixbuf-loader \
    wireplumber \
    wl-clipboard \
    wl-mirror \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    xdg-terminal-exec \
    xdg-user-dirs \
    xwayland-satellite

# we already have a service for handling fcitx5
rm -f /usr/share/applications/fcitx5-wayland-launcher.desktop
rm -f /usr/share/applications/org.fcitx.Fcitx5*.desktop

# just breaks ostree deployments
rm -rf /usr/share/doc/just

dnf install -y --setopt=install_weak_deps=False \
    kf6-kirigami \
    qt6ct \
    plasma-breeze \
    kf6-qqc2-desktop-style

sed --sandbox -i -e '/gnome_keyring.so/ s/-auth/auth/ ; /gnome_keyring.so/ s/-session/session/' /etc/pam.d/greetd

# Codecs for video thumbnails on nautilus
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf config-manager setopt fedora-multimedia.enabled=0
dnf -y install --enablerepo=fedora-multimedia \
    -x PackageKit* \
    ffmpeg libavcodec @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl ffmpegthumbnailer

add_wants_niri() {
    sed -i "s/\[Unit\]/\[Unit\]\nWants=$1/" "/usr/lib/systemd/user/niri.service"
}
add_wants_niri udiskie.service
add_wants_niri foot-server.service
cat /usr/lib/systemd/user/niri.service

systemctl enable greetd
systemctl enable firewalld

# Sacrificed to the :steamhappy: emoji old god
dnf install -y \
    default-fonts-core-emoji \
    google-noto-color-emoji-fonts \
    google-noto-emoji-fonts \
    glibc-all-langpacks \
    default-fonts

cp -avf "/ctx/files"/. /

systemctl enable --global chezmoi-init.service
systemctl enable --global chezmoi-update.timer
systemctl enable --global dms.service
systemctl enable --global foot-server.service
systemctl enable --global fcitx5.service
systemctl enable --global gnome-keyring-daemon.service
systemctl enable --global gnome-keyring-daemon.socket
systemctl enable --global iio-niri.service
systemctl enable --global udiskie.service
systemctl preset --global chezmoi-init
systemctl preset --global chezmoi-update
systemctl preset --global foot-server
systemctl preset --global udiskie
systemctl enable brew-setup.service
systemctl enable flatpak-preinstall.service

git clone "https://github.com/zirconium-dev/zdots.git" /usr/share/zirconium/zdots
install -Dpm0644 -t /usr/share/plymouth/themes/spinner/ /ctx/assets/logos/watermark.png
install -Dpm0644 -t /usr/share/zirconium/skel/Pictures/Wallpapers/ /ctx/assets/wallpapers/*
install -Dpm0644 -t /usr/share/zirconium/pixmaps/ /ctx/assets/logos/logo-z.svg

mkdir -p "/usr/share/fonts/Maple Mono"

XDG_EXT_TMPDIR="$(mktemp -d)"
curl -fsSLo - "$(curl -fsSL https://api.github.com/repos/tulilirockz/xdg-terminal-exec-nautilus/releases/latest | jq -rc .tarball_url)" | tar -xzvf - -C "${XDG_EXT_TMPDIR}"
install -Dpm0644 -t "/usr/share/nautilus-python/extensions/" "${XDG_EXT_TMPDIR}"/*/xdg-terminal-exec-nautilus.py
rm -rf "${XDG_EXT_TMPDIR}"

MAPLE_TMPDIR="$(mktemp -d)"
LATEST_RELEASE_FONT="$(curl --retry 3 "https://api.github.com/repos/subframe7536/maple-font/releases/latest" | jq '.assets[] | select(.name == "MapleMono-Variable.zip") | .browser_download_url' -rc)"
curl --retry 3 -fSsLo "${MAPLE_TMPDIR}/maple.zip" "${LATEST_RELEASE_FONT}"
unzip "${MAPLE_TMPDIR}/maple.zip" -d "/usr/share/fonts/Maple Mono"
rm -rf "${MAPLE_TMPDIR}"

MAPLE_NF_TMPDIR="$(mktemp -d)"
LATEST_RELEASE_FONT="$(curl --retry 3 "https://api.github.com/repos/subframe7536/maple-font/releases/latest" | jq '.assets[] | select(.name == "MapleMono-NF.zip") | .browser_download_url' -rc)"
curl --retry 3 -fSsLo "${MAPLE_NF_TMPDIR}/maple.zip" "${LATEST_RELEASE_FONT}"
unzip "${MAPLE_NF_TMPDIR}/maple.zip" -d "/usr/share/fonts/Maple Mono NF"
rm -rf "${MAPLE_NF_TMPDIR}"

fc-cache --force --really-force --system-only --verbose # recreate font-cache to pick up the added fonts

echo 'source /usr/share/zirconium/shell/pure.bash' | tee -a "/etc/bashrc"

tee /usr/lib/tmpfiles.d/99-greeter-config.conf <<'EOF'
L /var/cache/dms-greeter/settings.json - greeter greeter - /usr/share/zirconium/zdots/dot_config/DankMaterialShell/settings.json
L /var/cache/dms-greeter/session.json - greeter greeter - /usr/share/zirconium/zdots/private_dot_local/state/DankMaterialShell/session.json
L /var/cache/dms-greeter/dms-colors.json - greeter greeter - /usr/share/zirconium/zdots/dot_cache/DankMaterialShell/dms-colors.json
L /var/cache/dms-greeter/colors.json - greeter greeter - /usr/share/zirconium/zdots/dot_cache/DankMaterialShell/dms-colors.json
EOF

install -d /usr/share/bash-completion/completions /usr/share/zsh/site-functions /usr/share/fish/vendor_completions.d/
just --completions bash | sed -E 's/([\(_" ])just/\1zjust/g' > /usr/share/bash-completion/completions/zjust
just --completions zsh | sed -E 's/([\(_" ])just/\1zjust/g' > /usr/share/zsh/site-functions/_zjust
just --completions fish | sed -E 's/([\(_" ])just/\1zjust/g' > /usr/share/fish/vendor_completions.d/zjust.fish
