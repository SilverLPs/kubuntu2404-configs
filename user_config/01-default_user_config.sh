# Output can be too large for the konsole windows, copy STDERR and STDOUT into a textfile by using this command:
# bash ./01-default_user_config.sh |& tee "$HOME/01-default_user_config.log"

if [ "$(id -u)" -eq 0 ]; then
    echo "This script is not supposed to be run as root but as a normal user"
    exit 1
fi

echo "Starting default user configuration"
echo

#Hier muss das Theme noch ins User Dir für Plasma/Lookandfeel verschoben werden
plasma-apply-lookandfeel -a silverlps.breezedarkcustom.desktop --resetLayout

# kwriteconfig5 is fully idempotent and automatically creates config files and even folders if necessary, which makes mkdir or touch commands obsolete
kwriteconfig5 --file ksplashrc --group 'KSplash' --key 'Engine' 'none'
kwriteconfig5 --file ksplashrc --group 'KSplash' --key 'Theme' 'none'
kwriteconfig5 --file klaunchrc --group 'FeedbackStyle' --key 'BusyCursor' --type bool false
kwriteconfig5 --file kwinrc --group 'Plugins' --key 'kwin4_effect_fadingpopupsEnabled' --type bool false
kwriteconfig5 --file kwinrc --group 'Plugins' --key 'kwin4_effect_morphingpopupsEnabled' --type bool false
kwriteconfig5 --file kwinrc --group 'Effect-windowview' --key 'BorderActivateAll' '9'
# WARNING Part of these values in kglobalshortcutsrc are in German, which could lead to problems when the systems/users language is different, it looks like most of them start in English even on a German system, and then the System settings app will change them on the fly to english as the user goes through the options, which would mean, that I could just set it to the english value with this script and on a different language system KDE will set it to the local language automatically without any problems
kwriteconfig5 --file kglobalshortcutsrc --group 'kwin' --key 'Overview' 'Meta+W\tMeta+Tab,Meta+W,Übersicht umschalten'
#Geändert auf einfache Anführungszeichen, prüfen ob \t nach sed korrekt entfernt und alles richtig ist!
sed -i '/Overview/s/\\\\t/\\t/g' "$HOME/.config/kglobalshortcutsrc"
kwriteconfig5 --file kglobalshortcutsrc --group 'plasmashell' --key 'next activity' 'none,Meta+Tab,Zwischen Aktivitäten wechseln'
kwriteconfig5 --file kscreenlockerrc --group 'Daemon' --key 'Timeout' '90'
kwriteconfig5 --file kscreenlockerrc --group 'Greeter' --group 'Wallpaper' --group 'org.kde.image' --group 'General' --key 'Image' '/usr/share/wallpapers/Next/'
kwriteconfig5 --file kscreenlockerrc --group 'Greeter' --group 'Wallpaper' --group 'org.kde.image' --group 'General' --key 'PreviewImage' '/usr/share/wallpapers/Next/'
kwriteconfig5 --file ksmserverrc --group 'General' --key 'loginMode' 'emptySession'
kwriteconfig5 --file kcminputrc --group 'Keyboard' --key 'NumLock' '0'
kwriteconfig5 --file plasma-nm --group 'General' --key 'ManageVirtualConnections' --type bool true

# Implements a basic stock profile picture for the user account to overwrite the Kubuntu icon profile picture
busctl call org.freedesktop.Accounts /org/freedesktop/Accounts/User$(id -u) org.freedesktop.Accounts.User SetIconFile s "./ressources/face.png"

# Configures Dolphin to always start with a fresh session in users home dir
kwriteconfig5 --file dolphinrc --group 'General' --key 'RememberOpenedTabs' --type bool false

# Configure system monitor process page to show processes of all users
kwriteconfig5 --file "$HOME/.local/share/plasma-systemmonitor/processes.page" --group 'Face-94051759765872' --group 'org.kde.ksysguard.processtable' --group 'General' --key 'userFilterMode' '3'

# Copy the energy profile from this config to the users config dir (overwrites if necessary)
cp ./configs/powermanagementprofilesrc "$HOME/.config/powermanagementprofilesrc"

# Create an Apps folder in users home dir (for AppImages and self contained installs, like /opt but on user level)
kwriteconfig5 --file "$HOME/Apps/.directory" --group 'Desktop Entry' --key 'Icon' 'folder-appimage'

#WICHTIG: Das hier sollte eigentlich in das erste Systemskript verschoben werden, sofern es mit sudo richtig arbeitet...
busctl call com.ubuntu.WhoopsiePreferences /com/ubuntu/WhoopsiePreferences com.ubuntu.WhoopsiePreferences SetReportCrashes b false
busctl call com.ubuntu.WhoopsiePreferences /com/ubuntu/WhoopsiePreferences com.ubuntu.WhoopsiePreferences SetAutomaticallyReportCrashes b false
busctl call com.ubuntu.WhoopsiePreferences /com/ubuntu/WhoopsiePreferences com.ubuntu.WhoopsiePreferences SetReportMetrics b false
#Kann geprüft werden mit cat /etc/whoopsie (dort ist nur die Metrics Option) und systemctl status whoopsie.path (muss auf disabled stehen)

# Install basic system tool flatpaks
flatpak install --noninteractive flathub com.github.tchx84.Flatseal
flatpak install --noninteractive flathub org.localsend.localsend_app
flatpak install --noninteractive flathub org.rncbc.qpwgraph

# Configure qpwgraph to not use the system tray at all (and therefore quit the process if the window is closed)
# kwriteconfig5 really doesn't like many of the characters used in the qpwgraph config file. So this shouldn't be used on an existing config!
echo "The following mv command is just a safety mechanism to prevent kwriteconfig5 from editing an existing file with incompatible characters. If it errors it probably means there is no config file for qpwgraph yet, which is absolutely fine"
mv "$HOME/.var/app/org.rncbc.qpwgraph/config/rncbc.org/qpwgraph.conf" "$HOME/.var/app/org.rncbc.qpwgraph/config/rncbc.org/qpwgraph.conf.bak"-"$(date +\%Y\%m\%d)-$(date +\%H\%M\%S)"
kwriteconfig5 --file "$HOME/.var/app/org.rncbc.qpwgraph/config/rncbc.org/qpwgraph.conf" --group 'SystemTray' --key 'Enabled' --type bool false

# MIME type associations
# This should be run after software installations to make sure new software installs don't overwrite the MIME type associations again.
xdg-mime default org.kde.discover.desktop application/vnd.debian.binary-package

xdg-mime default org.kde.kate.desktop application/json
xdg-mime default org.kde.kate.desktop application/xml

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

# KWallet shouldn't be disabled because that can lead to severe problems with various applications (i.e. Vivaldi). If autologin is activated, the password of KWallet can be changed to just an empty string, this will disable the password prompts and KWallet will still work (but without any encryption, meaning the passwords are clear and unprotected on disk!).
# If disabling KWallet is still desired, the following commands can be used to achieve that goal on the users own risk!
#kwriteconfig5 --file kwalletrc --group Wallet --key "Enabled" --type bool false
#kwriteconfig5 --file kwalletrc --group org.freedesktop.secrets --key "apiEnabled" --type bool false
#busctl --user call org.kde.kwalletd5 /modules/kwalletd5 org.kde.KWallet reconfigure
