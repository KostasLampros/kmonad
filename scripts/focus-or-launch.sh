WINDOW_NAME="$1"
shift
LAUNCH_CMD=("$@")

name_result=$(kdotool search --name "$WINDOW_NAME" | head -1 2>/dev/null)
echo "$name_result"

if [[ -n $name_result ]]; then
  # echo "window found"
  kdotool windowactivate "$name_result"
else
  # echo "no window - launching new"
  "${LAUNCH_CMD[@]}" &
fi
