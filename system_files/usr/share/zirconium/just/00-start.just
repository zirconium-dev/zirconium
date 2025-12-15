default:
    @zjust --choose

zdots-update:
    #!/usr/bin/env bash
    yes s | chezmoi apply --no-tty --keep-going -S "/usr/share/zirconium/zdots" --verbose --config "$HOME/.config/zirconium/chezmoi/chezmoi.toml"

zdots-reset FILE:
    #!/usr/bin/env bash
    chezmoi apply --force -S "/usr/share/zirconium/zdots" --verbose --config "$HOME/.config/zirconium/chezmoi/chezmoi.toml" {{FILE}}

zdots-override-all:
    #!/usr/bin/env bash
    chezmoi apply --force -S "/usr/share/zirconium/zdots" --verbose --config "$HOME/.config/zirconium/chezmoi/chezmoi.toml" 

toggle-user-motd:
    #!/usr/bin/env bash

    TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/zirconium/no-show-user-motd"

    if [ -e "$TARGET" ] ; then
         rm -r "${TARGET}"
         echo "Enabled the MOTD"
         exit 0
    fi
    mkdir -p "$(dirname "$(realpath ${TARGET})")"
    touch "${TARGET}"
    echo "Disabled the MOTD"

preinstalled-flatpaks:
    #!/usr/bin/env bash
    flatpak preinstall --reinstall

restart-shell:
    #!/usr/bin/env bash
    if systemctl is-active --quiet --user dms ; then
        systemctl restart --user dms
    elif systemctl is-active --quiet --user noctalia ; then
        systemctl restart --user noctalia
    fi

switch-to-dms:
    #!/usr/bin/env bash
    sed -i "s@include \"noctalia.kdl\"@\/\/ include \"noctalia.kdl\"@" $HOME/.config/niri/config.kdl
    sed -i "s@\/\/ include \"dms.kdl\"@include \"dms.kdl\"@" $HOME/.config/niri/config.kdl
    systemctl mask --now --user noctalia.service
    systemctl unmask --user dms.service
    systemctl enable --now --user dms.service
    systemctl disable --now --user swayidle.service

switch-to-noctalia:
    #!/usr/bin/env bash
    sed -i "s@include \"dms.kdl\"@\/\/ include \"dms.kdl\"@" $HOME/.config/niri/config.kdl
    sed -i "s@\/\/ include \"noctalia.kdl\"@include \"noctalia.kdl\"@" $HOME/.config/niri/config.kdl
    systemctl mask --now --user dms.service
    systemctl unmask --user noctalia.service
    systemctl enable --now --user noctalia.service
    systemctl enable --now --user swayidle.service

reset-niri:
    #!/usr/bin/env bash
    zjust zdots-reset "${HOME}/.config/niri"

update-greeter:
    dms greeter sync

# Update system, flatpaks, and brew all at once
update:
    #!/usr/bin/bash
    if systemctl cat -- uupd.timer &> /dev/null; then
        SERVICE="uupd.service"
    else
        SERVICE="rpm-ostreed-automatic.service"
    fi
    if systemctl is-active --quiet "$SERVICE"; then
        echo "automatic updates are currently running, use \`journalctl -fexu $SERVICE\` to see logs"
        exit 1
    fi
    if grep -E -e "LockLayering=false" /etc/rpm-ostreed.conf ; then
        rpm-ostree upgrade
    else
        sudo bootc upgrade
    fi
    # rpm-ostree used due to bootc upgrade not supporting local layered packages
    # Updates system Flatpaks
    if flatpak remotes | grep -q system; then
        flatpak update -y
    fi
    # Update user Flatpaks
    if flatpak remotes | grep -q user; then
        flatpak update --user -y
    fi
    # Guard Brew if the user does not own brew/doesn't exist
    if [[ -O /var/home/linuxbrew/.linuxbrew/bin/brew ]]; then
        # Upgrade will run brew update if needed
        /var/home/linuxbrew/.linuxbrew/bin/brew upgrade
    fi