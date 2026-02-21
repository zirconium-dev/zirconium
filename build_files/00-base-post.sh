#!/bin/bash

set -xeuo pipefail

cp -avf "/ctx/files"/. /

sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service
sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

# keep in sync with zirconium preset file
systemctl preset auditd.service
systemctl preset bootc-fetch-apply-updates.service
systemctl preset brew-setup.service
systemctl preset firewalld.service
systemctl preset flatpak-preinstall.service
systemctl preset systemd-resolved.service
systemctl preset systemd-resolved.service
# systemctl preset systemd-timesyncd.service
systemctl preset uupd.timer
