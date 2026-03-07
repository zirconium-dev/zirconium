zdots_path := "/usr/share/zirconium/zdots"

import "/usr/share/ublue-os/just/update.just"
import "/usr/share/ublue-os/just/shared.just"
import "/usr/share/ublue-os/just/default.just"
set allow-duplicate-recipes := true

default:
    @zjust --choose

zdots-update:
    #!/usr/bin/env bash
    yes s | chezmoi apply --no-tty --keep-going -S "{{ zdots_path }}" --verbose --config "$HOME/.config/zirconium/chezmoi/chezmoi.toml"

zdots-reset FILE:
    #!/usr/bin/env bash
    chezmoi apply --force -S "{{ zdots_path }}" --verbose --config "$HOME/.config/zirconium/chezmoi/chezmoi.toml" {{FILE}}

zdots-override-all:
    #!/usr/bin/env bash
    if ! command -v gum &>/dev/null ; then
        echo "This script requires gum to run, install it: brew install gum"
        exit 1
    fi
    if gum confirm "Are you sure you want to reset all your configuration?" ; then
        chezmoi apply --force -S "{{ zdots_path }}" --verbose --config "$HOME/.config/zirconium/chezmoi/chezmoi.toml" 
    fi

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

toggle-autorotation:
    #!/usr/bin/env bash

    if systemctl is-enabled --quiet --user iio-niri ; then
        systemctl disable --now --user iio-niri.service
        systemctl mask --now --user iio-niri.service
        echo "Disabled autorotation"
        exit 0
    else
        systemctl unmask --user iio-niri.service
        systemctl enable --now --user iio-niri.service
        echo "Enabled autorotation"
        exit 0
    fi

toggle-automatic-dotfiles:
    #!/usr/bin/env bash

    if systemctl is-enabled --quiet --user chezmoi-update.timer ; then
        systemctl disable --now --user chezmoi-update.timer
        systemctl mask --now --user chezmoi-update.timer
        systemctl disable --now --user chezmoi-init.service
        systemctl mask --user chezmoi-init.service
        echo "Disabled dotfile updates"
        exit 0
    else
        systemctl unmask --user chezmoi-init.service
        systemctl enable --user chezmoi-init.service
        systemctl unmask --user chezmoi-update.timer
        systemctl enable --now --user chezmoi-update.timer
        echo "Enabled dotfile updates"
        exit 0
    fi

toggle-fcitx5:
    #!/usr/bin/env bash

    if systemctl is-enabled --quiet --user fcitx5 ; then
        systemctl disable --now --user fcitx5.service
        systemctl mask --now --user fcitx5.service
        echo "Disabled fcitx5"
        exit 0
    else
        systemctl unmask --user fcitx5.service
        systemctl enable --now --user fcitx5.service
        echo "Enabled fcitx5"
        exit 0
    fi

preinstalled-flatpaks:
    #!/usr/bin/env bash
    flatpak preinstall --reinstall

reset-niri:
    #!/usr/bin/env bash
    if ! command -v gum &>/dev/null ; then
        echo "This script requires gum to run, install it: brew install gum"
        exit 1
    fi
    if gum confirm "Are you sure you want to reset your niri configuration?" ; then
        zjust zdots-reset "${HOME}/.config/niri"
    fi

update-greeter:
    dms greeter sync

enroll-secure-boot-key:
    #!/usr/bin/env bash
    echo "This is not implemented yet!"

alias set-accent-colour := set-accent-color

set-accent-color:
	gsettings set org.gnome.desktop.interface accent-color "$(gum choose blue teal green yellow orange red pink purple slate --limit 1 --header "Pick an accent colour")"
