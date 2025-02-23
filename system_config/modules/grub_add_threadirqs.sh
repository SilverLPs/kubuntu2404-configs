GRUB_FILE="/etc/default/grub"
KEY="GRUB_CMDLINE_LINUX_DEFAULT"
ADD_VALUE="threadirqs"

CURRENT_VALUE=$(grep "^$KEY=" "$GRUB_FILE" | sed -E "s/^$KEY=['\"](.*)['\"]/\1/")

if [[ ! " $CURRENT_VALUE " =~ " $ADD_VALUE " ]]; then
    if [[ -n "$CURRENT_VALUE" ]]; then
        NEW_VALUE="$(echo "$CURRENT_VALUE" | sed -E 's/[[:space:]]+$//') $ADD_VALUE"
    else
        NEW_VALUE="$ADD_VALUE"
    fi
else
    echo "$ADD_VALUE already exists in GRUB config"
    exit 0
fi

cp "$GRUB_FILE" "$GRUB_FILE.bak-$(date +\%Y\%m\%d)-$(date +\%H\%M\%S)"

sed -i -E "s|^$KEY=['\"].*['\"]|$KEY=\"${NEW_VALUE}\"|" "$GRUB_FILE"

echo "$ADD_VALUE has been added to GRUB config"
