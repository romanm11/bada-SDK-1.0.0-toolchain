

ROOT_DIR=$(shell pwd)
TOOLCHAIN= \
	binutils-sim \

all: showtime $(TOOLCHAIN)

showtime:
	@date

binutils-sim:
# $(ROOT_DIR)/binutils-sim.mak
	@echo "Building binutils ..."
	@cd $(ROOT_DIR); \
	make -f binutils.mak
