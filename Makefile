-include .makeconfig

MSTPM_CFLAGS :=
TPM_OPT :=

ifeq ($(DEBUG),1)
MSTPM_CFLAGS += -DDEBUG=YES
else
MSTPM_CFLAGS += -DDEBUG=NO
endif

ifeq ($(MANUFACTURE),1)
TPM_OPT += -m
endif

.PHONY: all clean distclean repoclean run-simulator run-simulator-bare \
	tpm2-simulator reconfigure help

ifneq ($(MSTPM_CFLAGS),$(OLD_MSTPM_CFLAGS))
all tpm2-simulator: reconfigure
endif

all clean distclean: ms-tpm-20-ref/TPMCmd/Makefile
	./run-in-container.sh make $@

repoclean:
	rm -rf ms-tpm-20-ref

tpm2-simulator: ms-tpm-20-ref/TPMCmd/Simulator/src/tpm2-simulator

run-simulator: tpm2-simulator
	./run-in-container.sh Simulator/src/tpm2-simulator $(TPM_OPT)

run-simulator-bare: tpm2-simulator
	ms-tpm-20-ref/TPMCmd/Simulator/src/tpm2-simulator $(TPM_OPT)

ms-tpm-20-ref/TPMCmd/bootstrap:
	git submodule update --init

ms-tpm-20-ref/TPMCmd/configure: ms-tpm-20-ref/TPMCmd/bootstrap
	./run-in-container.sh ./bootstrap

ms-tpm-20-ref/TPMCmd/Makefile: ms-tpm-20-ref/TPMCmd/configure
	./run-in-container.sh ./configure CFLAGS="${MSTPM_CFLAGS}"
	@echo OLD_MSTPM_CFLAGS=$(MSTPM_CFLAGS) > .makeconfig

ms-tpm-20-ref/TPMCmd/Simulator/src/tpm2-simulator: ms-tpm-20-ref/TPMCmd/Makefile
	./run-in-container.sh make Simulator/src/tpm2-simulator

reconfigure: distclean
	$(MAKE) ms-tpm-20-ref/TPMCmd/Makefile
