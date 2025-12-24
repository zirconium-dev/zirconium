ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

FROM scratch AS ctx

COPY build_files /build
COPY system_files /files
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /files
COPY cosign.pub /files/etc/pki/containers/zirconium.pub

FROM quay.io/fedora/fedora-bootc:44@sha256:0326aedf9ee1ff4958bc00604d4471d874540eb9ddda7513bfe1da01736d19ae
ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/00-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/01-theme.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build/02-nvidia.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build/99-cleanup.sh

# This is handy for VM testing
# RUN usermod -p "$(echo "changeme" | mkpasswd -s)" root

RUN rm -rf /var/* && mkdir /var/tmp && bootc container lint
