

ROOT_DIR=$(shell pwd)
TOOLCHAIN= \
	build-binutils \
	build-gcc \
	build-gdb \
	bada-toolchain.tar.gz
	

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

build-gdb: build-binutils build-gcc
	@echo "Building gdb ..."
	@cd $(ROOT_DIR); \
	make -f gdb.mak
	
	
bada-toolchain.tar.gz : $(ROOT_DIR)/install
	@echo "Creating $@ ..."
	@cd $(ROOT_DIR)/install; \
		tar cfz $(ROOT_DIR)/$@ *
	@echo "Done"
