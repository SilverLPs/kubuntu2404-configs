These scripts and resources are designed to manually install and automatically configure a Kubuntu 24.04 LTS system with my preferred settings.
The focus is on system reliability, reasonable low latency improvements and a traditional and conservative approach to a still modern desktop experience.

### IMPORTANT:
This is just a personal project I worked on for my own needs. It’s definitely not a professional product, nor is it meant to be treated like one. I’m only sharing it in case someone else might find it useful, but please don’t expect anything close to finished, polished, or well-developed software. Make sure to read the License and Disclaimer section below in this README before even thinking about using the scripts or any of the resources.

## Quick Start
> [!NOTE]
> The output may exceed the visible area in Konsole, so it will be saved (STDERR + STDOUT) to a log file in `~/.local/share`.

```bash
git clone https://github.com/SilverLPs/kubuntu2404-configs.git
cd ./kubuntu2404-configs
./run.sh --system --user |& tee -a "$HOME/.local/share/kubuntu2404-configs-$(date +\%Y\%m\%d)-$(date +\%H\%M\%S).log"
```

### Arguments:
Parameter | Description
--- | ---
--autoreboot | Automatically reboot the system when the script finished all tasks
--system | Apply default system configuration (recommended)
--user | Apply default user configuration (recommended)
--realtime | Adds user to the pipewire-group with realtime permissions. Recommended for low latency tasks like gaming and especially audio production. However, rare Pipewire bugs could freeze the system in edge cases, so don't enable this for maximum system stability.
--lighttheme | Switch from the default dark theme to the light theme.
--lighttheme-darkplasma | Change plasma elements like the taskbar, startmenu and widget to the dark theme look while using the light theme. The argument --lighttheme is still needed to active the light theme.

## Pre-Usage

### Kubuntu 24.04 Installation
- Boot the Kubuntu 24.04 install image.
    - For installations on physical PCs: Download and install Ventoy (Linux/Windows) from its official website.
        - Ventoy allows you to prepare a bootable USB stick using either CLI or GUI. It erases all data on the stick, but the process only needs to be done once per drive. Then it can be used for an unlimited number of bootable images.
    - Download the Kubuntu 24.04 LTS ISO, copy it to the Ventoy USB, and verify its checksum. Do not install if checksums don’t match — the file may be corrupted or tampered with. (SHA256 Checksum for kubuntu-24.04.1-desktop-amd64.iso `a828578f407471a69d13c0caa7cc0d4013f5b9f672de069e8017163d13695c3c`)
        - Use the Kubuntu 24.04.1 ISO unless your system has very new hardware (released around Q2/2024 or later). ISOs from 24.04.2 onward use newer kernels (HWE), which auto-upgrade every 6 months. See Kubuntu kernel versions below for details.
    - Boot from the USB flash drive (physical PC) or the virtual disc drive (VM). Choose the first option in the boot menu ("Try or Install Kubuntu") or wait 30 seconds.
- In the first screen select your language and internet connection, and begin installation:
    - Set your timezone, system language, and keyboard layout
        - Tip: In some languages like German, choose the “(no dead keys)” layout.
    - Select Normal installation (not minimal/full) and check boxes for Virtual Machine Manager and updates.
        - Don't select Krita or Element here. Install the Flatpak or AppImage version later to get the latest release.
    - Choose your drive and erase it, making sure swap file creation is enabled and ext4 is chosen.
        - Dual-boot setups may cause issues (especially with Windows). Prefer full-disk installation with separate physical drives for multi-boot systems.
        - LUKS disk encryption is optional but requires password entry on every boot and update. See Security Levels Concept below.
            - Note: TPM-based encryption (like BitLocker) is not supported yet.
    - Create a username, device name, and password.
        - Do not enable auto-login—it interferes with KDE Wallet. See Post-usage for a safer method.
        - If you want a "no password" feel, using a space as password works but is very insecure. Understand the risks (see Security Levels Concept).
        - Use only lowercase letters and numbers for usernames — avoid special characters.
    - Complete installation and restart. Remove USB when prompted or as needed.

### Script Notes
- These scripts were tested on installations following the above steps exactly. While they should work on any Kubuntu 24.04 system, unexpected behavior is possible if your setup differs. Use at your own (increased) risk.

### Kubuntu Kernel Versions
Ubuntu 24.04 (and its flavors like Kubuntu) support two kernel channels: GA and HWE.

**GA (General Availability):**

- Default with Ubuntu 24.04 and the 24.04.1 ISO.
- Installs Kernel 6.8 with only minor updates (e.g., security, bug fixes).
- Most stable and predictable; ideal unless your hardware is too new.

**HWE (Hardware Enablement):**

- Used in ISOs from 24.04.2 onward.
- Brings newer kernels with major upgrades, which may introduce instability.
- Only use if the GA kernel doesn’t support your hardware properly.

> [!NOTE]
> Some core components like X11 may also differ between GA and HWE.

To switch from HWE to GA manually:

```bash
sudo -s
apt-get install -y --install-recommends linux-generic
DEBIAN_FRONTEND=noninteractive apt-get remove  -y --purge linux-generic-hwe-24.04 linux-hwe-* linux-modules-6.11* linux-modules-6.11* linux-modules-6.11*
exit
```

Then double check with:

```bash
sudo dpkg -l | grep hwe
```

*Only one systemd line should remain. If others appear, some HWE packages are still present.*

and:

```bash
apt-get remove --purge '*-hwe-24.04'
```

*This should list all the hwe packages as uninstalled*

### Security Levels Concept
Security level | Description | Notes
--- | --- | ---
0: No security | No disk encryption, space as password, auto-login + empty KDE Wallet password | Only for testing
1: Low security | No disk encryption, normal password, auto-login + empty KDE Wallet password | For beginners (e.g., your grandma) who'd otherwise refuse Linux and use Windows insecurely anyway
2: Medium security | No disk encryption, normal password, manual login | For non-critical, stationary systems
3: High security | Encrypted disk, normal password, auto-login + empty KDE Wallet password | For mobile or critical systems needing data protection
4: Paranoia | Encrypted disk, normal password, manual Login | Maximum runtime and storage security, but requires multiple logins

## Post-Usage

### Additional manual Configurations
- Enable auto-login (if desired)
    - Avoid additional password prompts by setting KDE Wallet password to empty — but do not disable KDE Wallet. It’s critical for many apps.
- Install uBlock Origin in Chromium/Firefox
- If disk encryption is used, you'll see the "kubuntu_2404" partition twice in Dolphin. The lock-icon entry is redundant and can be hidden.
- Add a Dolphin "places" shortcut to your `~/Apps` folder
- Disable Bluetooth/Wi-Fi if unused
    - Improves power usage, interrupt handling, and latency. BIOS/hardware-switch disablement is best.

### Verify important Configurations
- Verify realtime kernel mode

## Miscellaneous

### Script Issues
n/a

### Kubuntu 24.04 Issues
- KDE-Bug 433569 Color change for Titlebar and window header isn't synchronized when window becomes active or inactive: No reliable fix yet. A workaround might be possible by manually editing color schemes, but this is unstable and may be reset by updates (see bugtracker ticket for details). However, this bug is barely noticable at all.
- Ubuntu 24.04 distros still don't have reliable access to dracut for generating the initramfs, which introduces the following issues:
    - The language in the update screen (plymouth) is not localized and always in English
    - LUKS disk decryption with the TPM module is not available, so the password gets prompted at every boot

### Automation Issues
- Automating the installation of extensions (like UBlock Origin Lite) from the Chromium Store is almost impossible, unless I would use Policies/"External Extensions" which will both force the installation and will make it impossible to uninstall it via Chromium itself.
- Automating the addition of "places"-entries for Dolphin/KDE File Picker is difficult as the entrys are saved in a large XBEL (xml-style) file in $HOME/.local/share/user-places.xbel. It could be edited with an XML tool but the entries all have UUID-like IDs, so this can not be replicated without knowing the exact logic behind this file. Also there seem to be no CLI or DBus ways to interact with this file.

## License and Disclaimer

All content is licensed under GPLv3. See [LICENSE](LICENSE) for more details.
This project uses and redistributes freely licensed resources from:
- KDE
- Ubuntu/Kubuntu

### Disclaimer of Warranty and Responsibility

This is a private project developed in my spare time. It is provided "as is" without any warranty of any kind, either expressed or implied. I cannot offer any guarantees regarding its functionality, security, or suitability for a specific purpose. Anyone using the software does so entirely at their own risk.

### Use at Your Own Risk

Users are encouraged to thoroughly review the scripts and all other files before using them. The software, including all of the scripts themself and all associated files, is intended for technically proficient users who understand the potential risks and can assess whether the software meets their requirements. If you are not confident in your technical ability to understand or review the code, I strongly advise against using this software.

### Recommendations for Technical Users

- Carefully review the provided scripts and configurations before running them.
- Test the software in a safe environment before applying it to critical data or systems.
- Use the software only if you are comfortable with its functionality and limitations.

This project is not intended for non-technical users, and I explicitly discourage anyone without a strong technical understanding from using this software.
