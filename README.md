# Zirconium

***Do you like how I dance? I've got Zirconium pants!***

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/73e4e017-893b-46fc-b6ce-351c176d444c" />

## What is Zirconium?

Zirconium is an opinionated Fedora Bootc image that makes use of Niri and DMS to create a usable out of the box TWM experience.

Zirconium is built primarily for container-focused development and day-to-day usage, however gaming is still more than possible. For a fully gaming-focused experience, use Bazzite.

[Join our Discord](https://discord.gg/mmgNQpxwhW)!

## How do I use this?

### ISOs

> [!NOTE]
>
> Zirconium Jackrabbit, a gaming focused variant, currently doesn't have ISOs ready to use.
>
> Those who wants to use it are encouraged to install Zirconium and [rebase to Jackrabbit manually](#zirconium-jackrabbit).

The best way to install Zirconium is to download our ISOs! Pick your flavor:

- x86_64
  - **[AMD/Intel GPUs](https://isos.zirconium.gay/zirconium-isos/zirconium-amd64.iso)** ([Checksum](https://isos.zirconium.gay/zirconium-isos/zirconium-amd64.iso-CHECKSUM))
  - **[NVIDIA GPUs (GTX 16xx and RTX series)](https://isos.zirconium.gay/zirconium-isos/zirconium-nvidia-amd64.iso)** ([Checksum](https://isos.zirconium.gay/zirconium-isos/zirconium-nvidia-amd64.iso-CHECKSUM))
- ARM64
  - **[AMD/Intel GPUs](https://isos.zirconium.gay/zirconium-isos/zirconium-arm64.iso)** ([Checksum](https://isos.zirconium.gay/zirconium-isos/zirconium-arm64.iso-CHECKSUM))
  - **[NVIDIA GPUs (GTX 16xx and RTX series)](https://isos.zirconium.gay/zirconium-isos/zirconium-nvidia-arm64.iso)** ([Checksum](https://isos.zirconium.gay/zirconium-isos/zirconium-nvidia-arm64.iso-CHECKSUM))

### Manual rebase

Alternatively, you can install Zirconium by doing a rebase from an existing Fedora Atomic install. We recommend [Bluefin](https://projectbluefin.io/), but it doesn't really matter.

#### Zirconium

Once you have some flavour of Fedora Atomic installed, run this command:

```bash
sudo bootc switch ghcr.io/zirconium-dev/zirconium:latest
```

If you also have NVIDIA GPU (GTX 16xx or RTX series), run this command instead:

```bash
sudo bootc switch ghcr.io/zirconium-dev/zirconium-nvidia:latest
```

#### Zirconium Jackrabbit

Once you have some flavour of Fedora Atomic installed, run this command:

```bash
sudo bootc switch ghcr.io/zirconium-dev/zirconium-jackrabbit:latest
```

If you also have NVIDIA GPU (GTX 16xx or RTX series), run this command instead:

```bash
sudo bootc switch ghcr.io/zirconium-dev/zirconium-jackrabbit-nvidia:latest
```

## Notice about Nvidia GPUs and Jackrabbit

Currently the Nvidia kernel module and OGC kernel used in Jackrabbit are not being signed so there is no way of using Secure Boot on the Nvidia and Jackrabbit images. ([related issue](https://github.com/zirconium-dev/zirconium/issues/108))

## Can I still customize Niri and/or DMS?

Yes! Put your Niri customizations in `~/.config/niri/local.kdl` (for your user) or `/etc/niri/local.kdl` (for system-wide customizations).

We update our dotfiles in OS updates, which will overwrite the default `~/.config/niri/config.kdl` file. If you edit it, it might get overwritten in a future update. 

## Zirconium is a stupid name. Why did you pick Zirconium?

A weird wax baby made me.

[![Tally Hall - Ruler of Everything](https://img.youtube.com/vi/I8sUC-dsW8A/0.jpg)](https://www.youtube.com/watch?v=I8sUC-dsW8A)
