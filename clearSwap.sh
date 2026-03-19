# /usr/local/bin/clearSwap.sh 
# make it executable (chmod +x /usr/local/bin/clearSwap.sh).
#!/bin/bash

# Define config file path
CONFIG_FILE="/etc/clearSwap.conf"

# Default values (fallback if config is missing)
SWAP_THRESHOLD=80
CHECK_INTERVAL=60

# Load configuration if the file exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

echo "clearSwap initialized. Threshold: ${SWAP_THRESHOLD}%, Interval: ${CHECK_INTERVAL}s"

while true; do
    # Extract Memory and Swap values in Megabytes
    MEM_AVAILABLE=$(free -m | awk '/^Mem:/ {print $7}')
    SWAP_TOTAL=$(free -m | awk '/^Swap:/ {print $2}')
    SWAP_USED=$(free -m | awk '/^Swap:/ {print $3}')

    # Only proceed if Swap is actually configured
    if [ "$SWAP_TOTAL" -gt 0 ]; then
        # Calculate swap usage percentage
        SWAP_PCT=$(( (SWAP_USED * 100) / SWAP_TOTAL ))

        if [ "$SWAP_PCT" -ge "$SWAP_THRESHOLD" ]; then
            # SAFETY CHECK: Is Available RAM > Used Swap + 100MB buffer?
            SAFE_LIMIT=$(( MEM_AVAILABLE - 100 ))

            if [ "$SAFE_LIMIT" -gt "$SWAP_USED" ]; then
                echo "$(date): Swap at ${SWAP_PCT}%. Sufficient RAM available (${MEM_AVAILABLE}MB > ${SWAP_USED}MB). Cycling swap..."
                swapoff -a && swapon -a
                echo "$(date): Swap refreshed successfully."
            else
                echo "$(date): WARNING. Swap at ${SWAP_PCT}%, but insufficient RAM to safely cycle (${MEM_AVAILABLE}MB available, need ${SWAP_USED}MB). Skipping."
            fi
        fi
    fi
    
    # Wait before checking again
    sleep "$CHECK_INTERVAL"
done