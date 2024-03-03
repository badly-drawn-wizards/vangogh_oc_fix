LINUX_PKG_DIR ?= ./linux-pkg
LINUX_PKGBUILD = $(LINUX_PKG_DIR)/PKGBUILD
LINUX_PKGBASE = $(shell cat $(LINUX_PKGBUILD) | sed -n 's/^pkgbase=\(.*\)$$/\1/p')
LINUX_PKG_BUILDDIR ?= build
LINUX_SRC ?= $(LINUX_PKG_BUILDDIR)/$(LINUX_PKGBASE)/src/archlinux-linux-neptune
MAKEPKG_CONF ?= $(shell [ -f /etc/makepkg.conf ] && echo "/etc/makepkg.conf" || echo ./makepkg.conf)
LINUX_SRC_KERNEL_VERSION = $(shell make -s -C $(LINUX_SRC) kernelversion)
LINUX_SRC_AMD_DIR=$(LINUX_SRC)/drivers/gpu/drm/amd
LINUX_SRC_AMD_HEADERS = $(shell find $(LINUX_SRC_AMD_DIR) -name '*.h')
HEADERS_DIR = ../module/amd_headers/$(LINUX_SRC_KERNEL_VERSION)
LINUX_HEADERS_ALL_DIRS = $(shell find $(HEADERS_DIR)/drivers -type d)


PHONEY += linux-pkg-prepare
linux-pkg-prepare: | $(LINUX_PKG_DIR)
	cd $(LINUX_PKG_DIR) && CARCH=x86_64 MAKEPKG_CONF=$(MAKEPKG_CONF) BUILDDIR=$(LINUX_PKG_BUILDDIR) makepkg --nobuild --nocheck --nodeps

$(HEADERS_DIR)/%.h: $(LINUX_SRC)/%.h
	mkdir -p $(shell dirname $@)
	cp $< $@

$(HEADERS_DIR)/Makefile: $(LINUX_SRC_AMD_HEADERS:$(LINUX_SRC)/%.h=$(HEADERS_DIR)/%.h)
	mkdir -p $(shell dirname $@)

	( echo "ccflags-y += \\"; echo '$(LINUX_HEADERS_ALL_DIRS:$(HEADERS_DIR)/%=-I$$(CONFIG_MODULE_AMD_HEADERS_DIR)/%)' ) > $@

$(HEADERS_DIR)/COPYING: $(LINUX_SRC)/COPYING
	cp $< $@

$(HEADERS_DIR)/LICENSES: $(LINUX_SRC)/LICENSES
	cp -R $< $@

PHONEY += extract-headers
extract-headers: $(HEADERS_DIR)/Makefile $(HEADERS_DIR)/COPYING $(HEADERS_DIR)/LICENSES

test:
	echo $(LINUX_HEADERS_ALL_DIRS)
