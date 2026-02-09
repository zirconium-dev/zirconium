#!/usr/bin/env bash

set -xeuo pipefail

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

# GO AWAY fedora flatpaks.
rm -rf /usr/lib/systemd/system/flatpak-add-fedora-repos.service
systemctl enable flatpak-add-flathub-repos.service

rm -rf /usr/bin/chsh # footgun

systemctl enable rechunker-group-fix.service

# These files NEED to be on the image.
grep -F -e "ghcr.io/zirconium-dev" /etc/containers/policy.json
stat /usr/share/pki/containers/zirconium.pub
stat /usr/share/pki/containers/jackrabbit.pub
stat /usr/bin/luks*tpm*
stat /usr/bin/uupd
stat /usr/lib/systemd/system/uupd.service
stat /usr/lib/systemd/system/uupd.timer

# Symlinks.
rm -rfv /opt /usr/local
ln -s /var/usrlocal /usr/local
ln -s /var/opt /
