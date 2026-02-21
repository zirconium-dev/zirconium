# Zirconium : Serious Edition X
***Do you like how I ~~dance~~ am serious? I've got a Zirconium ~~pants~~ tuxedo!***

Based on Centos 10 with Zirconium things

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9a007d51-524e-4af8-a9b7-5d2cfb6bedaf" />


## What is Zirconium?
Zirconium is an opinionated fedora-bootc image that makes use of Niri and DankMaterialShell to create a usable out of the box TWM experience.

Zirconium is built primarily for container-focused development and day-to-day usage, however gaming is still more than possible. For a fully gaming-focused experience, use Bazzite.

## How do I use this?
There is no ISO, rebase from Bluefin-LTS or another RHEL10-Like distro

Alternatively, you can install Zirconium by doing a rebase from an existing Fedora Atomic install. We recommend [Bluefin-LTS](https://projectbluefin.io/), but it doesn't really matter.

Once you have some flavour of RHEL10 Atomic installed, run this command:

```
sudo bootc switch ghcr.io/jumpyvi/zirconium-lts:latest-amd64
```


[Join our Discord](https://discord.gg/mmgNQpxwhW)!

## Notice about Nvidia GPUs

No Nvidia support planned

## Disclamers

Differences from Fedora Zirconium
- Foot swapped for Ptyxis
- Vim added
- nm-connection-editor added
- Docker-ce & Qemu (Soon)

Important missings:
- Udiskie
- fcitx5
- Video thumbnails in Nautilus
- Input-Remapper

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
