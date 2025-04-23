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

echo "Starting default system configuration (default user realtime permissions)"
echo

# Add default user to pipewire group to enable enhanced access to system ressources (better for low latency tasks)
usermod -a -G pipewire "${SUDO_USER}"
echo
