
include common.mak

VERSION=4.4-157
SRC_TAR=$(ROOT_DIR)/src/gdb-$(VERSION).tar.bz2
BUILD_ROOT=$(ROOT_DIR)/build/gdb
SRC_DIR=$(BUILD_ROOT)/gdb-stable


# Конфігурація для симулятора
CONFIGURE_SIM=\
	--with-build-sysroot=$(ROOT_DIR)/install/Win32 \
	--enable-gdbserver \

#	--disable-multilib \
#	--without-headers \
#	--disable-libgcc \
#	--disable-libgcov \
#	--disable-target-libiberty \
#	--enable-threads \
#	--disable-libmudflap \
#	--disable-libssp \
#	--disable-libstdcxx-pch \
#	--with-arch-32=i686 \
#	--disable-sjlj-exceptions \
#	--with-gnu-as \
#	--with-gnu-ld \
#	--with-specs='%{O2:%{!fno-remove-local-statics: -fremove-local-statics}} %{O*:%{O|O0|O1|O2|Os:;:%{!fno-remove-local-statics: -fremove-local-statics}}}' \
#	--enable-languages=c,c++ \
#	--disable-shared \
#	--with-pkgversion='Samsung Sourcery G++ 4.4-41' \
#	--with-bugurl=https://support.codesourcery.com/GNUToolchain/ \
#	--disable-nls \
#	--prefix=/opt/codesourcery \
#	--with-sysroot=/opt/codesourcery/i686-mingw32 \
#	--with-build-sysroot=$(ROOT_DIR)/install/Win32 \
#	--disable-libgomp \
#	--with-build-time-tools=$(ROOT_DIR)/install/Win32/i686-mingw32/bin \
	
#	--with-host-libstdcxx='-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm' \
#	--with-cloog=/scratch/nathan/samsung/obj/host-libs-4.4-41-i686-mingw32-i686-mingw32/usr \
	
#	--with-build-time-tools=/scratch/nathan/samsung/obj/tools-i686-pc-linux-gnu-4.4-41-i686-mingw32-i686-mingw32/i686-mingw32/bin \
#	--with-build-time-tools=/scratch/nathan/samsung/obj/tools-i686-pc-linux-gnu-4.4-41-i686-mingw32-i686-mingw32/i686-mingw32/bin
	
#	--with-libiconv-prefix=/scratch/nathan/samsung/obj/host-libs-4.4-41-i686-mingw32-i686-mingw32/0/usr 
#	--with-gmp=/scratch/nathan/samsung/obj/host-libs-4.4-41-i686-mingw32-i686-mingw32/usr \
#	--with-mpfr=/scratch/nathan/samsung/obj/host-libs-4.4-41-i686-mingw32-i686-mingw32/usr \
#	--with-ppl=/scratch/nathan/samsung/obj/host-libs-4.4-41-i686-mingw32-i686-mingw32/usr \

#    --prefix=/opt/codesourcery \
#    '--with-pkgversion=Samsung Sourcery G++ $(VERSION)' \
#    --with-bugurl=https://support.codesourcery.com/GNUToolchain/ \
#    --disable-nls \
#    --with-sysroot=/opt/codesourcery/arm-samsung-nucleuseabi \
#    --enable-poison-system-directories


all: build
	@echo "gdb : done"

build: $(SRC_DIR) \
	$(BUILD_ROOT)/configure-sim.d \
	$(BUILD_ROOT)/build-sim.d \
	$(BUILD_ROOT)/install-sim.d


# Створенння директорії з сорсами
$(SRC_DIR): $(SRC_TAR) $(BUILD_ROOT)/src.d
	@echo "gdb : extracting sources ..."
	@rm -f "$(BUILD_ROOT)/src.d"
	@if [ ! -d "$(BUILD_ROOT)" ]; then mkdir -p "$(BUILD_ROOT)"; fi;
	@rm -fR "$(SRC_DIR)"
	@mkdir "$(SRC_DIR)"
	@cd "$(SRC_DIR)/.."; \
		tar xf "$(SRC_TAR)"
	@touch $(SRC_DIR)
	@touch -r "$(SRC_TAR)" "$(BUILD_ROOT)/src.d"

"$(SRC_TAR)":
	@echo "missing gdb sources : $(SRC_TAR)" 1>&2
	exit 1

$(BUILD_ROOT)/src.d :
	@if [ ! -f "$@" ]; then rm -fR $(SRC_DIR); fi;

# конфігурація для симулятора
$(BUILD_ROOT)/configure-sim.d: $(BUILD_ROOT)/src.d
	@echo "gdb : configure-sim ..."
	@if [ ! -d "$(BUILD_ROOT)/sim" ]; then mkdir "$(BUILD_ROOT)/sim"; fi;
	cd "$(BUILD_ROOT)/sim"; \
	"$(SRC_DIR)/configure" \
		--target=$(TARGET_SIM) \
		$(CONFIGURE_SIM)
	@touch $(BUILD_ROOT)/configure-sim.d

# білдання для симулятора
$(BUILD_ROOT)/build-sim.d: $(BUILD_ROOT)/configure-sim.d $(BUILD_ROOT)/samsung-toolchain-data-sim.d
	@echo "gdb : build-sim ..."
	@cd "$(BUILD_ROOT)/sim"; \
	make -j4
	@touch $(BUILD_ROOT)/build-sim.d

# інсталяція для симулятора
# тут відбуваються маніпуляції з локалом (LANG, в зв'язку з тим, що десь хтось наглючив, і з локалом "cs_CZ.UTF-8" то допомагає
$(BUILD_ROOT)/install-sim.d: $(BUILD_ROOT)/build-sim.d
	@echo "gdb : install-sim ..."
	@cd "$(BUILD_ROOT)/sim"; \
	export OLD_LANG=$(LANG); \
	export LANG=cs_CZ.UTF-8; \
	make install prefix=$(ROOT_DIR)/install/Win32; \
	export LANG=$(OLD_LANG)
	@touch $(BUILD_ROOT)/install-sim.d
