#!/bin/bash

GRUB_FILE="/etc/default/grub"
KEY="GRUB_RECORDFAIL_TIMEOUT"
ADD_VALUE="0"

cp "$GRUB_FILE" "$GRUB_FILE.bak-$(date +%Y%m%d-%H%M%S)"

if grep -q "^$KEY=" "$GRUB_FILE"; then
    sed -i -E "s|^$KEY=.*|$KEY=$ADD_VALUE|" "$GRUB_FILE"
    echo "$KEY was set to $ADD_VALUE (overwritten)."
else
    echo "$KEY=$ADD_VALUE" >> "$GRUB_FILE"
    echo "$KEY was added with value $ADD_VALUE."
fi

