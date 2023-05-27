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

url:
	echo STEAMOS_HEADERS_URL $(STEAMOS_HEADERS_URL)

steamos-headers.tar.zst:
	wget $(STEAMOS_HEADERS_URL) -O$@

download-headers: steamos-headers.tar.zst

steamos-headers: steamos-headers.tar.zst
	mkdir $@
	tar --use-compress-program=unzstd -xvf $< -C $@

$(HEADERS_BUILD): steamos-headers

module/vangogh_oc_fix.ko: $(HEADERS_BUILD) module/*.c
	make -C $(HEADERS_BUILD) CONFIG_GCC_PLUGINS=n M=$(shell pwd)/module modules

module/vangogh_oc_fix.ko.xz: module/vangogh_oc_fix.ko
	xz --keep --check=crc32 --lzma2=dict=512KiB $< -c > $@

build: module/vangogh_oc_fix.ko.xz

clean: $(HEADERS_DIR)
	make -C $(HEADERS_BUILD) M=$(shell pwd)/module clean

git-tag:
	echo $(LINUX_GIT_TAG)

uname:
	echo $(UNAME)

.PHONEY: all clean download-headers git-tag uname build url
