UNAME ?= $(shell uname -r)
MODULES_DIR ?= /lib/modules/$(UNAME)
HEADERS_BUILD ?= $(MODULES_DIR)/build
HEADERS_KERNEL_VERSION = $(shell make -s -C $(HEADERS_BUILD) kernelversion)
MODULES_EXTRA_DIR = $(MODULES_DIR)/extra
MODULES_LOAD_DIR = /etc/modules-load.d
MODULE_LOAD_LINE = "vangogh_oc_fix"
MODULE_FREQ ?= 3500
MODPROBE_DIR = /etc/modprobe.d
MODPROBE_LINE = "options vangogh_oc_fix cpu_default_soft_max_freq=$(MODULE_FREQ)"
MODULE_AMD_HEADERS_DIR = ./module/amd_headers/$(HEADERS_KERNEL_VERSION)

PHONEY := build
build: module/vangogh_oc_fix.ko.xz

$(HEADERS_BUILD):
	$(error "Could not find $(HEADERS_BUILD)\nYou probably don't have headers installed. Run 'sudo pacman -S $(PKGBASE)-headers' to install them")

PHONEY += clean
clean: $(HEADERS_DIR)
	make -C $(HEADERS_BUILD) M=$(shell pwd)/module clean

PHONEY += install
install: $(MODULES_EXTRA_DIR)/vangogh_oc_fix.ko.xz
	depmod -a

PHONEY += install-conf
install-conf: $(MODULES_LOAD_DIR)/vangogh_oc_fix.conf $(MODPROBE_DIR)/vangogh_oc_fix.conf

PHONEY += uname
uname:
	@echo $(UNAME)

module/vangogh_oc_fix.ko: $(HEADERS_BUILD) module/Makefile module/*.c module/*.h
	make -C $(HEADERS_BUILD) \
		CONFIG_MODULE_AMD_HEADERS_DIR=$(MODULE_AMD_HEADERS_DIR) \
		CONFIG_GCC_PLUGINS=n \
		M=$(shell pwd)/module \
		modules

module/vangogh_oc_fix.ko.xz: module/vangogh_oc_fix.ko
	xz --keep --check=crc32 --lzma2=dict=512KiB $< -c > $@

$(MODULES_EXTRA_DIR): | $(MODULES_DIR)
	mkdir $(MODULES_EXTRA_DIR)

$(MODULES_EXTRA_DIR)/vangogh_oc_fix.ko.xz: module/vangogh_oc_fix.ko.xz | $(MODULES_EXTRA_DIR)
	cp $< $@

PHONEY += _always
_always:

$(MODULES_LOAD_DIR)/vangogh_oc_fix.conf: _always
	@echo $(MODULE_LOAD_LINE) > $@

$(MODPROBE_DIR)/vangogh_oc_fix.conf: _always
	@echo $(MODPROBE_LINE) > $@

.PHONEY: $(PHONEY)
