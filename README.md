# Description
A linux kernel module to override AMD Van Gogh APU PowerPlay limits for CPU.
This is useful if you have overclocked your SteamDeck but still want to use
PowerTools to set clock limits.

This is mainly a proof of concept as getting it to work is unwieldy and will need to be done every SteamOS update. Hopefully smarter people will make an easier fix, or the limit in the amdgpu driver will be made configurable.

# Disclaimer
This software is distributed under the terms of the GPLv3 license. Please refer to the license for the full disclaimer and understand that by using this software, you do so at your own risk.

The module does a sanity check to ensure that it is trying to modify the right value, but this may fail and write to some unknown place in kernel memory which BAD™.

# Future plans
Wait and see if someone else does it better. Otherwise I'll do it myself.

# How to build
- Install all tools required to build linux kernel
- Set variables in Makefile appropriate for your SteamDeck's linux kernel.
- On your build machine
    - `make build`
    - Your module should now be at `module/vangogh_oc_fix.ko.xz`
- On your SteamDeck
    - On your SteamDeck create the folder `/lib/modules/$(uname -r)/extra`. You will need `sudo`. Copy  into the `extra` folder.
    - `sudo depmod -a`
    
# How to run

You can load the module with:

`sudo modprobe vangogh_oc_fix cpu_default_soft_max_freq=<Max clock speed in Mhz>`. 

Note that this is still limited by the clock speed set in your BIOS and only
determines the maximum that can be set through the AMD PowerPlay interface
(which PowerTools uses).

This will only run for your current boot. You can add modules to load on boot, but I will not elaborate on that here.
