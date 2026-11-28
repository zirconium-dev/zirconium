bootc --source-imgref=oci:/usr/lib/zirconium/install/zirconium-oci --target-imgref=ghcr.io/zirconium-dev/zirconium:latest
# https://discussion.fedoraproject.org/t/root-mount-options-are-ignored-in-fedora-atomic-desktops-42-and-later/148562
# using bootc kargs.d might be a pain later because they are added to every
# existing installation as well which for whatever reason might not be BTRFS
# and blow up
# this can probably be removed with F46
# https://bugzilla.redhat.com/show_bug.cgi?id=2332319
bootloader --append "rootflags=compress=zstd:1"
