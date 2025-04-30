# Check if user script is run as root user in sudo context and exit if not
if [ -z "${SUDO_USER}" ]; then
    echo "ERROR: This script needs to be started in sudo context, opened by the main normal user account of this computer, it can't be run just as root or a normal user!"
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

echo "Starting studio configuration"
echo

# Install studio software from Ubuntu repos
apt-get update
apt-get install -q -y rt-tests raysession
echo

# Install studio software from Flathub
flatpak install --noninteractive flathub io.github.dimtpap.coppwr
echo
