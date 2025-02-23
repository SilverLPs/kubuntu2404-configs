FSTAB_FILE="/etc/fstab"

if grep -Pq '^(?!#)(?:\S+\s+){3}\S*\bdiscard\b' "$FSTAB_FILE"; then
    echo "WARNING: Found the option discard in fstab. This can damage the SSD in the long run due to double trimming SSD-devices!"
    echo "Affected lines:"
    grep -E '^[^#].*\bdiscard\b' "$FSTAB_FILE"
    TEMP_FILE="$(mktemp)"
    TIMESTAMP="$(date +\%Y\%m\%d)-$(date +\%H\%M\%S)"
    cp "$FSTAB_FILE" "$FSTAB_FILE.bak-$TIMESTAMP"
    mawk '
    {
        line = $0;
        if ($1 ~ /^#/ || NF < 4) {
            print line;
            next;
        }
        n = split($4, options, ",");
        new_options = "";
        for (i = 1; i <= n; i++) {
            if (options[i] != "discard") {
                if (new_options == "")
                    new_options = options[i];
                else
                    new_options = new_options "," options[i];
            }
        }
        if (new_options == "")
            new_options = "defaults";
        sub($4, new_options, line);
        print line;
    }' "$FSTAB_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$FSTAB_FILE"
    echo "Tried to remove 'discard' from fstab. A backup was saved as $FSTAB_FILE.bak-$TIMESTAMP."
    if grep -Pq '^(?!#)(?:\S+\s+){3}\S*\bdiscard\b' "$FSTAB_FILE"; then
        echo "ERROR: The option discard still seems to be in fstab. This means that the script did not run properly. The backup of the fstab will be restored now! Please check the fstab file for potential damage and remove the discard option manually."
        echo "Affected lines:"
        grep -E '^[^#].*\bdiscard\b' "$FSTAB_FILE"
        cp "$FSTAB_FILE.bak-$TIMESTAMP" "$FSTAB_FILE"
        chmod 644 "$FSTAB_FILE"
    else
        echo "As expected no 'discard' options were found in fstab anymore."
        chmod 644 "$FSTAB_FILE"
        cat "$FSTAB_FILE"
    fi
else
    echo "As expected no 'discard' options were found in fstab."
fi
