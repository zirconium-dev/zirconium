#!/bin/bash

echo "Netbird installation"

tee /etc/yum.repos.d/netbird.repo <<EOF
[netbird]
name=netbird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=0
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1
EOF

dnf config-manager -y addrepo --from-repofile=/etc/yum.repos.d/netbird.repo
dnf install -y libappindicator-gtk3 libappindicator netbird-ui
