while ps -eo pid,comm,exe | grep chromium | grep '/snap/chromium/' > /dev/null; do
  echo "Running chromium processes have been detected. Please close all chromium processes so the script can proceed!"
  sleep 5
done
script_chromecurrentprofile="Default"
if [[ -f "$HOME/snap/chromium/common/chromium/Local State" ]]; then
  profile=$(jq -r '.profile.last_used // empty' "$HOME/snap/chromium/common/chromium/Local State")
  script_chromecurrentprofile="${profile:-Default}"
fi
mkdir -p "$HOME/snap/chromium/common/chromium/$script_chromecurrentprofile"
if [ ! -s "$HOME/snap/chromium/common/chromium/$script_chromecurrentprofile/Preferences" ]; then
  jq -n '.extensions.theme.system_theme = 1 | .browser.custom_chrome_frame = true' > "$HOME/snap/chromium/common/chromium/$script_chromecurrentprofile/Preferences"
else
  jq '.extensions.theme.system_theme = 1 | .browser.custom_chrome_frame = true' "$HOME/snap/chromium/common/chromium/$script_chromecurrentprofile/Preferences" > "/tmp/Chromium_Preferences.tmp" && mv "/tmp/Chromium_Preferences.tmp" "$HOME/snap/chromium/common/chromium/$script_chromecurrentprofile/Preferences"
fi
unset script_chromecurrentprofile
