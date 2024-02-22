FROM fedora:39

RUN dnf install -qy openssl1.1-devel make automake gcc gcc-c++ \
    git autoconf-archive pkg-config

VOLUME /usr/src/ms-tpm-20-ref
WORKDIR /usr/src/ms-tpm-20-ref/TPMCmd
