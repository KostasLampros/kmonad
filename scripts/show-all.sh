mapfile -t results < <(kdotool search --name "$WINDOW_NAME" 2>/dev/null)

if [[ ${#results[@]} -eq 0 ]]; then
  echo "No windows currently open"
else
  for i in "${!results[@]}"; do
    echo "${results[$i]}"
    window="${results[$i]}"
    echo "$(kdotool getwindowclassname $window)"
  done
fi
