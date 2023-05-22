RELEASE_CHANNEL := jupiter-rel
NEPTUNE_NAME := neptune
LINUX_PKGBASE := linux-$(NEPTUNE_NAME)
LINUX_GIT_TAG := 5.13.0-valve36
LINUX_URL_TAG := $(subst -,.,$(LINUX_GIT_TAG))
LINUX_REL := 1
LINUX_NAME := $(LINUX_PKGBASE)-$(LINUX_URL_TAG)-$(LINUX_REL)
UNAME := $(LINUX_GIT_TAG)-$(LINUX_REL)-$(NEPTUNE_NAME)
LINUX_PKGBUILD_TAR := $(LINUX_NAME).src.tar.gz
LINUX_HEADERS_TAR := linux-neptune-headers-$(LINUX_URL_TAG)-$(LINUX_REL)-x86_64.pkg.tar.zst
STEAMOS_MIRROR := https://steamdeck-packages.steamos.cloud/archlinux-mirror
STEAMOS_PKGBUILD_URL := $(STEAMOS_MIRROR)/sources/$(RELEASE_CHANNEL)/$(LINUX_PKGBUILD_TAR)
STEAMOS_HEADERS_URL := $(STEAMOS_MIRROR)/$(RELEASE_CHANNEL)/os/x86_64/$(LINUX_HEADERS_TAR)
LINUX_PKG := steamos-pkgbuild/$(LINUX_PKGBASE)
LINUX_GITDIR := $(LINUX_PKG)/archlinux-linux-neptune
LINUX_DIR := linux
HEADER_DIR := steamos-headers/usr/lib/modules/$(UNAME)/build
MAKE_DIR := $(LINUX_DIR)

urls:
	echo STEAMOS_PKGBUILD_URL $(STEAMOS_PKGBUILD_URL)
	echo STEAMOS_HEADERS_URL $(STEAMOS_HEADERS_URL)

steamos-pkgbuild.tar.gz:
	wget $(STEAMOS_PKGBUILD_URL) -O$@

steamos-headers.tar.zst:
	wget $(STEAMOS_HEADERS_URL) -O$@

download-linux: steamos-pkgbuild.tar.gz
download-headers: steamos-headers.tar.zst

steamos-pkgbuild: steamos-pkgbuild.tar.gz
	mkdir $@
	tar -xvf $< -C $@

steamos-headers: steamos-headers.tar.zst
	mkdir $@
	tar --use-compress-program=unzstd -xvf $< -C $@

steamos-headers.tar: steamos-headers.tar.zst

$(LINUX_GITDIR): steamos-pkgbuild

# Target is explicitly not $(LINUX_DIR)
linux:
	git --git-dir=$(LINUX_GITDIR) worktree add -f linux

set-version: | linux
	cd linux && git checkout $(LINUX_GITTAG)
	cd linux && scripts/setlocalversion --save-scmversion
	cd linux \
		&& echo "-$(LINUX_REL)" > localversion.10-pkgrel \
		&& echo "-$(NEPTUNE_NAME)" > localversion.20-pkgname
	cd linux && make -s kernelrelease > version

linux-clean: | $(LINUX_DIR)
	cd $(LINUX_DIR) && make clean

$(LINUX_DIR)/.config: $(LINUX_PKG)/config* | $(LINUX_DIR)
	(cd $(LINUX_DIR) && scripts/kconfig/merge_config.sh -m $(abspath $^) && make olddefconfig ) || rm $(LINUX_DIR)/.config

prepare: $(LINUX_DIR)/.config
	cd $(LINUX_DIR) && make prepare

modules: $(LINUX_DIR)/.config
	cd $(LINUX_DIR) && make modules

module/amd:
	- ln -sr $(LINUX_DIR)/drivers/gpu/drm/amd module/amd

module/vangogh_oc_fix.ko: module/*.c | module/amd
	make -C $(MAKE_DIR) srctree=$(abspath $(LINUX_DIR)) M=$(shell pwd)/module modules

module/vangogh_oc_fix.ko.xz: module/vangogh_oc_fix.ko
	xz --keep --check=crc32 --lzma2=dict=512KiB $< -c > $@

build: module/vangogh_oc_fix.ko.xz

clean: | linux
	make -C $(MAKE_DIR) M=$(shell pwd)/module clean

git-tag:
	echo $(LINUX_GIT_TAG)

uname:
	echo $(UNAME)

.PHONEY: all clean download-linux download-headers linux-config git-tag uname prepare build urls set-version
