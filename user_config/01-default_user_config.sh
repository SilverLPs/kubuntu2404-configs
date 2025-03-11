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

##GGF sollten auch die Groups in Anführungszeichen gesetzt werden, austesten ob das genauso funktioniert wie davor!
kwriteconfig5 --file ksplashrc --group KSplash --key Engine "none"
kwriteconfig5 --file ksplashrc --group KSplash --key Theme "none"
kwriteconfig5 --file klaunchrc --group FeedbackStyle --key "BusyCursor" --type bool false
kwriteconfig5 --file kwinrc --group Plugins --key "kwin4_effect_fadingpopupsEnabled" --type bool false
kwriteconfig5 --file kwinrc --group Plugins --key "kwin4_effect_morphingpopupsEnabled" --type bool false
kwriteconfig5 --file kwinrc --group Effect-windowview --key "BorderActivateAll" "9"
# WARNING Part of these values in kglobalshortcutsrc are in German, which could lead to problems when the systems/users language is different, it looks like most of them start in English even on a German system, and then the System settings app will change them on the fly to english as the user goes through the options, which would mean, that I could just set it to the english value with this script and on a different language system KDE will set it to the local language automatically without any problems
kwriteconfig5 --file kglobalshortcutsrc --group kwin --key Overview "Meta+W\tMeta+Tab,Meta+W,Übersicht umschalten"
sed -i '/Overview/s/\\\\t/\\t/g' "$HOME/.config/kglobalshortcutsrc"
kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "next activity" "none,Meta+Tab,Zwischen Aktivitäten wechseln"
kwriteconfig5 --file kscreenlockerrc --group Daemon --key "Timeout" "90"
kwriteconfig5 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key "Image" "/usr/share/wallpapers/Next/"
kwriteconfig5 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key "PreviewImage" "/usr/share/wallpapers/Next/"
kwriteconfig5 --file ksmserverrc --group General --key "loginMode" "emptySession"
kwriteconfig5 --file kcminputrc --group Keyboard --key "NumLock" "0"
kwriteconfig5 --file plasma-nm --group General --key "ManageVirtualConnections" --type bool true

busctl call org.freedesktop.Accounts /org/freedesktop/Accounts/User$(id -u) org.freedesktop.Accounts.User SetIconFile s "./ressources/face.png"

kwriteconfig5 --file dolphinrc --group General --key "RememberOpenedTabs" --type bool false

#copy das Energieprofil aus den Ressources in das configdir (überschreiben!!)
cp ./configs/powermanagementprofilesrc "$HOME/.config/powermanagementprofilesrc"

#WICHTIG: Das hier sollte eigentlich in das erste Systemskript verschoben werden, sofern es mit sudo richtig arbeitet...
busctl call com.ubuntu.WhoopsiePreferences /com/ubuntu/WhoopsiePreferences com.ubuntu.WhoopsiePreferences SetReportCrashes b false
busctl call com.ubuntu.WhoopsiePreferences /com/ubuntu/WhoopsiePreferences com.ubuntu.WhoopsiePreferences SetAutomaticallyReportCrashes b false
busctl call com.ubuntu.WhoopsiePreferences /com/ubuntu/WhoopsiePreferences com.ubuntu.WhoopsiePreferences SetReportMetrics b false
#Kann geprüft werden mit cat /etc/whoopsie (dort ist nur die Metrics Option) und systemctl status whoopsie.path (muss auf disabled stehen)

flatpak install --noninteractive flathub com.github.tchx84.Flatseal
flatpak install --noninteractive flathub org.localsend.localsend_app
flatpak install --noninteractive flathub org.rncbc.qpwgraph

mkdir "$HOME/Apps"
kwriteconfig5 --file "$HOME/Apps/.directory" --group 'Desktop Entry' --key 'Icon' 'folder-appimage'

#MIME type associations
#Sollte NACH der Installation von Software erledigt werden, um es zu vermeiden, dass neue Installationen die Defaults wieder überschreiben
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

#Das deaktiviert tatsächlich KWallet, allerdings führt das zu anderen Problemen, Anwendungen wie Vivaldi speichern dann nicht mehr richtig, ggf. ist abschalten doch nicht die beste Option... Vlt. lohnt es sich das Passwort leer zu machen, was effektiv wohl die Passwortabfragen deakiviert, auch bei Autologin. Ist natürlich unsicher, allerdings ist Leerzeichen als Userpassword dann auch das Passwort des Wallets und das ist auch nicht besser, nur nerviger bei Autologin. Vlt. gibt es eine Lösung die das Wallet Passwort bei Autologin immer mitentsperrt. Sonst lohnt es sich wohlmöglich gar nicht. Sonst sollte wohlmöglich Autologin einfach nicht verwendet werden, die Einstellungen warnen eh den Nutzer davor, dass es zu Problemen mit KWallet führt, oder eine Art Autounlock wie hier https://www.reddit.com/r/kde/comments/ybp191/how_to_auto_unlock_kwallet/?tl=de oder ich könnte austesten, immer eine Nachfrage auf den Zugriff zu machen, und den vlt. pro Programm immer zu erlauben, falls das geht siehe hier grünes Feld: https://wiki.archlinux.org/title/KDE_Wallet
#kwriteconfig5 --file kwalletrc --group Wallet --key "Enabled" --type bool false
#kwriteconfig5 --file kwalletrc --group org.freedesktop.secrets --key "apiEnabled" --type bool false
#busctl --user call org.kde.kwalletd5 /modules/kwalletd5 org.kde.KWallet reconfigure
