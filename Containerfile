ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"
ARG BASE_NAME="${BASE_NAME:-quay.io/fedora/fedora-bootc}"
ARG BASE_VERSION="${BASE_VERSION:-43}"
ARG BASE_IMAGE="${BASE_IMAGE:-${BASE_NAME}:${BASE_VERSION}}"

FROM scratch AS ctx

COPY build_files /build
COPY system_files /files
COPY cosign.pub /files/etc/pki/containers/zirconium.pub

FROM ${BASE_IMAGE} AS build

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
    /ctx/build/03-nvidia.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/99-cleanup.sh

# This is handy for VM testing
# RUN usermod -p "$(echo "changeme" | mkpasswd -s)" root

RUN rm -rf /var/* && bootc container lint
