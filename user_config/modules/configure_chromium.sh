while ps -eo pid,comm,exe | grep chrome | grep '/opt/google/chrome/' > /dev/null; do
  echo "Running chrome processes have been detected. Please close all chrome processes so the script can proceed!"
  sleep 5
done
script_chromecurrentprofile="Default"
#if [[ -f "$HOME/snap/chromium/common/chromium/Local State" ]]; then
#  profile=$(jq -r '.profile.last_used // empty' "$HOME/snap/chromium/common/chromium/Local State")
#  script_chromecurrentprofile="${profile:-Default}"
#fi
mkdir -p "$HOME/.config/google-chrome/$script_chromecurrentprofile"
if [ ! -s "$HOME/.config/google-chrome/$script_chromecurrentprofile/Preferences" ]; then
  jq -n '.extensions.theme.system_theme = 1 | .browser.custom_chrome_frame = true' > "$HOME/.config/google-chrome/$script_chromecurrentprofile/Preferences"
else
  jq '.extensions.theme.system_theme = 1 | .browser.custom_chrome_frame = true' "$HOME/.config/google-chrome/$script_chromecurrentprofile/Preferences" > "/tmp/Chromium_Preferences.tmp" && mv "/tmp/Chromium_Preferences.tmp" "$HOME/.config/google-chrome/$script_chromecurrentprofile/Preferences"
fi
unset script_chromecurrentprofile
