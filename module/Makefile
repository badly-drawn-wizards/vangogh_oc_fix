ccflags-y += -I$(src)/amd/pm/swsmu/inc

# Copied from amdgpu/Makefile and display/Makefile, copyright blurb below
#
# Copyright 2017 Advanced Micro Devices, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
#
# Makefile for the drm device driver.  This driver provides support for the
# Direct Rendering Infrastructure (DRI) in XFree86 4.1.0 and higher.
FULL_AMD_PATH:=$(srctree)/drivers/gpu/drm/amd
DISPLAY_FOLDER_NAME=display
FULL_AMD_DISPLAY_PATH = $(FULL_AMD_PATH)/$(DISPLAY_FOLDER_NAME)
ccflags-y += -I$(FULL_AMD_PATH)/include/asic_reg \
	-I$(FULL_AMD_PATH)/include \
	-I$(FULL_AMD_PATH)/amdgpu \
	-I$(FULL_AMD_PATH)/pm/inc \
	-I$(FULL_AMD_PATH)/acp/include \
	-I$(FULL_AMD_DISPLAY_PATH) \
	-I$(FULL_AMD_DISPLAY_PATH)/include \
	-I$(FULL_AMD_DISPLAY_PATH)/dc \
	-I$(FULL_AMD_DISPLAY_PATH)/amdgpu_dm \
	-I$(FULL_AMD_PATH)/amdkfd

ccflags-y += -I$(FULL_AMD_DISPLAY_PATH)/dc/inc/
ccflags-y += -I$(FULL_AMD_DISPLAY_PATH)/dc/inc/hw
ccflags-y += -I$(FULL_AMD_DISPLAY_PATH)/dc/clk_mgr
ccflags-y += -I$(FULL_AMD_DISPLAY_PATH)/modules/inc
ccflags-y += -I$(FULL_AMD_DISPLAY_PATH)/modules/freesync
ccflags-y += -I$(FULL_AMD_DISPLAY_PATH)/modules/color
ccflags-y += -I$(FULL_AMD_DISPLAY_PATH)/modules/info_packet
ccflags-y += -I$(FULL_AMD_DISPLAY_PATH)/modules/power
ccflags-y += -I$(FULL_AMD_DISPLAY_PATH)/dmub/inc

obj-m += vangogh_oc_fix.o
