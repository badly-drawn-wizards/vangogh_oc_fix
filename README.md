# Description
A linux kernel module to override AMD Van Gogh APU PowerPlay limits for CPU.
This is useful if you have overclocked your SteamDeck but still want to use
PowerTools to set clock limits. 

Note that you still need a `pt_oc.json` to tell PowerTools that it can go that hard. Conservesly, the way PowerTools works as of writing this (2023-03-06) will not go past stock settings even if you have a `pt_oc.json` but not this module. Similarly, you still need to set your maximum clock speed through the BIOS, either through SmokelessUMAF or SD_Unlocker depending on your BIOS version.

You will need to reinstall the module each SteamOS update as it wipes the file system. Hopefully smarter people will make an easier fix, or the limit in the amdgpu driver will be made configurable.

# Disclaimer
This software is distributed under the terms of the GPLv3 license. Please refer to the license for the full disclaimer and understand that by using this software, you do so at your own risk.

The module does a sanity check to ensure that it is trying to modify the right value, but this may fail and write to some unknown place in kernel memory which BAD™.

# How to build & install
- Disable read only mode on your SteamDeck
- Install `base-devel` with pacman
- `make build` to build
    - If linux headers are not installed, it will tell which package to install.
      Once installed, rerun `make build`
- `sudo make install` to install the module
- You can either:
  - Run it in the current boot with `sudo modprobe vangogh_oc_fix cpu_default_soft_max_freq=<freq in Mhz>`. 
  - Run it every boot with `sudo make install-conf MODULE_FREQ=<freq in Mhz>`. you will need to run `sudo modprobe vangogh_oc_fix` to run for the current boot. 

# How to add support specific kernels

This project depends on unstable internel APIs of the amdgpu driver. In version `0.0.1` I created c header files to mirror the header files in the kernel, but this not a great idea. In this version I copy the header files for a specific kernel version and store them for each version in source control. 

Right now I have only added suport for `6.1.21-valve1`. If you want support for, as of writing, stable release `5.*.*`, then use version `0.0.1`.

To add support for a kernel version, find the the linux-nepture source for your release channel and version on the [SteamDeck archlinux-mirror](https://steamdeck-packages.steamos.cloud/archlinux-mirror/sources/) and extract it to `./linux-header-extract/linux-pkg`. Then run `make linux-pkg-prepare` followed by `make extract-headers`. You can then use it for yourself or submit a PR so others won't need this process.
