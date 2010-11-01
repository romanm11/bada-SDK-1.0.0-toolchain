

ROOT_DIR=$(shell pwd)
TOOLCHAIN= \
	build-binutils \
	build-gcc \
	

all: showtime $(TOOLCHAIN)

showtime:
	@date

build-binutils:
	@echo "Building binutils ..."
	@cd $(ROOT_DIR); \
	make -f binutils.mak

build-gcc: build-binutils
	@echo "Building gcc ..."
	@cd $(ROOT_DIR); \
	make -f gcc.mak
	