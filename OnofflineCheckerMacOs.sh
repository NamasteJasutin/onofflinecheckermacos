#!/bin/bash

# Initiate path var to script location
MY_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
MY_PATH="$(cd -- "$MY_PATH" && pwd)"    # absolutized and normalized

# Initialize a variable to keep track of the previous status
prev_status="offline"

while true; do
    # Ping 1.1.1.1 once to check connectivity -W(aittime) 500ms to speed up offline detection
    ping -W 500 -c 1 1.1.1.1 > /dev/null

    # Check the return status of the ping command
    # This will set the state. If the state is the same as the previous state, it will not send a notification.
    if [[ $? -eq 0 ]]; then
        current_status="online"
    else
        current_status="offline"
    fi

    # If there is a change in status, send a macOS notification via dialog
    if [[ $current_status != $prev_status ]]; then
        ACCEPT=$(osascript -e "display dialog (((current date) as string) & \"\nYou are now $current_status\") with title \"Network Status Changed\" with icon file POSIX file \"$MY_PATH/$current_status.icns\"")
        # If the user pressed cancel, the dialog will return until acknowledged. Press OK to overwrite the status until the next status change.
        if [[ $ACCEPT == "button returned:OK" ]]; then
            prev_status=$current_status
        fi
    fi
    # Sleep for 5 seconds before the next iteration
    sleep 5
done
