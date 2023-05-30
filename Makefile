RELEASE_CHANNEL := jupiter-rel
NEPTUNE_NAME := neptune
LINUX_PKGBASE := linux-$(NEPTUNE_NAME)
LINUX_GIT_TAG := 5.13.0-valve36
LINUX_URL_TAG := $(subst -,.,$(LINUX_GIT_TAG))
LINUX_REL := 1
LINUX_NAME := $(LINUX_PKGBASE)-$(LINUX_URL_TAG)-$(LINUX_REL)
UNAME := $(LINUX_GIT_TAG)-$(LINUX_REL)-$(NEPTUNE_NAME)
LINUX_HEADERS_TAR := linux-neptune-headers-$(LINUX_URL_TAG)-$(LINUX_REL)-x86_64.pkg.tar.zst
STEAMOS_MIRROR := https://steamdeck-packages.steamos.cloud/archlinux-mirror
STEAMOS_HEADERS_URL := $(STEAMOS_MIRROR)/$(RELEASE_CHANNEL)/os/x86_64/$(LINUX_HEADERS_TAR)
HEADERS_BUILD := $(shell pwd)/steamos-headers/usr/lib/modules/$(UNAME)/build
MODULES_DIR := /lib/modules/$(UNAME)
MODULES_EXTRA_DIR := $(MODULES_DIR)/extra
MODULES_LOAD_DIR := /etc/modules-load.d
MODULE_LOAD_LINE := "vangogh_oc_fix"
MODULE_FREQ := 3500
MODPROBE_DIR := /etc/modprobe.d
MODPROBE_LINE := "options vangogh_oc_fix cpu_default_soft_max_freq=$(MODULE_FREQ)"

PHONEY := build
build: module/vangogh_oc_fix.ko.xz

PHONEY += clean
clean: $(HEADERS_DIR)
	make -C $(HEADERS_BUILD) M=$(shell pwd)/module clean

PHONEY += install
install: _install
_install: $(MODULES_EXTRA_DIR)/vangogh_oc_fix.ko.xz
	depmod -a

PHONEY += install-conf
install-conf: _install-conf
_install-conf: _install $(MODULE_LOAD_DIR)/vangogh_oc_fix.conf $(MODPROBE_DIR)/vangogh_oc_fix.conf

PHONEY += download-headers
download-headers: steamos-headers.tar.zst

PHONEY += url
url:
	echo STEAMOS_HEADERS_URL $(STEAMOS_HEADERS_URL)

PHONEY += git-tag
git-tag:
	echo $(LINUX_GIT_TAG)

PHONEY += uname
uname:
	echo $(UNAME)

steamos-headers.tar.zst:
	wget $(STEAMOS_HEADERS_URL) -O$@

steamos-headers: steamos-headers.tar.zst
	mkdir $@
	tar --use-compress-program=unzstd -xvf $< -C $@

$(HEADERS_BUILD): steamos-headers

module/vangogh_oc_fix.ko: $(HEADERS_BUILD) module/*.c
	make -C $(HEADERS_BUILD) CONFIG_GCC_PLUGINS=n M=$(shell pwd)/module modules

module/vangogh_oc_fix.ko.xz: module/vangogh_oc_fix.ko
	xz --keep --check=crc32 --lzma2=dict=512KiB $< -c > $@

$(MODULES_EXTRA_DIR): | $(MODULES_DIR)
	mkdir $(MODULES_EXTRA_DIR)

$(MODULES_EXTRA_DIR)/vangogh_oc_fix.ko.xz: module/vangogh_oc_fix.ko.xz | $(MODULES_EXTRA_DIR)
	cp $< $@

$(MODULES_LOAD_DIR)/vangogh_oc_fix.conf:
	echo $(MODULE_LOAD_LINE) > $@

$(MODPROBE_DIR)/vangogh_oc_fix.conf:
	echo $(MODPROBE_LINE) > $@

.PHONEY: $(PHONEY)
