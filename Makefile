MSTPM_CFLAGS :=

ifdef DEBUG
MSTPM_CFLAGS += -DDEBUG=YES
else
MSTPM_CFLAGS += -DDEBUG=NO
endif

.PHONY: all clean distclean repoclean run-simulator tpm2-simulator

all clean distclean: ms-tpm-20-ref/TPMCmd/Makefile
	./run-in-container.sh make $@

repoclean:
	rm -rf ms-tpm-20-ref

tpm2-simulator: ms-tpm-20-ref/TPMCmd/Simulator/src/tpm2-simulator

run-simulator: tpm2-simulator
	ms-tpm-20-ref/TPMCmd/Simulator/src/tpm2-simulator

run-simulator-remanufactured: tpm2-simulator
	ms-tpm-20-ref/TPMCmd/Simulator/src/tpm2-simulator -m

ms-tpm-20-ref/TPMCmd/bootstrap:
	git submodule update --init

ms-tpm-20-ref/TPMCmd/configure: ms-tpm-20-ref/TPMCmd/bootstrap
	./run-in-container.sh ./bootstrap

ms-tpm-20-ref/TPMCmd/Makefile: ms-tpm-20-ref/TPMCmd/configure
	./run-in-container.sh ./configure CFLAGS="${MSTPM_CFLAGS}"

ms-tpm-20-ref/TPMCmd/Simulator/src/tpm2-simulator: ms-tpm-20-ref/TPMCmd/Makefile
	./run-in-container.sh make Simulator/src/tpm2-simulator
