
include common.mak

VERSION=4.4-157
SRC_TAR=$(ROOT_DIR)/src/binutils-$(VERSION).tar.bz2
BUILD_ROOT=$(ROOT_DIR)/build/binutils
SRC_DIR=$(BUILD_ROOT)/binutils-stable


# Конфігурація для симулятора
CONFIGURE_SIM=\
    --prefix=/opt/codesourcery \
    '--with-pkgversion=Samsung Sourcery G++ $(VERSION)' \
    --with-bugurl=https://support.codesourcery.com/GNUToolchain/ \
    --disable-nls \
    --with-sysroot=/opt/codesourcery/arm-samsung-nucleuseabi \
    --enable-poison-system-directories


all: build
	@echo "binutils : done"

build: $(SRC_DIR) \
	$(BUILD_ROOT)/configure-sim.d \
	$(BUILD_ROOT)/build-sim.d \
	$(BUILD_ROOT)/install-sim.d


# Створенння директорії з сорсами
$(SRC_DIR): $(SRC_TAR) $(BUILD_ROOT)/src.d
	@echo "binutils : extracting sources ..."
	@rm -f "$(BUILD_ROOT)/src.d"
	@if [ ! -d "$(BUILD_ROOT)" ]; then mkdir "$(BUILD_ROOT)"; fi;
	@rm -fR "$(SRC_DIR)"
	@mkdir "$(SRC_DIR)"
	@cd "$(SRC_DIR)/.."; \
		tar xf "$(SRC_TAR)"
	@touch $(SRC_DIR)
	@touch -r "$(SRC_TAR)" "$(BUILD_ROOT)/src.d"

"$(SRC_TAR)":
	@echo "missing binutils sources : $(SRC_TAR)" 1>&2
	exit 1

$(BUILD_ROOT)/src.d :
	@if [ ! -f "$@" ]; then rm -fR $(SRC_DIR); fi;

# конфігурація для симулятора
$(BUILD_ROOT)/configure-sim.d: $(BUILD_ROOT)/src.d
	@echo "binutils : configure-sim ..."
	@if [ ! -d "$(BUILD_ROOT)/sim" ]; then mkdir "$(BUILD_ROOT)/sim"; fi;
	cd "$(BUILD_ROOT)/sim"; \
	"$(SRC_DIR)/configure" \
		--target=$(TARGET_SIM) \
		$(CONFIGURE_SIM)
	@touch $(BUILD_ROOT)/configure-sim.d

# білдання для симулятора
$(BUILD_ROOT)/build-sim.d: $(BUILD_ROOT)/configure-sim.d
	@echo "binutils : build-sim ..."
	@cd "$(BUILD_ROOT)/sim"; \
	make
	@touch $(BUILD_ROOT)/build-sim.d

# інсталяція для симулятора
# тут відбуваються маніпуляції з локалом (LANG, в зв'язку з тим, що десь хтось наглючив, і з локалом "cs_CZ.UTF-8" то допомагає
$(BUILD_ROOT)/install-sim.d: $(BUILD_ROOT)/build-sim.d
	@echo "binutils : install-sim ..."
	@cd "$(BUILD_ROOT)/sim"; \
	export OLD_LANG=$(LANG); \
	export LANG=cs_CZ.UTF-8; \
	make install prefix=$(ROOT_DIR)/install/Win32; \
	export LANG=$(OLD_LANG)
	strip $(ROOT_DIR)/install/Win32/bin/*
	@touch $(BUILD_ROOT)/install-sim.d
