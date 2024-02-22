#!/bin/sh

IMAGE=ms-tpm-builder
VOLUME=/usr/src/ms-tpm-20-ref

set -e

cd "$(dirname "$0")"

# Build image, if it doesn't exist or is older than ./Containerfile
if [ "$(podman images --noheading --filter reference="${IMAGE}" | wc -l)" -eq 0 ]; then
    buildah bud --tag "${IMAGE}" .
elif [ "$(podman images --noheading --filter reference="${IMAGE}" --filter until="$(date -r ./Containerfile +%s)" | wc -l)" -ne 0 ]; then
    buildah bud --tag "${IMAGE}" .
fi

# Disable seccomp so io_uring syscalls are allowed
exec podman run --security-opt=seccomp=unconfined --rm -it \
    --user "$(id --user):$(id --group)" --userns keep-id \
    --volume ./ms-tpm-20-ref:"${VOLUME}":z "${IMAGE}" \
    /bin/sh -e -c "$*"
