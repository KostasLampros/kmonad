#!/bin/bash
# ~/.local/bin/focus-or-launch.sh
# Usage: focus-or-launch.sh <window-name> <launch-command>

WINDOW_NAME="$1"
LAUNCH_CMD="$2"

if kdotool search --name $WINDOW_NAME >/dev/null 2>&1; then
  kdotool search --name $WINDOW_NAME windowactivate
else
  $LAUNCH_CMD &
fi
