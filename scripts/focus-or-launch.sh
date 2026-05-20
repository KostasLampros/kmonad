WINDOW_NAME="$1"
shift
LAUNCH_CMD=("$@")

mapfile -t results < <(kdotool search --class "$WINDOW_NAME" 2>/dev/null)

if [[ ${#results[@]} -eq 0 ]]; then
  "${LAUNCH_CMD[@]}" &
else
  current=$(kdotool getactivewindow 2>/dev/null)

  # Find the index of the current window in the list
  current_index=-1
  for i in "${!results[@]}"; do
    if [[ "${results[$i]}" == "$current" ]]; then
      current_index=$i
      break
    fi
  done

  # Pick the next window, wrapping around to 0 after the last
  next_index=$(((current_index + 1) % ${#results[@]}))
  kdotool windowactivate "${results[$next_index]}"
fi
