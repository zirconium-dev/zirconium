zdots_path := "/usr/share/zirconium/zdots"

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

switch-to-noctalia:
    #!/usr/bin/env bash
    sed -i "s@include \"dms.kdl\"@\/\/ include \"dms.kdl\"@" $HOME/.config/niri/config.kdl
    sed -i "s@\/\/ include \"noctalia.kdl\"@include \"noctalia.kdl\"@" $HOME/.config/niri/config.kdl
    systemctl mask --now --user dms.service
    systemctl unmask --user noctalia.service
    systemctl enable --now --user noctalia.service

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

update:
    sudo uupd

tpm2:
    #!/usr/bin/env bash
    if ! command -v gum &>/dev/null ; then
        echo "This script requires gum to run, install it: brew install gum"
        exit 1
    fi
    /usr/bin/luks-tpm2-autounlock
