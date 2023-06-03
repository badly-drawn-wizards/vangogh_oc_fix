UNAME ?= $(shell uname -r)
MODULES_DIR ?= /lib/modules/$(UNAME)
HEADERS_BUILD ?= $(MODULES_DIR)/build
PKGBASE := $(shell (cat $(MODULES_DIR)/pkgbase || echo "linux-neptune-<version>"))
ifndef CONFIG_HEADERS_HAVE_EXTRA_SHIT
ifeq ($(PKGBASE),linux-neptune-61)
CONFIG_HEADERS_HAVE_EXTRA_SHIT := y
else
ifeq ($(PKGBASE),linux-neptune)
CONFIG_HEADERS_HAVE_EXTRA_SHIT := n
else
# Probably and some more
# HEADERS_HAVE_EXTRA_SHIT := y
$(error "This module has not been tested on other versions, remove this at your own peril")
endif
endif
endif
MODULES_EXTRA_DIR := $(MODULES_DIR)/extra
MODULES_LOAD_DIR := /etc/modules-load.d
MODULE_LOAD_LINE := "vangogh_oc_fix"
MODULE_FREQ ?= 3500
MODPROBE_DIR := /etc/modprobe.d
MODPROBE_LINE := "options vangogh_oc_fix cpu_default_soft_max_freq=$(MODULE_FREQ)"

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
	make -C $(HEADERS_BUILD) CONFIG_GCC_PLUGINS=n CONFIG_HEADERS_HAVE_EXTRA_SHIT=$(HEADERS_HAVE_EXTRA_SHIT) M=$(shell pwd)/module modules

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
