# ms-tpm-20-ref containerized build

This repository contains a Makefile and scripts to build
[ms-tpm-20-ref](https://github.com/microsoft/ms-tpm-20-ref)
and launch the simulator using a container.

This is motivated by the fact that `ms-tpm-20-ref` requires `openssl-1.1` and
in many recent systems we now have newer versions installed.

Repository `ms-tpm-20-ref` is added as a `git submodule` and automatically
cloned from the Makefile. To start using it, you just need to use the Makefile,
for example by running `make run-simulator`.

## Prerequisites

`buildah` and `podman` are used by the scripts in this repository. So make sure
you have them installed in your system.

### Fedora/RHEL/CentOS

```bash
dnf install buildah podman
```

### Arch Linux

```bash
pacman -S buildah podman
```

### Debian/Ubuntu

```bash
apt-get install buildah podman
```

### openSUSE

```bash
zypper install buildah podman
```

## Debug mode

The simulator will NOT be compiled in debug mode by default, so this way it
will NOT provide fixed seeding of the RNG. To re-enable this feature,
please use `DEBUG=1` option (e.g. `make DEBUG=1 run-simulator`).

The Makefile in this repository also automatically handles full recompilation
when enabled in debug mode or not.

## Usage

```bash
$ make help
Cleaning targets:
  clean           - Remove files normally created during the building
                    Call `make clean` in `ms-tpm-20-ref/TPMCmd`
  distclean       - clean + remove files created during the configuration
                    Call `make distlclean` in `ms-tpm-20-ref/TPMCmd`
  repoclean       - Remove `ms-tpm-20-ref` git submodule completly, so
                    next builds will clone it again, starting from a
                    completely clean source base

Building targets:
  all                 - Build all targets in `ms-tpm-20-ref` using a container
  tpm2-simulator      - Build the MS TPM simulator using a container

Running targets:
  run-simulator       - Run the MS TPM simulator in a container
  run-simulator-bare  - Run the MS TPM simulator locally (NOT in a container)
                        `openssl1.1` library must be installed

Options:
  make DEBUG=1 [targets]       - build with `-DDEBUG=YES` defined in CFLAGS
                                 Bulding the simulator in debug mode will
                                 provide fixed seeding of the RNG and other
                                 behaviors useful for debugging
  make MANUFACTURE=1 [targets] - run the simulator with `-m` option
                                 forces NV state of the TPM simulator to be
                                 (re)manufactured
```
