# Output can be too large for the konsole windows, copy STDERR and STDOUT into a textfile by using this command:
# sudo bash ./01-default_user_config.sh |& tee "$HOME/01-default_user_config.log"

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

busctl call org.freedesktop.Accounts /org/freedesktop/Accounts/User$(id -u) org.freedesktop.Accounts.User SetIconFile s "./ressources/face.png"

#WICHTIG: Das hier sollte eigentlich in das erste Systemskript verschoben werden, sofern es mit sudo richtig arbeitet...
busctl call com.ubuntu.WhoopsiePreferences /com/ubuntu/WhoopsiePreferences com.ubuntu.WhoopsiePreferences SetReportCrashes b false
busctl call com.ubuntu.WhoopsiePreferences /com/ubuntu/WhoopsiePreferences com.ubuntu.WhoopsiePreferences SetAutomaticallyReportCrashes b false
busctl call com.ubuntu.WhoopsiePreferences /com/ubuntu/WhoopsiePreferences com.ubuntu.WhoopsiePreferences SetReportMetrics b false
#Kann geprüft werden mit cat /etc/whoopsie (dort ist nur die Metrics Option) und systemctl status whoopsie.path (muss auf disabled stehen)

kwriteconfig5 --file kwalletrc --group Wallet --key "Enabled" --type bool false
kwriteconfig5 --file kwalletrc --group org.freedesktop.secrets --key "apiEnabled" --type bool false
busctl --user call org.kde.kwalletd5 /modules/kwalletd5 org.kde.KWallet reconfigure

#Dateiformate wie xml und json nicht mit Firefox, sondern mit Kate öffnen
#Multimediaformate an VLC schicken

#Profilbild von Kubuntu auf leeres Nutzersymbol auswählen (Hintergrund so auswählen, dass es sowohl mit dem Anmeldebildschirm als auch dem Startmenü passt
