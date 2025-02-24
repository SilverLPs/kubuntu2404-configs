# Output is too large for the konsole windows, copy STDERR and STDOUT into a textfile by using this command:
# sudo bash ./01-default_system_config.sh |& tee "$HOME/01-default_system_config.log"

if [ -z "${SUDO_USER}" ]; then
    echo "ERROR: This script needs to be started in sudo context, opened by the main normal user account of this computer, it can't be run just as root or a normal user!"
    exit 1
fi

echo "Starting default system configuration"
echo

bash ./modules/fstab_notrim.sh
echo

bash ./modules/grub_add_preempt.sh
bash ./modules/grub_add_threadirqs.sh
echo

update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/bgrt/bgrt.plymouth 160
update-initramfs -u -k all
update-grub
echo

echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
apt-get install -q -y curl net-tools iftop btop htop neofetch kubuntu-restricted-extras gstreamer1.0-vaapi libvdpau-va-gl1 fonts-crosextra-carlito fonts-crosextra-caladea exfatprogs synaptic chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg-extra openjdk-17-jre vlc vlc-plugin-fluidsynth vlc-plugin-jack vlc-plugin-pipewire vlc-plugin-svg nfs-common flatpak kde-config-flatpak plasma-discover-backend-flatpak pipewire-jack pipewire-alsa latencytop kolourpaint

flatpak -v remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo

#This config file was auto-generated by KDEs system settings application after applying the breeze theme and after applying "plasma settings" onto it (there is a button for this setting)
cp -v ./configs/sddm/kde_settings.conf /etc/sddm.conf.d/kde_settings.conf
chmod 644 /etc/sddm.conf.d/kde_settings.conf
echo

usermod -a -G pipewire "${SUDO_USER}"

echo "vm.swappiness = 10" > /etc/sysctl.d/98-swappiness.conf
chmod 644 /etc/sysctl.d/98-swappiness.conf
cat /etc/sysctl.d/98-swappiness.conf
echo

cp -v /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/
ldconfig
