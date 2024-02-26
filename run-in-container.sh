#!/bin/bash

IMAGE=ms-tpm-builder
VOLUME=/usr/src/ms-tpm-20-ref
EXTRA_PARAMS=
CMD=

function usage
{
    echo -e "usage: $0 [OPTION...]"
    echo -e ""
    echo -e "Run commands in a container image which is build if it doesn't"
    echo -e "exist or is older than ./Containerfile."
    echo -e ""
    echo -e " -c, --command       command to run in the container"
    echo -e " -e, --extra-params  extra parameters for podman-run"
    echo -e " -h, --help          print this help"
}

set -e

while [ "$1" != "" ]; do
    case $1 in
        -c | --command )
            shift
            CMD=$1
            ;;
        -e | --extra-params )
            shift
            EXTRA_PARAMS=$1
            ;;
        -h | --help )
            usage
            exit
            ;;
        * )
            echo -e "\nParameter not found: $1\n"
            usage
            exit 1
    esac
    shift
done

cd "$(dirname "$0")"

# Build image, if it doesn't exist or is older than ./Containerfile
if [ "$(podman images --noheading --filter reference="${IMAGE}" | wc -l)" -eq 0 ]; then
    buildah bud --tag "${IMAGE}" .
elif [ "$(podman images --noheading --filter reference="${IMAGE}" --filter until="$(date -r ./Containerfile +%s)" | wc -l)" -ne 0 ]; then
    buildah bud --tag "${IMAGE}" .
fi

exec podman run --rm -it --init ${EXTRA_PARAMS} \
    --user "$(id --user):$(id --group)" --userns keep-id \
    --volume ./ms-tpm-20-ref:"${VOLUME}":z "${IMAGE}" \
    /bin/sh -e -c "${CMD}"
