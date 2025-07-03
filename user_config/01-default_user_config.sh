# Check if user script is run as non-root user and exit if not
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: This script is not supposed to be run as root but as a normal user"
    exit 1
fi

# Check if the current directory is the same as the scripts location, otherwise relative paths in the script would not work
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPTDIR" || {
    echo "ERROR: Could not change current directory to scripts location. Please run the script from its actual location!"
    exit 1
}
echo "Changed current directory to scripts location: $(pwd)"
if [[ "$(pwd)" != "$SCRIPTDIR" ]]; then
    echo "ERROR: Could not change current directory to scripts location. Please run the script from its actual location!"
    exit 1
fi

echo "Starting default user configuration"
echo

# Install and enables custom plasma theme that contains various settings
# Plasma must run to apply the look and feel
mkdir -pv "$HOME/.local/share/icons/hicolor/16x16/apps"
cp -v ./resources/silverlps-kickoff.svg "$HOME/.local/share/icons/hicolor/16x16/apps/"
mkdir -pv "$HOME/.local/share/plasma/look-and-feel"
cp -vR ./configs/silverlps.breezedarkcustom.desktop "$HOME/.local/share/plasma/look-and-feel/"
plasma-apply-lookandfeel -a silverlps.breezedarkcustom.desktop --resetLayout
echo

# Install basic system tools flatpaks
flatpak install --noninteractive flathub com.github.tchx84.Flatseal
flatpak install --noninteractive flathub org.localsend.localsend_app
flatpak install --noninteractive flathub org.rncbc.qpwgraph
echo

# End KDE/Plasma related processes
#kquitapp5 plasmashell
# More processes like kwin or kactivitymanagerd and so on could be exited but for now that seems unnecessary

# kwriteconfig5 is fully idempotent and automatically creates config files and even folders if necessary, which makes mkdir or touch commands obsolete

# Disable KDE splash screen (useless and increases session load time)
kwriteconfig5 --file ksplashrc --group 'KSplash' --key 'Engine' 'none'
kwriteconfig5 --file ksplashrc --group 'KSplash' --key 'Theme' 'none'

# Disable bouncing cursor icons on application start
kwriteconfig5 --file klaunchrc --group 'FeedbackStyle' --key 'BusyCursor' --type bool false

# Disable animations for application preview popups in taskbar (these are plagued by heavy graphical glitches)
kwriteconfig5 --file kwinrc --group 'Plugins' --key 'kwin4_effect_fadingpopupsEnabled' --type bool false
kwriteconfig5 --file kwinrc --group 'Plugins' --key 'kwin4_effect_morphingpopupsEnabled' --type bool false

# Disable trigger of activating the window overview by putting the mouse in the top left corner of the screen (is triggered to easily and can interfere in daily operation when using maximized applications)
kwriteconfig5 --file kwinrc --group 'Effect-windowview' --key 'BorderActivateAll' '9'

# Change task switcher to thumbnail grid
kwriteconfig5 --file kwinrc --group 'TabBox' --key 'LayoutName' 'thumbnail_grid'

# Adding shortcut Meta+W to the triggers for the window overview and also removing the original Meta+W shortcut from the triggers for the activity switcher to avoid a duplicate shortcut trigger
kwriteconfig5 --file kglobalshortcutsrc --group 'kwin' --key 'Overview' 'Meta+W\tMeta+Tab,Meta+W,Toggle Overview'
# kwriteconfig5 has a bug that makes it impossible to correctly process the \t, it will always make \\t out of it. The sed command is necessary to fix that.
sed -i '/Overview/s/\\\\t/\\t/g' "$HOME/.config/kglobalshortcutsrc"
kwriteconfig5 --file kglobalshortcutsrc --group 'plasmashell' --key 'next activity' 'none,none,Walk through activities'
kwriteconfig5 --file kglobalshortcutsrc --group 'plasmashell' --key 'previous activity' 'none,none,Walk through activities (Reverse)'

# Configuring timeout to 90 minutes for activating the lock screen (conservative value in my opinion)
kwriteconfig5 --file kscreenlockerrc --group 'Daemon' --key 'Timeout' '90'

# Configuring lock screen wallpaper
kwriteconfig5 --file kscreenlockerrc --group 'Greeter' --group 'Wallpaper' --group 'org.kde.image' --group 'General' --key 'Image' '/usr/share/wallpapers/Next/'
kwriteconfig5 --file kscreenlockerrc --group 'Greeter' --group 'Wallpaper' --group 'org.kde.image' --group 'General' --key 'PreviewImage' '/usr/share/wallpapers/Next/'

# Configuring plasma to always start with a fresh session (aka not reopening the last sessions applications etc)
kwriteconfig5 --file ksmserverrc --group 'General' --key 'loginMode' 'emptySession'

# Configuring plasma to always enable NumLock at the start of a new session (should be default imo, who needs the other features of NumLock outside of games anyway??)
kwriteconfig5 --file kcminputrc --group 'Keyboard' --key 'NumLock' '0'

# Enabling visibility for virtual networks in the network configuration section in the system settings app
kwriteconfig5 --file plasma-nm --group 'General' --key 'ManageVirtualConnections' --type bool true

# Enable offline updates (updates after reboot)
# Kubuntu 26.04 will most likely implement dracut, which will fix the following 2 issues:
# 1. Due to the initramfs not being localised the plymouth display for "Installing updates" is shown only in English even on non English-systems: https://bugs.launchpad.net/ubuntu/+source/plymouth/+bug/2088413
# 2. Installing updates at reboot with offline-updates will require the user to enter the LUKS passwort manually, and as the system will be fully restarted after an update, the user will have to enter it 2 times. Dracut will make it possible to use automatic disk decryption by using the TPM chip with systemd's disk encryption module
kwriteconfig5 --file discoverrc --group 'Software' --key 'UseOfflineUpdates' --type bool true

# Implements a basic stock profile picture for the user account to overwrite the Kubuntu icon profile picture
busctl call org.freedesktop.Accounts /org/freedesktop/Accounts/User$(id -u) org.freedesktop.Accounts.User SetIconFile s "$(realpath "./resources/face.png")"

# Configures Dolphin to always start with a fresh session in users home dir
kwriteconfig5 --file dolphinrc --group 'General' --key 'RememberOpenedTabs' --type bool false

# Configure system monitor process page to show processes of all users
kwriteconfig5 --file "$HOME/.local/share/plasma-systemmonitor/processes.page" --group 'Face-94051759765872' --group 'org.kde.ksysguard.processtable' --group 'General' --key 'userFilterMode' '3'

# Copy the energy profile from this config to the users config dir (overwrites if necessary)
cp -v ./configs/powermanagementprofilesrc "$HOME/.config/powermanagementprofilesrc"
echo

# Create an Apps folder in users home dir (for AppImages and self contained installs, like /opt but on user level)
kwriteconfig5 --file "$HOME/Apps/.directory" --group 'Desktop Entry' --key 'Icon' 'folder-appimage'

# Create a start menu shortcut for systemmonitor (System Activity)
mkdir -pv "$HOME/.local/share/applications"
cp -v ./configs/systemmonitor.desktop "$HOME/.local/share/applications/systemmonitor.desktop"
echo

# Disable clipboard history remaining after closed sessions
kwriteconfig5 --file klipperrc --group 'General' --key 'KeepClipboardContents' --type bool false

# Disable kubuntu-notification-helper reboot notification after updates (redundant to discovers notification and also affected to a bug, which causes it to literally spam the notification like crazy)
kwriteconfig5 --file notificationhelper --group 'Event' --key 'hideRestartNotifier' --type bool true

# Configure qpwgraph to not use the system tray at all (and therefore quit the process if the window is closed)
# kwriteconfig5 really doesn't like many of the characters used in the qpwgraph config file. So this shouldn't be used on an existing config!
echo "The following mv command is just a safety mechanism to prevent kwriteconfig5 from editing an existing file with incompatible characters. If it errors it probably means there is no config file for qpwgraph yet, which is absolutely fine"
mv -v "$HOME/.var/app/org.rncbc.qpwgraph/config/rncbc.org/qpwgraph.conf" "$HOME/.var/app/org.rncbc.qpwgraph/config/rncbc.org/qpwgraph.conf.bak"-"$(date +\%Y\%m\%d)-$(date +\%H\%M\%S)"
kwriteconfig5 --file "$HOME/.var/app/org.rncbc.qpwgraph/config/rncbc.org/qpwgraph.conf" --group 'SystemTray' --key 'Enabled' --type bool false
echo

# Disable fcitx Keyboard Layout system tray icon (most users won't need this)
# The KCM systemsettings module uses dynamic IDs in the configuration file, therefore editing it automatically with kwriteconfig5 can't be reliable and the whole config file needs to be copied.
#kwriteconfig5 --file "$HOME.config/fcitx5/config" --group 'Behavior/DisabledAddons' --key '0' 'classicui'
mv -v "$HOME/.config/fcitx5/config" "$HOME/.config/fcitx5/config.bak"-"$(date +\%Y\%m\%d)-$(date +\%H\%M\%S)"
cp -v ./configs/fcitx5_config "$HOME/.config/fcitx5/config"
echo

# MIME type associations for default applications that open specified filetypes
# This should be run after software installations to make sure new software installs don't overwrite the MIME type associations again.
# Debian package files should always be opened with Discovery (as QApt is really buggy):
xdg-mime default org.kde.discover.desktop application/vnd.debian.binary-package
# XML and JSON should be opened with a text editor (and not a web browser):
xdg-mime default org.kde.kate.desktop application/json
xdg-mime default org.kde.kate.desktop application/xml
# Video files should all be opened with VLC media player (if possible, this contains only formats that are declared as compatible to VLC):
xdg-mime default vlc.desktop application/mxf
xdg-mime default vlc.desktop application/sdp
xdg-mime default vlc.desktop application/vnd.adobe.flash.movie
xdg-mime default vlc.desktop application/vnd.ms-asf
xdg-mime default vlc.desktop application/vnd.ms-wpl
xdg-mime default vlc.desktop application/vnd.rn-realmedia
xdg-mime default vlc.desktop application/x-matroska
xdg-mime default vlc.desktop application/x-netshow-channel
xdg-mime default vlc.desktop application/x-quicktime-media-link
xdg-mime default vlc.desktop text/x-google-video-pointer
xdg-mime default vlc.desktop video/3gpp
xdg-mime default vlc.desktop video/3gpp2
xdg-mime default vlc.desktop video/dv
xdg-mime default vlc.desktop video/mp2t
xdg-mime default vlc.desktop video/mp4
xdg-mime default vlc.desktop video/mpeg
xdg-mime default vlc.desktop video/ogg
xdg-mime default vlc.desktop video/quicktime
xdg-mime default vlc.desktop video/vnd.avi
xdg-mime default vlc.desktop video/vnd.mpegurl
xdg-mime default vlc.desktop video/vnd.rn-realvideo
xdg-mime default vlc.desktop video/webm
xdg-mime default vlc.desktop video/x-anim
xdg-mime default vlc.desktop video/x-flic
xdg-mime default vlc.desktop video/x-flv
xdg-mime default vlc.desktop video/x-javafx
xdg-mime default vlc.desktop video/x-matroska
xdg-mime default vlc.desktop video/x-matroska-3d
xdg-mime default vlc.desktop video/x-ms-wmp
xdg-mime default vlc.desktop video/x-ms-wmv
xdg-mime default vlc.desktop video/x-nsv
xdg-mime default vlc.desktop video/x-ogm+ogg
xdg-mime default vlc.desktop video/x-theora+ogg
xdg-mime default vlc.desktop x-content/video-dvd
xdg-mime default vlc.desktop x-content/video-svcd
xdg-mime default vlc.desktop x-content/video-vcd
# Audio files should all be opened with VLC media player (if possible, this contains only formats that are declared as compatible to VLC):
xdg-mime default vlc.desktop application/ogg
xdg-mime default vlc.desktop application/x-shorten
xdg-mime default vlc.desktop application/xspf+xml
xdg-mime default vlc.desktop audio/aac
xdg-mime default vlc.desktop audio/ac3
xdg-mime default vlc.desktop audio/basic
xdg-mime default vlc.desktop audio/flac
xdg-mime default vlc.desktop audio/midi
xdg-mime default vlc.desktop audio/mp2
xdg-mime default vlc.desktop audio/mp4
xdg-mime default vlc.desktop audio/mpeg
xdg-mime default vlc.desktop audio/ogg
xdg-mime default vlc.desktop audio/vnd.dts
xdg-mime default vlc.desktop audio/vnd.dts.hd
xdg-mime default vlc.desktop audio/vnd.rn-realaudio
xdg-mime default vlc.desktop audio/vnd.wave
xdg-mime default vlc.desktop audio/webm
xdg-mime default vlc.desktop audio/x-adpcm
xdg-mime default vlc.desktop audio/x-aiff
xdg-mime default vlc.desktop audio/x-ape
xdg-mime default vlc.desktop audio/x-flac+ogg
xdg-mime default vlc.desktop audio/x-gsm
xdg-mime default vlc.desktop audio/x-it
xdg-mime default vlc.desktop audio/x-m4b
xdg-mime default vlc.desktop audio/x-m4r
xdg-mime default vlc.desktop audio/x-matroska
xdg-mime default vlc.desktop audio/x-mod
xdg-mime default vlc.desktop audio/x-mpegurl
xdg-mime default vlc.desktop audio/x-ms-asx
xdg-mime default vlc.desktop audio/x-ms-wma
xdg-mime default vlc.desktop audio/x-musepack
xdg-mime default vlc.desktop audio/x-opus+ogg
xdg-mime default vlc.desktop audio/x-pn-realaudio-plugin
xdg-mime default vlc.desktop audio/x-s3m
xdg-mime default vlc.desktop audio/x-scpls
xdg-mime default vlc.desktop audio/x-speex
xdg-mime default vlc.desktop audio/x-speex+ogg
xdg-mime default vlc.desktop audio/x-vorbis+ogg
xdg-mime default vlc.desktop audio/x-wavpack
xdg-mime default vlc.desktop audio/x-xm
xdg-mime default vlc.desktop x-content/audio-cdda
xdg-mime default vlc.desktop x-content/audio-player
echo

# Make Chromium the default browser (I can already feel the salt of the Anti-Chrome folks :D)
xdg-mime default chromium_chromium.desktop x-scheme-handler/http
xdg-mime default chromium_chromium.desktop x-scheme-handler/https
xdg-settings set default-web-browser chromium_chromium.desktop
echo

# Make Thunderbird the default mail application
xdg-mime default thunderbird_thunderbird.desktop x-scheme-handler/mailto
xdg-mime default thunderbird_thunderbird.desktop x-scheme-handler/mid
echo

# Configure chromium to use GTK-theme of KDE Plasma and to merge the tab bar into the window bar
bash ./modules/configure_chromium.sh
echo

echo
echo "Reboot to apply all settings"
echo
