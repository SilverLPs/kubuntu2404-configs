#!/bin/bash

# Check if user script is run as non-root user and exit if not
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: This script is not supposed to be run as root but as a normal user"
    exit 1
fi

# Declare arguments that can be passed when starting this script
declare -A valid_args
valid_args_order=()

add_valid_arg() {
  key="$1"
  valid_args["$key"]=0
  valid_args_order+=("$key")
}

add_valid_arg "--autoreboot"
add_valid_arg "--system"
add_valid_arg "--user"
add_valid_arg "--realtime"
add_valid_arg "--lighttheme"
add_valid_arg "--lighttheme-darkplasma"
add_valid_arg "--studio"
add_valid_arg "--tuxedo"
add_valid_arg "--focusrite_scarlett"

# If started without arguments show GUI window to choose options
if [[ $# -eq 0 ]]; then
  if ! command -v kdialog &> /dev/null; then
    echo "ERROR: kdialog seems to be not installed. You can run this script with command-line arguments instead."
    exit 1
  fi

  checklist_items=()
  for key in "${valid_args_order[@]}"; do
    label="${key#--}"
    checklist_items+=("$label" "$label" "off")
  done

  selected=$(kdialog --separate-output --checklist "Which parts of the script do you want to run? (Multiple choices are possible)" \
    "${checklist_items[@]}")

  if [[ $? -ne 0 ]]; then
    echo "Cancelled"
    exit 1
  fi

  if [[ -z "$selected" ]]; then
    echo "Cancelled (nothing chosen)"
    exit 1
  fi

  args_to_set=()
  while read -r label; do
    arg="--$label"
    args_to_set+=("$arg")
  done <<< "$selected"

  # Restart script with chosen arguments
  export script_gui_mode=1
  exec "$0" "${args_to_set[@]}"
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

# Process arguments that have been passed when starting this script
for arg in "$@"; do
  if [[ -v valid_args["$arg"] ]]; then
    valid_args["$arg"]=1
  else
    echo "ERROR: Invalid argument '$arg'"
    exit 1
  fi
done

# System configuration (scripts that will run with sudo)
# These commands are passed and run as a single block in a single sudo command to avoid multiple password prompts
sudo_commands=""
[[ ${valid_args["--system"]} -eq 1 ]] && sudo_commands+="bash ./system_config/01-default_system_config.sh"$'\n'
[[ ${valid_args["--realtime"]} -eq 1 ]] && sudo_commands+="bash ./system_config/02-default_system_config_user_realtime_permissions.sh"$'\n'
[[ ${valid_args["--studio"]} -eq 1 ]] && sudo_commands+="bash ./system_config/10-studio.sh"$'\n'
[[ ${valid_args["--focusrite_scarlett"]} -eq 1 ]] && sudo_commands+="bash ./system_config/21-focusrite_scarlett.sh"$'\n'

if [[ -n "$sudo_commands" ]]; then
  if [ "$script_gui_mode" = "1" ]; then
    SUDO_ASKPASS="$(command -v ssh-askpass)" sudo -A -s <<HERE
$sudo_commands
HERE
  else
    sudo -s <<HERE
$sudo_commands
HERE
  fi
fi

# User configuration (scripts that will run without sudo)
if [[ ${valid_args["--user"]} -eq 1 ]]; then
  bash ./user_config/01-default_user_config.sh
fi

if [[ ${valid_args["--lighttheme"]} -eq 1 ]]; then
  bash ./user_config/02-default_user_config_theme_light.sh
fi

if [[ ${valid_args["--lighttheme-darkplasma"]} -eq 1 ]]; then
  bash ./user_config/02-default_user_config_theme_lightlite.sh
fi

if [ "$script_gui_mode" = "1" ]; then
  notify-send -u critical -a "kubuntu2404-config" -i utilities-terminal "Script finished" "The PC could need a restart to apply all settings!"
fi
unset script_gui_mode

# Automatically reboot the system after 10 seconds
if [[ ${valid_args["--autoreboot"]} -eq 1 ]]; then
    for i in {10..1}
    do
        echo "The system will reboot in $i..."
        sleep 1
    done
    echo "Restart via KDE session"
    busctl --user call org.kde.Shutdown /Shutdown org.kde.Shutdown logoutAndReboot
fi
