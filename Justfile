image := env("IMAGE_FULL", "zirca:latest")
image_name := env("IMAGE_NAME", "zirca") # output image name, usually same as repo name, change as needed
default_tag := env("DEFAULT_TAG", "latest")
filesystem := env("BUILD_FILESYSTEM", "ext4")

iso $image=image:
    #!/usr/bin/env bash
    mkdir -p output
    sudo podman pull "${image}"
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

build $target_image=image_name $tag=default_tag:
    #!/usr/bin/env bash

    BUILD_ARGS=()
    if [[ -z "$(git status -s)" ]]; then
        BUILD_ARGS+=("--build-arg" "SHA_HEAD_SHORT=$(git rev-parse --short HEAD)")
    fi

    podman build \
        "${BUILD_ARGS[@]}" \
        --pull=newer \
        --tag "${target_image}:${tag}" \
        .


