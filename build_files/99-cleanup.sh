#!/usr/bin/env bash

# See https://github.com/CentOS/centos-bootc/issues/191
mkdir -p /var/roothome

HOME_URL="https://github.com/zirconium-dev/zirconium"
echo "zirconium" | tee "/etc/hostname"
# OS Release File (changed in order with upstream)
# TODO: change ANSI_COLOR
sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Zirconium\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Zirconium\"|
s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"Juno\"|
s|^VARIANT_ID=.*|VARIANT_ID=""|
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${HOME_URL}/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"${HOME_URL}/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:zirconium-dev:zirconium\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"${HOME_URL}\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="zirconium"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF

# Add Flathub to the image for eventual application
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# GO AWAY fedora flatpaks.
rm -rf /usr/lib/systemd/system/flatpak-add-fedora-repos.service
systemctl enable flatpak-add-flathub-repos.service

# Saves a ton of space 6767 :steamhappy:
rm -rf /usr/share/doc
rm -rf /usr/bin/chsh # footgun

systemctl enable rechunker-group-fix.service

# REQUIRED for dms-greeter to work
tee /usr/lib/sysusers.d/greeter.conf <<'EOF'
g greeter 6767
u greeter 6767 "Greetd greeter"
EOF

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"

