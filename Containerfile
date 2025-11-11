FROM scratch AS ctx

COPY build_files /build
COPY system_files /files
COPY cosign.pub /files/etc/pki/containers/zirconium.pub

FROM quay.io/fedora/fedora-bootc:43 AS zirconium

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/00-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/01-theme.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/02-extras.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/99-cleanup.sh

# This is handy for VM testing
# RUN usermod -p "$(echo "changeme" | mkpasswd -s)" root

RUN rm -rf /var/* && \
    rm -rf /tmp/* || true && \
    bootc container lint

FROM ghcr.io/ublue-os/akmods-nvidia-open:main-43-x86_64 AS akmods_nvidia

FROM zirconium AS zirconium-nvidia

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=bind,from=akmods_nvidia,src=/rpms,dst=/tmp/akmods-nv-rpms \
    --mount=type=tmpfs,dst=/tmp \
    curl -sSL --retry 3 -Lo /tmp/nvidia-install.sh https://github.com/ublue-os/main/raw/refs/heads/main/build_files/nvidia-install.sh && \
    chmod +x /tmp/nvidia-install.sh && \
    AKMODNV_PATH=/tmp/akmods-nv-rpms IMAGE_NAME="zirconium-nvidia" /tmp/nvidia-install.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/99-cleanup.sh

RUN rm -rf /var/* && \
    rm -rf /tmp/* || true && \
    bootc container lint
