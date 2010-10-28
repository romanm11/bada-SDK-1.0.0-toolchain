
include common.mak

VERSION=4.4-157
SRC_TAR=$(ROOT_DIR)/src/binutils-$(VERSION).tar.bz2
SRC_DIR=$(ROOT_DIR)/build/src/binutils-stable


# Конфігурація для симулятора
CONFIGURE_SIM=\
    --prefix=/opt/codesourcery \
    '--with-pkgversion=Samsung Sourcery G++ $(VERSION)' \
    --with-bugurl=https://support.codesourcery.com/GNUToolchain/ \
    --disable-nls \
    --with-sysroot=/opt/codesourcery/arm-samsung-nucleuseabi \
    --enable-poison-system-directories


all: binutils-src
	@echo "binutils : done"

binutils-src: $(SRC_DIR) \
	$(ROOT_DIR)/build/binutils/configure-sim.d \
	$(ROOT_DIR)/build/binutils/build-sim.d \
	$(ROOT_DIR)/build/binutils/install-sim.d


# Створенння директорії з сорсами
$(SRC_DIR): $(ROOT_DIR)/build/src $(SRC_TAR) $(ROOT_DIR)/build/binutils/src.d
	@echo "binutils : extracting sources ..."
	@rm -f "$(ROOT_DIR)/build/binutils/src.d"
	@if [ ! -d "$(ROOT_DIR)/build/binutils" ]; then mkdir "$(ROOT_DIR)/build/binutils"; fi;
	@if [ ! -d "$(ROOT_DIR)/build" ]; then mkdir "$(ROOT_DIR)/build"; fi;
	@if [ ! -d "$(ROOT_DIR)/build/src" ]; then mkdir "$(ROOT_DIR)/build/src"; fi;
	@rm -fR "$(SRC_DIR)"
	@mkdir "$(SRC_DIR)"
	@cd "$(SRC_DIR)/.."; \
		tar xf "$(SRC_TAR)"
	@touch $(SRC_DIR)
	@touch -r "$(SRC_TAR)" "$(ROOT_DIR)/build/binutils/src.d"

"$(SRC_TAR)":
	@echo "missing binutils sources : $(SRC_TAR)" 1>&2
	exit 1

$(ROOT_DIR)/build/binutils/src.d :
	@if [ ! -f "$@" ]; then rm -fR $(SRC_DIR); fi;

# конфігурація для симулятора
$(ROOT_DIR)/build/binutils/configure-sim.d: $(ROOT_DIR)/build/binutils/src.d
	@echo "binutils : configure-sim ..."
	@if [ ! -d "$(ROOT_DIR)/build/binutils/sim" ]; then mkdir "$(ROOT_DIR)/build/binutils/sim"; fi;
	cd "$(ROOT_DIR)/build/binutils/sim"; \
	"$(SRC_DIR)/configure" \
		--target=$(TARGET_SIM) \
		$(CONFIGURE_SIM)
	@touch $(ROOT_DIR)/build/binutils/configure-sim.d

# білдання для симулятора
$(ROOT_DIR)/build/binutils/build-sim.d: $(ROOT_DIR)/build/binutils/configure-sim.d
	@echo "binutils : build-sim ..."
	@cd "$(ROOT_DIR)/build/binutils/sim"; \
	make
	@touch $(ROOT_DIR)/build/binutils/build-sim.d

# інсталяція для симулятора
# тут відбуваються маніпуляції з локалом (LANG, в зв'язку з тим, що десь хтось наглючив, і з локалом "cs_CZ.UTF-8" то допомагає
$(ROOT_DIR)/build/binutils/install-sim.d: $(ROOT_DIR)/build/binutils/build-sim.d
	@echo "binutils : install-sim ..."
	@cd "$(ROOT_DIR)/build/binutils/sim"; \
	export OLD_LANG=$(LANG); \
	export LANG=cs_CZ.UTF-8; \
	make install prefix=$(ROOT_DIR)/install; \
	export LANG=$(OLD_LANG)
	@touch $(ROOT_DIR)/build/binutils/install-sim.d
