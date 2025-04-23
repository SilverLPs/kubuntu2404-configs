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

echo "Starting default user configuration (apply light theme with dark core elements)"
echo

plasma-apply-desktoptheme breeze-dark
echo
