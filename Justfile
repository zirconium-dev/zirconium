image := env("IMAGE_FULL", "zirca:latest")
filesystem := env("BUILD_FILESYSTEM", "ext4")

iso $image=image:
    #!/usr/bin/env bash
    mkdir -p output
    sudo podman pull ghcr.io/mgspl/"${image}"
    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v "./iso.toml:/config.toml:ro" \
        -v ./output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        ghcr.io/osbuild/bootc-image-builder:latest \
        --type iso \
        --rootfs btrfs \
        --use-librepo=True \
        "${image}"

rootful $image=image:
    #!/usr/bin/env bash
    podman image scp $USER@localhost::$image root@localhost::$image

bootc *ARGS:
    sudo podman run \
        --rm --privileged --pid=host \
        -it \
        -v /sys/fs/selinux:/sys/fs/selinux \
        -v /etc/containers:/etc/containers:Z \
        -v /var/lib/containers:/var/lib/containers:Z \
        -v /dev:/dev \
        -v "${BUILD_BASE_DIR:-.}:/data" \
        --security-opt label=type:unconfined_t \
        "{{image}}" bootc {{ARGS}}

disk-image $filesystem=filesystem:
    #!/usr/bin/env bash
    if [ ! -e "${BUILD_BASE_DIR:-.}/bootable.img" ] ; then
        fallocate -l 20G "${BUILD_BASE_DIR:-.}/bootable.img"
    fi
    just bootc install to-disk --via-loopback /data/bootable.img --filesystem "${filesystem}" --wipe

quick-iterate:
    #!/usr/bin/env bash
    podman build -t zirca:latest .
    just rootful
    BUILD_BASE_DIR=/tmp just disk-image
