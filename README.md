# Zirconium
***Do you like how I dance? I've got Zirconium pants!***

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/73e4e017-893b-46fc-b6ce-351c176d444c" />

## What is Zirconium?
Zirconium is an opinionated fedora-bootc image that makes use of Niri and DankMaterialShell to create a usable out of the box TWM experience.

Zirconium is built primarily for container-focused development and day-to-day usage, however gaming is still more than possible. For a fully gaming-focused experience, use Bazzite.

## How do I use this?
The best way to install Zirconium is to download our ISOs! Pick your flavor:

- AMD64
  - **[AMD/Intel GPUs](https://isos.zirconium.gay/zirconium-isos/zirconium-amd64.iso)** ([Checksum](https://isos.zirconium.gay/zirconium-isos/zirconium-amd64.iso-CHECKSUM))
  - **[NVIDIA GPUs (GTX 16xx and RTX series)](https://isos.zirconium.gay/zirconium-isos/zirconium-nvidia-amd64.iso)** ([Checksum](https://isos.zirconium.gay/zirconium-isos/zirconium-nvidia-amd64.iso-CHECKSUM))
- ARM64
  - **[AMD/Intel GPUs](https://isos.zirconium.gay/zirconium-isos/zirconium-arm64.iso)** ([Checksum](https://isos.zirconium.gay/zirconium-isos/zirconium-arm64.iso-CHECKSUM))
  - **[NVIDIA GPUs (GTX 16xx and RTX series)](https://isos.zirconium.gay/zirconium-isos/zirconium-nvidia-arm64.iso)** ([Checksum](https://isos.zirconium.gay/zirconium-isos/zirconium-nvidia-arm64.iso-CHECKSUM))

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

Currently the Nvidia kernel module is not being signed so there is no way of using secure boot on the `-nvidia` images. ([related issue](https://github.com/zirconium-dev/zirconium/issues/108))

## Can I still customize Niri/DankMaterialShell?
Yes! We do update our dotfiles in OS updates, however you're not forced to use them. We're hoping at some point to be able to make the dotfile update process less destructive. 

## Zirconium is a stupid name. Why did you pick Zirconium?
A weird wax baby made me.

[![Tally Hall - Ruler of Everything](https://img.youtube.com/vi/I8sUC-dsW8A/0.jpg)](https://www.youtube.com/watch?v=I8sUC-dsW8A)
