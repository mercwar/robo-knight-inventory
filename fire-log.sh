#!/bin/bash
# /*******************************************************************************
#  * NAME: fire-log.sh
#  * ROLE: Shell-based multi-file logging for fire-log.asm integration
#  * GOAL: Sync portal logs and beacon while capturing internal errors
#  *******************************************************************************/

LOG_FILE="fire-portal.log"
CONFIG="cjs/fire-log.json"

# Function to write log with timestamp
log_pulse() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 1. Primary Portal Log
    echo "[$timestamp] $message" >> "$LOG_FILE"
    
    # 2. Synchronize to Beacon and Geo Audit (Multi-file Support)
    if [ -f "$CONFIG" ]; then
        # Extract target paths using jq and loop through them
        paths=$(jq -r '.AVIS_LOG_CONFIG.SYNC_TARGETS[].PATH' "$CONFIG")
        for path in $paths; do
            if [ "$path" != "$LOG_FILE" ]; then
                echo "[$timestamp] $message" >> "$path"
            fi
        done
    else
        # If config is missing, log the error to the main file
        echo "[$timestamp] ERROR: $CONFIG not found. Multi-file sync skipped." >> "$LOG_FILE"
    fi
}

# --- MAIN EXECUTION ---
# Catch script errors and log them
trap 'log_pulse "CRITICAL ERROR: fire-log.sh execution failed at line $LINENO"' ERR

# If called with an argument, log that message; otherwise, log a standard pulse
if [ -z "$1" ]; then
    log_pulse "PULSE: fire-log.sh executed successfully."
else
    log_pulse "DISPATCH: $1"
fi
