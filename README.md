# Description
A linux kernel module to override AMD Van Gogh APU PowerPlay limits for CPU.
This is useful if you have overclocked your SteamDeck but still want to use
PowerTools to set CPU clock limits. You do not need this for GPU overclocking.

Note that you still need a `pt_oc.json` to tell PowerTools that it can go that
hard. Conservesly, the way PowerTools works as of writing this (2023-03-06) will
not go past stock settings even if you have a `pt_oc.json` but not this module.
Similarly, you still need to set your maximum clock speed through the BIOS,
either through SmokelessUMAF or SD_Unlocker depending on your BIOS version.

You will need to reinstall the module each SteamOS update as it wipes the file
system. Hopefully smarter people will make an easier fix, or the limit in the
amdgpu driver will be made configurable.

# Disclaimer
This software is distributed under the terms of the GPLv3 license. Please refer
to the license for the full disclaimer and understand that by using this
software, you do so at your own risk.

The module does a sanity check to ensure that it is trying to modify the right
value, but this may fail and write to some unknown place in kernel memory which
BAD™.

# How to build & install
Step-by-step guide to build & install it on SteamOS 3.4.10:

- Go to desktop mode
- Open terminal and type or paste `sudo steamos-readonly disable` and type your root password
- On the same terminal type or paste `sudo pacman -S base-devel` and confirm with `y` + Enter
- Download `0.0.1` source from [0.0.1 release](https://github.com/badly-drawn-wizards/vangogh_oc_fix/releases/tag/0.0.1)
- Extract the source folder `vangogh_oc_fix-0.0.1`
- Open the new `vangogh_oc_fix-0.0.1` folder
- Right click on an empty space inside the folder and click Open terminal here
- On the new terminal type or paste `make build`
- Read the text about missing headers, copy & paste the command it reads on the same terminal
- Type or paste `make build` again
- Type or paste `sudo make install`
- Now you can either:
  - Run it in the current boot with `sudo modprobe vangogh_oc_fix cpu_default_soft_max_freq=<freq in Mhz>`

  - Run it every boot with `sudo make install-conf MODULE_FREQ=<freq in Mhz>` You will need to run `sudo modprobe vangogh_oc_fix` to run for the current boot
- On terminal type or paste `sudo steamos-readonly enable`
- Now you are done, no need to mess with it until a new SteamOS update breaks PowerTools OC again

# How to add support specific kernels

This project depends on unstable internel APIs of the amdgpu<sup>[1]</sup>
driver. In version `0.0.1` I created c header files to mirror the header files
in the kernel, but this not a great idea. In this version I copy the header
files for a specific kernel version and store them for each version in source
control.

Right now I have only added suport for `6.1.21-valve1`. If you want support for,
as of writing, stable release `5.*.*`, then use version `0.0.1`.

To add support for a kernel version, find the the linux-nepture source for your
release channel and version on the [SteamDeck
archlinux-mirror](https://steamdeck-packages.steamos.cloud/archlinux-mirror/sources/)
and extract it to `./linux-header-extract/linux-pkg`. Then run `make
linux-pkg-prepare` followed by `make extract-headers`. You can then use it for
yourself or submit a PR so others won't need this process.

[1] In addition to what the name of the driver suggests, it also exposes the
interface that PowerTools uses to adjust the CPU clock.
