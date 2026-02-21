# Zirconium : Serious Edition X
***Do you like how I ~~dance~~ am serious? I've got a Zirconium ~~pants~~ tuxedo!***

Based on Centos 10 with Zirconium things

<img width="2140" height="1332" alt="image" src="https://github.com/user-attachments/assets/63603c6e-df6c-4869-8d02-489b7631b46d" />

## What is Zirconium?
Zirconium is an opinionated fedora-bootc image that makes use of Niri and DankMaterialShell to create a usable out of the box TWM experience.

Zirconium is built primarily for container-focused development and day-to-day usage, however gaming is still more than possible. For a fully gaming-focused experience, use Bazzite.

## How do I use this?
There is no ISO, rebase from Bluefin-LTS or another RHEL10-Like distro

Alternatively, you can install Zirconium by doing a rebase from an existing Fedora Atomic install. We recommend [Bluefin](https://projectbluefin.io/), but it doesn't really matter.

Once you have some flavour of Fedora Atomic installed, run this command:

```
sudo bootc switch ghcr.io/zirconium-dev/zirconium:latest
```

If you also have NVIDIA GPU (GTX 16xx or RTX series), run this command instead:

```
sudo bootc switch ghcr.io/zirconium-dev/zirconium-nvidia:latest
```

[Join our Discord](https://discord.gg/mmgNQpxwhW)!

## Notice about Nvidia GPUs

No Nvdia

## Disclamers

Important missings:
- Foot (replaced by Ptyxis)
- Tailscale (Soon)
- Udiskie
- fcitx5
- Video thumbnails in Nautilus

This uses many custom repo to make CentOS usable
- EPEL10
- yselkowitz/wlroots-epel
- ligenix/enterprise-cosmic (greetd only)
- yalter/niri-git
- avengemedia/danklinux
- ublue-os/packages
- Terra

## Can I still customize Niri/DankMaterialShell?
Yes! We do update our dotfiles in OS updates, however you're not forced to use them. We're hoping at some point to be able to make the dotfile update process less destructive. 

## Zirconium is a stupid name. Why did you pick Zirconium?
A weird wax baby made me.

[![Tally Hall - Ruler of Everything](https://img.youtube.com/vi/I8sUC-dsW8A/0.jpg)](https://www.youtube.com/watch?v=I8sUC-dsW8A)
