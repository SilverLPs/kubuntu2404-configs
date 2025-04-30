These scripts and resources are designed to manually install and automatically configure a Kubuntu 24.04 LTS system with my preferred settings.
The focus is on system reliability, reasonable low latency improvements and a traditional and conservative approach to a still modern desktop experience.

### IMPORTANT:
This is just a personal project I worked on for my own needs. It’s definitely not a professional product, nor is it meant to be treated like one. I’m only sharing it in case someone else might find it useful, but please don’t expect anything close to finished, polished, or well-developed software. Make sure to read the License and Disclaimer section below in this README before even thinking about using the scripts or any of the resources.

## Quick Start
> [!NOTE]
> The output may exceed the visible area in Konsole, so it will be saved (STDERR + STDOUT) to a log file in `~/.local/share`.

If not run with any arguments (like in the command below), this script will assume you are on a desktop-environment and will show you GUI interfaces like a menu to choose which parts of the script you want to run. If you want to run this script in a non-desktop-environment you will need to specify at least one argument!

```bash
cd "$HOME/.local/share"
git clone https://github.com/SilverLPs/kubuntu2404-configs.git
./kubuntu2404-configs/run.sh |& tee -a "$HOME/.local/share/kubuntu2404-configs-$(date +\%Y\%m\%d)-$(date +\%H\%M\%S).log"
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
--studio | Installs specific audio/video studio utilities and configurations. Does not install actual big applications only small tools!
--focusrite_scarlett | Installt software for Focusrite Scarlett audio interfaces

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
        - Do not enable auto-login — it interferes with KDE Wallet. See Post-usage for a safer method.
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
- Verify script

## Studio (Audio) Setup Notes

### Kernel Information
- Kubuntu 24.04 LTS ships with excellent kernel options out of the box:
    - `CONFIG_PREEMPT_DYNAMIC=y`: Allows dynamic switching between `none`, `voluntary`, and `full` preemption via GRUB parameters without recompiling.
        - Check current mode: `sudo cat /sys/kernel/debug/sched/preempt`
    - `CONFIG_NO_HZ_FULL=y`
    - `CONFIG_HIGH_RES_TIMERS=y`
    - `CONFIG_LATENCYTOP=y`
    - `CONFIG_HZ=1000`
    - [Further details](https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/noble/commit/?h=master-next&id=2396118b8bc59c35fb50839e8f190922251c3fad)
- **Recommended Kernel Usage:**
    - The default Kubuntu 24.04 LTS kernel with full PREEMPT (not PREEMPT_RT) is highly stable and predictable, although not tuned for absolute minimum latencies under 5ms.
    - **Avoid PREEMPT_RT kernels:** Despite slightly better real-time stability, they drastically reduce overall DSP performance, severely impacting DAW usability, and can cause frequent system freezes or crashes, especially under low memory conditions.
    - **Liquorix kernel:** While offering impressive real-time stability under load, it may cause unpredictable full system freezes up to multiple seconds (**!**) due to experimental scheduler behavior. Usage is discouraged, especially for less experienced users.

### Real-Time Capabilities and Limitations
- **Expected Latency Behavior with Default Kernel (PREEMPT Full Mode):**
    - **512 buffer (10.4ms):** Fully stable and predictable even under moderate background load. Recommended for recordings and live usage with minimal background activity.
    - **256 buffer (5.2ms):** Generally stable but not recommended for critical recording/live use due to rare xruns under load. Avoid background processes, as these will lead to xruns much quicker than on higher buffers.
    - **128 buffer (2.6ms):** Very sensitive. Even minimal background load can cause xruns. Only usable for non-critical scenarios without any background load; xruns will probably still occur frequently, even in idle state.
- **Additional Notes:**
    - Opening/closing applications (e.g., browsers, Electron apps like Discord) can cause xruns even with high buffers (e.g., 1024 samples).
    - General/non-pro-audio desktop applications are not optimized for low-latency audio on Linux. They do not auto-adjust CPU priorities, causing minor audio glitches under background load (not always counted as xruns by PipeWire) at lower buffer sizes. This issue should lessen in future years. Until then it is not recommended to set Pipewires default buffer size below 512 if stable non-pro-audio is a requirement.
        - Important: These glitches are application-side dropouts, not PipeWire or ALSA failures. Windows handles this via background services adjusting priorities dynamically; Linux does not, requiring manual tuning if necessary.

### PipeWire / Audio Stack Best Practices
- **USB Audio Devices:**
    - Most USB audio interfaces are class-compliant. Simply plug them in and set them to "Pro Audio" mode in KDE's volume tray widget.
- **Mission-Critical Recommendations:**
    - Set a different device as the default output in KDE's audio tray widget to prevent background applications from interfering with the Pro Audio interface.
    - Close applications that access multiple audio devices simultaneously.
- **Latency Management:**
    - **Current issue:** Automatic latency negotiation in PipeWire is not yet fully reliable for Pro Audio use.
    - **Solution:** Manually fix PipeWire's quantum clock settings:
        - Create pipewire config file: `sudo mkdir /etc/pipewire` and `sudo cp /usr/share/pipewire/pipewire.conf /etc/pipewire/`
        - In `/etc/pipewire/pipewire.conf`, uncomment and set `default.clock.quantum` and `default.clock.max-quantum` **(Both should be identical)**.
        - Optionally, set `default.clock.rate` and `default.clock.allowed-rates` similarly for fixed sample rates.
        - Restart PipeWire: systemctl --user restart pipewire pipewire-pulse and systemctl --user daemon-reload
- **Pipewire APIs:**
    - For PipeWire JACK API:
        - Latency can be set by starting applications like this: `PIPEWIRE_LATENCY="1024/48000" bitwig-studio`
    - For PipeWire ALSA API:
        - Applications must support PipeWire's virtual ALSA device. Some apps (e.g., DaVinci Resolve) work despite being ALSA-only, others refuse to communicate with non-physical devices, which makes them incompatible with PipeWires ALSA API.
- **PipeWire Latency Behavior:**
    - Latency handling in PipeWire works fundamentally differently than in JACK. In JACK, ALSA is reconfigured at the start of the JACK daemon, and the configuration remains static until JACK is stopped. PipeWire, on the other hand, abstracts most of the communication with ALSA even in Pro Audio mode and usually automatically selects the best settings.
        - Applications do not directly configure ALSA when setting up their requested buffer size. Instead, they pass their request to PipeWire, which tries to implement it in ALSA as accurately and stably as possible.
        - As a result, PipeWire clients do not configure a period number, and the buffer size they request is a **PipeWire buffer, not an ALSA buffer**. Therefore, the traditional JACK latency calculations (buffer size × periods) do not apply to PipeWire.
    - PipeWire itself configures ALSA with a very high number of periods, not to define the working latency but simply to allow seamless switching between different latency settings.
        - This means that when an application calculates latency based only on the requested buffer size (without multiplying by the period number), the result is correct — similar to how Windows applications handle audio buffer latency (e.g., Bitwig Studio displays the correct latency value).
    - Only with batch devices (mainly very big/special USB interfaces with subdevices) using timer-based scheduling (instead of IRQ scheduling) you should add about +50% to the effective buffer/latency. For example, a 10ms buffer would result in approximately 15ms of effective latency, and 5ms would become 7.5ms.
    - It is **no longer necessary** in PipeWire to stick to "even" millisecond buffer values for USB devices (e.g., 240 samples at 48kHz for 5ms or 480 samples for 10ms) — any value generally works.
    - In Pro Audio profiles, devices are usually operated in **IRQ mode** (low-latency interrupt scheduling). Only if an interface exposes multiple subdevices via UCM, PipeWire may automatically switch to **timer mode**, because IRQ scheduling does not work well with multiple subdevices.
        - Manual adjustment to force IRQ mode can still be attempted if needed, but most interfaces are not affected anyway.
        - You can check whether a device is operating in IRQ mode by running: `pw-dump | grep tsched`
            - If `"api.alsa.disable-tsched"`: true appears in the output (for devices in Pro Audio mode), IRQ mode is active. Otherwise, the device is running in timer mode and may experience the +50% additional buffer.
        - If multiple devices are combined and used simultaneously within a single application, PipeWire will also automatically use timer mode to ensure stable operation across all devices — again, resulting in the +50% additional latency.

### Potential Further Optimizations (Not Yet Implemented, Usually Not Needed)
- **CPU Isolation & Pinning:**
    - Reserving CPU cores 0-1 for the system and dedicating others exclusively to audio (ALSA, PipeWire, DAWs, USB interrupts) could allow extremely low, stable latencies.
    - Requires considerable setup effort.
- **CPU Governor:**
    - Setting governor to "Performance" showed no significant improvements but can be tested via KDE’s battery/performance tray widget or `powerprofilesctl`.
- **Boot Parameter:** `mitigations=off`
    - Disabling CPU vulnerability mitigations can improve performance but leaves the system exposed to Spectre/Meltdown attacks. Use only as a last resort.
- **CPU Power States:**
    - Forcing CPUs to stay fully active can reduce latency but increases heat and power consumption drastically.
        - Example udev rule: [Ardour 99-cpu-dma-latency.rules](https://github.com/Ardour/ardour/blob/master/tools/udev/99-cpu-dma-latency.rules)
    - Apply with: `sudo udevadm control --reload-rules` and `sudo udevadm trigger`
- **IRQ Prioritization:**
    - Using tools like `rtirq` or `rtcirqus`:
        - `rtirq`: Flexible, manual prioritization.
        - `rtcirqus`: Newer tool; Automatic, but less configurable as of May 2024.
        - Note: `threadirqs` kernel option is necessary for these applications and already enabled by this script.
- **USB Stability:**
    - Setting boot parameter `usbcore.autosuspend=-1` can improve USB reliability but increases power usage. Disabled by default.
- **Memory Locking:**
    - Editing `/etc/security/limits.d/25-pw-rlimits.conf` to set `memlock unlimited` can allow larger locked memory allocations.
        **Warning:** Can cause freezes if applications reserve excessive memory. Only needed with special memory-heavy setups.

## Miscellaneous

### Script Issues
- The qpwgraph configuration (needed to disable the system tray icon running in background all the time) is not idempotent, so it will backup the old config and then overwrite it entirely, could possibly be fixed in the future by using a different INI-parser tool than kwriteconfig5, which has a bug (look at the comments in the script for more information).
- The fcitx5 configuration (needed to disable the system tray icon of the keyboard layout) is not idempotent, so it will backup the old config and then overwrite it entirely. This could possibly be fixed in the future if there is another way to disable (or even better just hide) the fcitx5 system tray icon (look at the comments in the script for more information).

### Kubuntu 24.04 Issues
- KDE-Bug 433569 Color change for Titlebar and window header isn't synchronized when window becomes active or inactive: No reliable fix yet. A workaround might be possible by manually editing color schemes, but this is unstable and may be reset by updates (see bugtracker ticket for details). However, this bug is barely noticable at all.
- Ubuntu 24.04 distros still don't have reliable access to dracut for generating the initramfs
    - This introduces the following issues:
        - The language in the update screen (plymouth) is not localized and always in English
        - LUKS disk decryption with the TPM module is not available, so the password gets prompted at every boot
    - Dracut will be implemented in Ubuntu 25.10 and is going to replace initramfs-tools. This should make it possible to fix both problems in Kubuntu 26.04 LTS.

### Automation Issues
- Automating the installation of extensions (like UBlock Origin Lite) from the Chromium Store is almost impossible, unless I would use Policies/"External Extensions" which will both force the installation and will make it impossible to uninstall it via Chromium itself.
- Automating the addition of "places"-entries for Dolphin/KDE File Picker is difficult as the entrys are saved in a large XBEL (xml-style) file in $HOME/.local/share/user-places.xbel. It could be edited with an XML tool but the entries all have UUID-like IDs, so this can not be replicated without knowing the exact logic behind this file. Also there seem to be no CLI or DBus ways to interact with this file.
- Automating autologin is almost impossible at the moment, not because of the autologin setting itself (that is just 2 lines in the sddm.conf ini) but because of KDE wallet which will then ask for a password everytime once per login when an app tries to use the wallet. There are 2 solutions to this:
    - Set KDE wallet password to blank/empty, while insecure (defacto decrypted wallet!) it will avoid the password prompts completely while not affecting the functionality. However, there is no CLI tool or DBus call to automate this, it has to be done manually via GUI.
    - The professional solution would be to use something like pam_autologin, to use the password even for SDDM autologin and therefore automatically decrypt the Wallet at login. While it seems to be technically possible, it is not supported in Kubuntu 24.04 and there is [almost](https://bbs.archlinux.org/viewtopic.php?id=285783) no documentation on how to implement this. For the sake of stability, this should not be used unless it becomes supported in the future. Side note: A big chunk of the autologin situation could be solved in Kubuntu 26.04 which will most likely be able to use TPM disk decryption thanks to dracut. This will make autologin unnecessary in LUKS setups as the double password prompt will be solved with automatic TPM disk decryption.

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
