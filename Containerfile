ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

FROM scratch AS ctx

COPY assets /assets
COPY build_files /build
COPY system_files /files
COPY cosign.pub /files/etc/pki/containers/zirconium.pub
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/bin/luks* /files/usr/bin
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/share/ublue-os/just /files/usr/share/ublue-os/just

FROM quay.io/fedora/fedora-bootc:43
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
    /ctx/build/02-zirca.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build/99-cleanup.sh

RUN rm -rf /var/* && mkdir /var/tmp && bootc container lint
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠀⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠗⠀⠀⣀⣄⠀⢿⣿⣿⣿⠟⠁⢠⡆⠉⠙⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⣴⣿⡟⠀⠘⣿⣿⠋⠀⠀⠀⢠⣶⡀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⢠⣿⠛⣶⠀⠀⣿⡟⠀⠀⠀⢠⣿⣿⡇⠀⠠⣽⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠅⠀⠀⣿⠏⠀⣿⠀⠀⣿⠁⠀⠀⢠⣿⠟⢻⡇⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⣼⣿⠀⢰⡟⠀⠀⠛⠀⠀⠀⣾⡇⠀⢸⡇⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠿⠃⠀⠈⠀⢀⠀⣀⣀⠀⠘⠟⠀⠀⡾⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀⠀⠀⢀⠂⠀⠈⠉⢴⣽⣿⠵⣿⡶⣂⣄⡀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⡟⠡⠆⢀⠀⠀⠀⠀⠄⠀⠈⠘⠏⢿⣶⣿⡿⢟⣱⣖⠒⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⡟⣻⠏⣠⠄⠀⢀⡀⠀⠀⠀⠀⠈⠀⠀⠀⢸⣿⢦⠄⠙⣿⡇⠩⣭⣅⠈⢿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣟⣼⡇⠈⢀⣴⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠁⠀⢀⠀⠈⠰⣶⡤⠿⠃⢸⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⡟⠉⢠⡶⠋⠀⠀⠀⠀⠀⠀⠀⢀⣤⣤⣴⣶⣤⣄⡀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿
# ⣿⣿⣿⡏⢀⡠⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣦⣄⠀⠀⠂⠀⠈⣿⣿⣿⣿
# ⣿⣿⣿⢃⠈⠀⢠⠀⠀⠀⠀⠀⢠⣿⣿⣿⠿⣩⣏⡙⣛⣛⣿⣿⣿⣿⣿⣿⣿⡿⢇⠀⠀⠄⠀⠘⣿⣿⣿
# ⣿⣿⣿⡎⠀⠀⠀⠀⠀⠀⠀⠠⣿⣿⣿⡟⣰⣿⠁⢀⠈⢿⣿⣿⣿⣿⢁⣴⠖⢲⣾⡇⠀⠀⠄⠀⣿⣿⣿
# ⣿⣿⣿⢀⠀⠀⠀⠀⠀⠀⠀⠀⣏⢿⣿⡇⣿⡇⠀⠀⠀⣼⣿⣿⣿⡇⣼⡏⠀⠀⣿⡇⠀⠀⠀⠀⣻⣿⣿
# ⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣄⠻⣷⡘⣷⣀⣀⣴⣿⡟⠉⠛⠓⣿⡇⠀⢰⣿⡇⠀⠀⠀⣼⣿⣿⣿
# ⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠙⢷⣌⠻⢿⣿⣿⣿⣿⣿⣦⣶⣿⣾⣧⣤⡾⠏⠀⠀⠀⠀⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⠶⢌⣉⣛⠛⠿⠿⠿⠿⠿⠛⠉⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠲⠀⠀⠀⠀⠀⠀⠉⠉⠉⠀⠀⠀⠈⠁⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠻⠿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⡏⠛⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡘⡻⣿⣿
# ⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⢨⡛⡛⣁⣿
# ⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠂⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿
# ⣿⣿⣿⣿⠇⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣄⣠⣴⣾⣿⣿⣿⣿
# ⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⡿⠋⠠⣾⡇⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿
# ⡟⢁⣠⣤⣦⣌⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣏⡹⢿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⡿⠿⢶⡬⠙⠟⠋⣁⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿
# ⣿⣏⠛⠚⠃⠀⠀⢰⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣻⣿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣧⣆⣤⣄⣤⣼⠁⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠠⠒⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠿⣿⣿⣿⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣧⣤⣴⣴⣦⠀⣄⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠐⠚⠛⠓⠂⢀⡄⠀⢰⢽⣿⣿⣿
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣰⣤⣄⣀⢀⠀⢠⡅⠀⠀⢀⣤⣤⡼⠧⣤⣤⣠⣤⣤⣄⡀⡀⣰⣦⣣⠈⡡⣽
# ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣹⣿⣿⣿⣾⣷⣾⡗⣒⠶⣿⣿⣿⡷⣾⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿
