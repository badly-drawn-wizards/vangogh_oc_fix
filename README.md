# Disclaimer
I am no longer actively working on this project. @lividhen is the currently maintaining thr project hopefully until a fix is merged into steamos and this project becomes obsolete.

# Description
A linux kernel module to override AMD Van Gogh APU PowerPlay limits for CPU.
This is useful if you have overclocked your SteamDeck but still want to use
PowerTools to set CPU clock limits. You do not need this for GPU overclocking.

Note that you need to setup [custom overrides](https://git.ngni.us/NG-SD-Plugins/PowerTools/wiki/Customization) to tell PowerTools that it can go that
hard. Conversely, the way PowerTools works as of writing this (2024-06-06) will
not go past stock settings even if you have custom overrides.
Similarly, you still need to set your maximum clock speed through the BIOS,
either through SmokelessUMAF or SD_Unlocker depending on your BIOS version. 
The Steam Deck Oled bios has overclocking built in after BIOS 109 on the OLED
Steam Deck and after BIOS 131 on the LCD deck, and do not need to be unlocked
except if you want to override the TDP which requires modifications with [SREP](https://www.stanto.com/steam-deck/how-to-unlock-the-lcd-and-oled-steam-deck-bios-for-increased-tdp-and-other-features/).

You will need to reinstall the module each SteamOS update as it wipes the file
system. Hopefully smarter people will make an easier fix, or the limit in the
amdgpu driver will be made configurable. There are issues raised about this on
[gitlab](https://gitlab.freedesktop.org/drm/amd/-/issues/2638) and [github](https://github.com/ValveSoftware/SteamOS/issues/1309).

# Disclaimer
This software is distributed under the terms of the GPLv3 license. Please refer
to the license for the full disclaimer and understand that by using this
software, you do so at your own risk.

The module does a sanity check to ensure that it is trying to modify the right
value, but this may fail and write to some unknown place in kernel memory which
BAD™.

# How to build & install
- Type `sudo steamos-readonly disable` followed by `sudo pacman -Sy base-devel linux-neptune-61 linux-neptune-61-headers`
  - If you don't have enough space to install these packages please install [rwfus](https://github.com/ValShaped/rwfus)
  - If it fails to find the linux-neptune package or make fails run:
    - `uname -r` and compare that with the output of `sudo pacman -Ss linux-neptune`
  - The output of which should show you which package to install that matches your kernel version
- Run `./install.sh`.
  - Enter password and desired cpu clock speed when prompted
- GPU speed is automatically determined.

# How to manually add support specific kernels

This project depends on unstable internel APIs of the amdgpu<sup>[1]</sup>
driver. In version `0.0.1` I created c header files to mirror the header files
in the kernel, but this not a great idea. In this version I copy the header
files for a specific kernel version and store them for each version in source
control.

Support provided with this repo' is stored in `/module/amd_headers/`.

To add support for your kernel version:
- `cd` to `/linux-header-extract directory` and
- Type `get.sh`
- Then type `make -j$(nproc) linux-pkg-prepare`
- Then type `make -j$(nproc) extract-headers`

You can then use it for yourself or submit a pull request so others won't need to do this process.

If you are in need of a different version of the kernel headers is giving you, you can download it from [here](https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/).
It is prefaced with linux-neptune (eg linux-neptune-61-6.1.52.valve16-1-x86_64.pkg.tar.zst). Then run `sudo pacman -U /path/to/linux-neptune-headers`.

[1] In addition to what the name of the driver suggests, it also exposes the
interface that PowerTools uses to adjust the CPU clock.
