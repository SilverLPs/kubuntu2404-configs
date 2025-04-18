#!/bin/bash

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

# Declare arguments that can be passed when starting this script
declare -A valid_args=(
  ["--autoreboot"]=0
  ["--system"]=0
  ["--user"]=0
  ["--realtime"]=0
  ["--lighttheme"]=0
  ["--lighttheme-darkplasma"]=0
  ["--tuxedo"]=0
)

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

if [[ -n "$sudo_commands" ]]; then
  sudo -s <<HERE
$sudo_commands
HERE
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
