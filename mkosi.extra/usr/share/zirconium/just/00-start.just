zdots_path := "/usr/share/zirconium/zdots"

default:
    @zjust --choose

update-dotfiles:
    #!/usr/bin/env bash
    echo "Updating non-overwritten dotfiles to their latest in-image state"
    yes s | chezmoi apply --no-tty --keep-going -S "{{ zdots_path }}" --verbose --config "$HOME/.config/zirconium/chezmoi/chezmoi.toml" &>/dev/null
    echo "Updated dotfiles. This should not have touched anything on your system that you've configured yourself."

_zdots-reset $FILE="":
    #!/usr/bin/env bash
    if [ "${FILE}" == "" ] ; then
        echo "This recipe is for resetting a specific file from the config to default again, do not use if you don't know what this does!"
        exit 0
    fi

    chezmoi apply --force -S "{{ zdots_path }}" --verbose --config "$HOME/.config/zirconium/chezmoi/chezmoi.toml" "${FILE}"

reset-all-configs:
    #!/usr/bin/env bash
    if gum confirm --confirm=no "Are you sure you want to reset all your configuration?" ; then
        chezmoi apply --force -S "{{ zdots_path }}" --verbose --config "$HOME/.config/zirconium/chezmoi/chezmoi.toml"
    fi

# Toggle display of the user-motd in terminal
toggle-user-motd:
    #!/usr/bin/bash
    if [ -e "${HOME}/.config/zirconium/no-show-user-motd" ] ; then
        if gum confirm "Would you like to enable the MOTD?" ; then
            rm -f "${HOME}/.config/zirconium/no-show-user-motd"
            echo "MOTD will now be shown on login."
            exit 0
        fi
    fi
    if gum confirm "Would you like to disable the MOTD?" ; then
        mkdir -p "${HOME}/.config"
        touch "${HOME}/.config/zirconium/no-show-user-motd"
        echo "MOTD will not be shown anymore"
        exit 0
    fi

toggle-autorotation:
    #!/usr/bin/env bash

    if systemctl is-enabled --quiet --user iio-niri ; then
        if gum confirm "Would you like to disable autorotation?" ; then
            systemctl disable --quiet --now --user iio-niri.service
            systemctl mask --quiet --now --user iio-niri.service
            echo "Disabled autorotation"
            exit 0
        fi
    else
        if gum confirm "Would you like to enable autorotation?" ; then
            systemctl unmask --quiet --user iio-niri.service
            systemctl enable --quiet --now --user iio-niri.service
            echo "Enabled autorotation"
            exit 0
        fi
    fi

toggle-automatic-dotfiles:
    #!/usr/bin/env bash

    if systemctl is-enabled --quiet --user chezmoi-update.timer ; then
        if gum confirm --default=no "Would you like to disable automatic dotfile updates?" ; then
            systemctl disable --quiet --now --user chezmoi-update.timer
            systemctl mask --quiet --now --user chezmoi-update.timer
            systemctl disable --quiet --now --user chezmoi-init.service
            systemctl mask --quiet --user chezmoi-init.service
            echo "Disabled dotfile updates"
            exit 0
        fi
    else
        if gum confirm "Would you like to enable dotfiles updates?" ; then
            systemctl unmask --quiet --user chezmoi-init.service
            systemctl enable --quiet --user chezmoi-init.service
            systemctl unmask --quiet --user chezmoi-update.timer
            systemctl enable --quiet --now --user chezmoi-update.timer
            echo "Enabled dotfile updates"
            exit 0
        fi
    fi

toggle-fcitx5:
    #!/usr/bin/env bash

    if systemctl is-enabled --quiet --user fcitx5 ; then
        if gum confirm "Would you like to disable fcitx5?" ; then
            systemctl disable --quiet --now --user fcitx5.service
            systemctl mask --quiet --now --user fcitx5.service
            echo "Disabled fcitx5"
            exit 0
        fi
    else
        if gum confirm "Would you like to enable fcitx5?" ; then
            systemctl unmask --quiet --user fcitx5.service
            systemctl enable --quiet --now --user fcitx5.service
            echo "Enabled fcitx5"
            exit 0
        fi
    fi

preinstalled-flatpaks:
    #!/usr/bin/env bash
    if gum confirm "Would you like to (re)install the preinstalled flatpaks?" ; then
        flatpak preinstall --reinstall
    fi

reset-niri:
    #!/usr/bin/env bash
    if gum confirm "Are you sure you want to reset your niri configuration?" ; then
        zjust _zdots-reset "${HOME}/.config/niri"
    fi

update-greeter:
    dms greeter sync

# Turn automatic updates on or off
toggle-updates ACTION="prompt":
    #!/usr/bin/bash
    CURRENT_STATE="disabled"
    if systemctl cat -- uupd.timer &> /dev/null; then
        TIMER="uupd.timer"
    else
        TIMER="rpm-ostreed-automatic.timer"
    fi
    CURRENT_STATE="$(systemctl is-enabled "${TIMER}")"

    if [ "${CURRENT_STATE}" == "enabled" ] ; then
        if gum confirm --default=no "Would you like to disable automatic updates?" ; then
            sudo systemctl enable "$TIMER"
            echo "Updates have been enabled"
        fi
    else
        if gum confirm --default=yes "Would you like to enable automatic updates?" ; then
            sudo systemctl disable "$TIMER"
            echo "Updates have been disabled"
        fi
    fi

# TPM2 auto-unlock toggle
toggle-tpm2:
    @/usr/bin/luks-tpm2-autounlock

# Check for local overrides
check-local-overrides:
    #!/usr/bin/bash
    RESET="\x1b[0m"
    if [ "${NO_COLOR}" == 1 ]; then
        BLUE_COLOR=""
        GREEN_COLOR=""
        YELLOW_COLOR=""
    else
        BLUE_COLOR="${BLUE_COLOR:-\x1b[38;5;117m}"
        GREEN_COLOR="${GREEN_COLOR:-\x1b[38;5;85m}"
        YELLOW_COLOR="${YELLOW_COLOR:-\x1b[93m}"
    fi

    sudo diff -qr \
        --suppress-common-lines \
        --color="always" \
        --exclude "passwd*" \
        --exclude "group*" \
        --exclude="subgid*" \
        --exclude="subuid*" \
        --exclude="machine-id" \
        --exclude="adjtime" \
        --exclude="fstab" \
        --exclude="system-connections" \
        --exclude="shadow*" \
        --exclude="gshadow*" \
        --exclude="ssh_host*" \
        --exclude="cmdline" \
        --exclude="crypttab" \
        --exclude="hostname" \
        --exclude="localtime" \
        --exclude="locale*" \
        --exclude="*lock" \
        --exclude=".updated" \
        --exclude="*LOCK" \
        --exclude="vconsole*" \
        --exclude="00-keyboard.conf" \
        --exclude="grub" \
        --exclude="system.control*" \
        --exclude="cdi" \
        --exclude="default.target" \
        /usr/etc /etc 2>/dev/null | sed \
            -e '/Binary\ files\ /d ; /Common subdirectories/d' \
            -e "/Files/ s/^/${BLUE_COLOR}&/g" \
            -e "/Files/ s/\$/&${RESET}/g" \
            -e "/Only in/ s/^/${GREEN_COLOR}&/g" \
            -e "/Only in/ s/\$/&${RESET}/g" \
            -e "s/\:.*/${RESET}${YELLOW_COLOR}&${RESET}/g"

# Gather device info to a pastebin
generate-bug-report:
    #!/usr/bin/bash
    if ! gum confirm "Submit information to the CentOS pastebin?" ; then
        exit 0
    fi

    REPORT_DATA="$(mktemp)"
    trap 'rm ${REPORT_DATA}' EXIT
    cat &> "${REPORT_DATA}" <<EOF
    --#--# sudo bootc status --verbose:
    $(sudo bootc status --verbose)
    --#--# fpaste --sysinfo --printonly:
    $(fpaste --sysinfo --printonly)
    --#--# flatpak list --columns=application,version,options:
    $(flatpak list --columns=application,version,options)
    --#-# BIOS info:
    Manufacturer:
    $(dmidecode -s baseboard-manufacturer 2>/dev/null)
    Product Name:
    $(dmidecode -s baseboard-product-name 2>/dev/null)
    Version:
    $(dmidecode -s bios-version 2>/dev/null)
    Release Date:
    $(dmidecode -s bios-release-date 2>/dev/null)
    EOF

    gzip -9c $REPORT_DATA | base64 | fpaste -t "zirconium report $(date +%Y%m%d%H%M%S)" --private=1
