# Description
A linux kernel module to override AMD Van Gogh APU PowerPlay limits for CPU.
This is useful if you have overclocked your SteamDeck but still want to use
PowerTools to set clock limits.

This is mainly a proof of concept as getting it to work is unwieldy and will need to be done every SteamOS update. Hopefully smarter people will make an easier fix, or the limit in the amdgpu driver will be made configurable.

# Disclaimer
This software is distributed under the terms of the GPLv3 license. Please refer to the license for the full disclaimer and understand that by using this software, you do so at your own risk.

The module does a sanity check to ensure that it is trying to modify the right value, but this may fail and write to some unknown place in kernel memory which BAD™.

# How to build & install
- Install all tools required to build linux kernel
- Set variables in Makefile appropriate for your SteamDeck's linux kernel.
- `make build` to build
- `sudo make install` to install the module
- `sudo make install-conf MODULE_FREQ=<freq in Mhz>` to automatically load the module with the given frequency
    
# How to run

You can load the module with:

`sudo modprobe vangogh_oc_fix cpu_default_soft_max_freq=<freq in Mhz>`. 

Note that this is still limited by the clock speed set in your BIOS and only
determines the maximum that can be set through the AMD PowerPlay interface
(which PowerTools uses).

This will only run for your current boot. To run every boot, use the `install-conf` target mentioned above
