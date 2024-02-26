-include .makeconfig

MSTPM_CFLAGS :=
TPM_OPT :=
PORT := 2321

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
	@echo "Container's ports 2321-2322 published to local ports $(PORT)-$$(( $(PORT) + 1 ))"
	./run-in-container.sh -e "-p $(PORT)-$$(( $(PORT) + 1 )):2321-2322" \
		-c "Simulator/src/tpm2-simulator $(TPM_OPT)"

run-simulator-bare: tpm2-simulator
	ms-tpm-20-ref/TPMCmd/Simulator/src/tpm2-simulator $(PORT) $(TPM_OPT)

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

help:
	@echo  'Cleaning targets:'
	@echo  '  clean           - Remove files normally created during the building'
	@echo  '                    Call `make clean` in `ms-tpm-20-ref/TPMCmd`'
	@echo  '  distclean       - clean + remove files created during the configuration'
	@echo  '                    Call `make distlclean` in `ms-tpm-20-ref/TPMCmd`'
	@echo  '  repoclean       - Remove `ms-tpm-20-ref` git submodule completly, so'
	@echo  '                    next builds will clone it again, starting from a'
	@echo  '                    completely clean source base'
	@echo  ''
	@echo  'Building targets:'
	@echo  '  all                 - Build all targets in `ms-tpm-20-ref` using a container'
	@echo  '  tpm2-simulator      - Build the MS TPM simulator using a container'
	@echo  ''
	@echo  'Running targets:'
	@echo  '  run-simulator       - Run the MS TPM simulator in a container'
	@echo  '  run-simulator-bare  - Run the MS TPM simulator locally (NOT in a container)'
	@echo  '                        `openssl1.1` library must be installed'
	@echo  ''
	@echo  'Options:'
	@echo  '  make DEBUG=1 [targets]       - build with `-DDEBUG=YES` defined in CFLAGS'
	@echo  '                                 Bulding the simulator in debug mode will'
	@echo  '                                 provide fixed seeding of the RNG and other'
	@echo  '                                 behaviors useful for debugging'
	@echo  '  make MANUFACTURE=1 [targets] - run the simulator with `-m` option'
	@echo  '                                 forces NV state of the TPM simulator to be'
	@echo  '                                 (re)manufactured'
	@echo  '  make PORT=value [targets]    - use custom ports in the TPM simulator'
	@echo  '                                 PORT is used for "TPM command server" [default 2321]'
	@echo  '                                 PORT+1 is used for "Platform server" [default 2322]'

