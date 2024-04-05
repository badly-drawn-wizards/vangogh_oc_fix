# Disclaimer
I am no longer actively working on this project. @lividhen is the currently maintaining thr project hopefully until a fix is merged into steamos and this project becomes obsolete.

# Description
A linux kernel module to override AMD Van Gogh APU PowerPlay limits for CPU.
This is useful if you have overclocked your SteamDeck but still want to use
PowerTools to set CPU clock limits. You do not need this for GPU overclocking.

Note that you still need a `pt_oc.json` to tell PowerTools that it can go that
hard. Conversely, the way PowerTools works as of writing this (2023-03-06) will
not go past stock settings even if you have a `pt_oc.json` but not this module.
Similarly, you still need to set your maximum clock speed through the BIOS,
either through SmokelessUMAF or SD_Unlocker depending on your BIOS version. 
The Steam Deck Oled bios has overclocking built in after steamos 3.5.17 and do not need to be unlocked.

You will need to reinstall the module each SteamOS update as it wipes the file
system. Hopefully smarter people will make an easier fix, or the limit in the
amdgpu driver will be made configurable.

Autostart service currently broken

# Disclaimer
This software is distributed under the terms of the GPLv3 license. Please refer
to the license for the full disclaimer and understand that by using this
software, you do so at your own risk.

The module does a sanity check to ensure that it is trying to modify the right
value, but this may fail and write to some unknown place in kernel memory which
BAD™.

# How to build & install
- Install `base-devel` and `linux-neptune-61` with pacman.
  - If it fails to find the linux-neptune package or make fails run `uname -r` and replace 61 with the last 2 numbers.
- Run `./install.sh`.
- You can either:
  - Run it in the current boot with `sudo modprobe vangogh_oc_fix
    cpu_default_soft_max_freq=<freq in Mhz>`.
  - Run it every boot with `sudo make install-conf MODULE_FREQ=<freq in Mhz>`.
    you will need to run `sudo modprobe vangogh_oc_fix` to run for the current
    boot.
- GPU speed is automatically determined.

# How to manually add support specific kernels

This project depends on unstable internel APIs of the amdgpu<sup>[1]</sup>
driver. In version `0.0.1` I created c header files to mirror the header files
in the kernel, but this not a great idea. In this version I copy the header
files for a specific kernel version and store them for each version in source
control.

Right now I have only added suport for `6.1.52-valve16`. If you want support for,
as of writing, stable release `5.*.*`, then use version `0.0.1`.

To add support for your kernel version, enter the linux-header-extract directory and run get.sh.  Then run `make
linux-pkg-prepare` followed by `make extract-headers`. You can then use it for
yourself or submit a PR so others won't need this process.

[1] In addition to what the name of the driver suggests, it also exposes the
interface that PowerTools uses to adjust the CPU clock.
