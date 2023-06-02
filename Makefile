UNAME ?= $(shell uname -r)
STEAMOS_MIRROR := https://steamdeck-packages.steamos.cloud/archlinux-mirror
ifndef LINUX_HEADERS_TAR
ifndef STEAMOS_HEADERS_URL
$(error Set LINUX_HEADERS_TAR to the header files for "$(UNAME)" relative to $(STEAMOS_MIRROR) or STEAMOS_HEADERS_URL to the full path)
endif
endif
STEAMOS_HEADERS_URL ?= $(STEAMOS_MIRROR)/$(LINUX_HEADERS_TAR)
HEADERS_BUILD := $(shell pwd)/steamos-headers/usr/lib/modules/$(UNAME)/build
MODULES_DIR := /lib/modules/$(UNAME)
MODULES_EXTRA_DIR := $(MODULES_DIR)/extra
MODULES_LOAD_DIR := /etc/modules-load.d
MODULE_LOAD_LINE := "vangogh_oc_fix"
MODULE_FREQ ?= 3500
MODPROBE_DIR := /etc/modprobe.d
MODPROBE_LINE := "options vangogh_oc_fix cpu_default_soft_max_freq=$(MODULE_FREQ)"

PHONEY := build
build: module/vangogh_oc_fix.ko.xz

PHONEY += clean
clean: $(HEADERS_DIR)
	make -C $(HEADERS_BUILD) M=$(shell pwd)/module clean

PHONEY += install
install: $(MODULES_EXTRA_DIR)/vangogh_oc_fix.ko.xz
	depmod -a

PHONEY += install-conf
install-conf: $(MODULES_LOAD_DIR)/vangogh_oc_fix.conf $(MODPROBE_DIR)/vangogh_oc_fix.conf

PHONEY += download-headers
download-headers: steamos-headers.tar.zst

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

PHONEY += _always
_always:

$(MODULES_LOAD_DIR)/vangogh_oc_fix.conf: _always
	echo $(MODULE_LOAD_LINE) > $@

$(MODPROBE_DIR)/vangogh_oc_fix.conf: _always
	echo $(MODPROBE_LINE) > $@

.PHONEY: $(PHONEY)
