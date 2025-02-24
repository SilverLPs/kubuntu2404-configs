# Output can be too large for the konsole windows, copy STDERR and STDOUT into a textfile by using this command:
# sudo bash ./01-default_user_config.sh |& tee "$HOME/01-default_user_config.log"

plasma-apply-lookandfeel -a silverlps.breezedarkcustom.desktop --resetLayout

kwriteconfig5 --file ksplashrc --group KSplash --key Engine "none"
kwriteconfig5 --file ksplashrc --group KSplash --key Theme "none"
kwriteconfig5 --file klaunchrc --group FeedbackStyle --key "BusyCursor" --type bool false
kwriteconfig5 --file kwinrc --group Plugins --key "kwin4_effect_fadingpopupsEnabled" --type bool false
kwriteconfig5 --file kwinrc --group Plugins --key "kwin4_effect_morphingpopupsEnabled" --type bool false
# WARNING Part of these values are in German, which could lead to problems when the systems/users language is different
kwriteconfig5 --file kglobalshortcutsrc --group kwin --key Overview "Meta+W\tMeta+Tab,Meta+W,Übersicht umschalten"
sed -i '/Overview/s/\\\\t/\\t/g' "$HOME/.config/kglobalshortcutsrc"
kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "next activity" "none,Meta+Tab,Zwischen Aktivitäten wechseln"



#Dateiformate wie xml und json nicht mit Firefox, sondern mit Kate öffnen
#Multimediaformate an VLC schicken

#Profilbild von Kubuntu auf leeres Nutzersymbol auswählen (Hintergrund so auswählen, dass es sowohl mit dem Anmeldebildschirm als auch dem Startmenü passt
