#!/bin/bash

set -xeuo pipefail

install -d /usr/share/zirconium/

dnf -y copr enable yalter/niri-git
dnf -y copr disable yalter/niri-git
echo "priority=1" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri-git.repo
dnf -y --enablerepo copr:copr.fedorainfracloud.org:yalter:niri-git install niri
rm -rf /usr/share/doc/niri

dnf -y copr enable avengemedia/danklinux
dnf -y copr disable avengemedia/danklinux
dnf -y --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux install quickshell-git

dnf -y copr enable avengemedia/dms-git
dnf -y copr disable avengemedia/dms-git
dnf -y \
    --enablerepo copr:copr.fedorainfracloud.org:avengemedia:dms-git \
    --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux \
    install --setopt=install_weak_deps=False \
    dms \
    dms-cli \
    dms-greeter \
    dgop

dnf -y copr enable zirconium/packages
dnf -y copr disable zirconium/packages
dnf -y --enablerepo copr:copr.fedorainfracloud.org:zirconium:packages install \
    matugen \
    cliphist

dnf -y remove alacritty
dnf -y install \
    brightnessctl \
    cava \
    chezmoi \
    ddcutil \
    fastfetch \
    flatpak \
    foot \
    fpaste \
    fzf \
    gamescope \
    git-core \
    glycin-thumbnailer \
    gnome-keyring \
    gnome-keyring-pam \
    greetd \
    greetd-selinux \
    input-remapper \
    just \
    nautilus \
    orca \
    pipewire \
    steam-devices \
    tuigreet \
    udiskie \
    webp-pixbuf-loader \
    wireplumber \
    wl-clipboard \
    wlsunset \
    xdg-desktop-portal-gnome \
    xdg-user-dirs \
    xwayland-satellite
rm -rf /usr/share/doc/just
ln -s footclient /usr/bin/ghostty

dnf install -y --setopt=install_weak_deps=False \
    kf6-kirigami \
    qt6ct \
    polkit-kde \
    plasma-breeze \
    kf6-qqc2-desktop-style

sed -i '/gnome_keyring.so/ s/-auth/auth/ ; /gnome_keyring.so/ s/-session/session/' /etc/pam.d/greetd
cat /etc/pam.d/greetd

# Codecs for video thumbnails on nautilus
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf config-manager setopt fedora-multimedia.enabled=0
dnf -y install --enablerepo=fedora-multimedia \
    ffmpeg libavcodec @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl ffmpegthumbnailer

add_wants_niri() {
    sed -i "s/\[Unit\]/\[Unit\]\nWants=$1/" "/usr/lib/systemd/user/niri.service"
}
add_wants_niri cliphist.service
add_wants_niri swayidle.service
add_wants_niri udiskie.service
add_wants_niri foot.service
add_wants_niri xwayland-satellite.service
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

systemctl enable flatpak-preinstall.service
systemctl enable --global chezmoi-init.service
systemctl enable --global foot.service
systemctl enable --global chezmoi-update.timer
systemctl enable --global dms.service
systemctl enable --global cliphist.service
systemctl enable --global gnome-keyring-daemon.socket
systemctl enable --global gnome-keyring-daemon.service
systemctl enable --global swayidle.service
systemctl enable --global udiskie.service
systemctl enable --global xwayland-satellite.service
systemctl preset --global chezmoi-init
systemctl preset --global chezmoi-update
systemctl preset --global cliphist
systemctl preset --global swayidle
systemctl preset --global udiskie
systemctl preset --global foot
systemctl preset --global xwayland-satellite

git clone "https://github.com/noctalia-dev/noctalia-shell.git" /usr/share/zirconium/noctalia-shell
cp /usr/share/zirconium/skel/Pictures/Wallpapers/mountains.png /usr/share/zirconium/noctalia-shell/Assets/Wallpaper/noctalia.png
cp -rf /usr/share/zirconium/skel/* /etc/skel
git clone "https://github.com/zirconium-dev/zdots.git" /usr/share/zirconium/zdots
install -d /etc/niri/
cp -f /usr/share/zirconium/zdots/dot_config/niri/config.kdl /etc/niri/config.kdl
file /etc/niri/config.kdl | grep -F -e "empty" -v
stat /etc/niri/config.kdl

fc-cache --force --really-force --system-only --verbose # recreate font-cache to pick up the added fonts

echo 'source /usr/share/zirconium/shell/pure.bash' | tee -a "/etc/bashrc"
