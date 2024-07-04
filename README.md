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

Type the following into a terminal:
- `sudo steamos-readonly disable`
- `sudo pacman -Sy base-devel`

Now we need to know what header packages to install.
- `uname -r`
With the output of this command you will see something like:

`6.1.52-valve16-1-neptune-61`

Now type:
- `sudo pacman -Ss linux-neptune`

Which will give you the output such as:
`jupiter-3.5/linux-neptune-61 6.1.52.valve16-1`
`jupiter-3.5/linux-neptune-61-headers 6.1.52.valve16-1`

This will tell us the package names that relate to our kernel version.
We want the ones that match, so in our example, we're running neptune-61, we type:

- sudo pacman -S linux-neptune-61 linux-neptune-61-headers`

Now, onto installing the fix. By default SteamOS will put you into the `/home/deck` folder.
Using the commands `cd` and `pwd` you can change directory, and also check what directory
you are in, to be able to navigate to where you have extracted or cloned this repo to.
If you're unsure how to do this, [learn more about the terminal](https://ubuntu.com/tutorials/command-line-for-beginners).
Once you're in the correct folder, you can install with:

- `./install.sh`

You should now be prompted for the CPU frequency, enter the same value as you have set in the BIOS.
GPU frequency is automatically determined, this is solely for the CPU.

If this does not work, read the messages on the screen. If it does not install, then you
will need to manually add support for your specific kernel (this can happem when SteamOS
has updated beyond what is supplied with this repo) and then run the install again. Follow
the instructions below.

# How to manually add support specific kernels

This project depends on unstable internel APIs of the amdgpu<sup>[1]</sup>
driver. In version `0.0.1` I created c header files to mirror the header files
in the kernel, but this not a great idea. In this version I copy the header
files for a specific kernel version and store them for each version in source
control.

Support provided with this repo' is stored in `/module/amd_headers/`.

Note this will download approximately 3.2gb of data.

To add support for your kernel version:
- `cd` to `/linux-header-extract directory` and
- Type `./get.sh`
- Then type `make -j$(nproc) linux-pkg-prepare`
- Then type `make -j$(nproc) extract-headers`

You can then use it for yourself or submit a pull request so others won't need to do this process.

If you're using SteamOS beta, preview or main then get.sh may not grab the correct file, until
get.sh is adapted to accommodate for this you will need to manually edit the script to get the
correct headers file.

If you are in need of a different version of the kernel headers is giving you, you can download it from [here](https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/).
It is prefaced with linux-neptune (eg linux-neptune-61-6.1.52.valve16-1-x86_64.pkg.tar.zst). Then run `sudo pacman -U /path/to/linux-neptune-headers`.

[1] In addition to what the name of the driver suggests, it also exposes the
interface that PowerTools uses to adjust the CPU clock.
