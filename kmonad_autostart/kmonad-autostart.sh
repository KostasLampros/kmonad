#!/usr/bin/env bash
# kmonad-autostart.sh
# Detects which keyboard is connected and launches KMonad with the right config.

set -euo pipefail

# ─── CONFIGURATION ────────────────────────────────────────────────────────────

# Your two external keyboards — fill in the exact by-id names.
# Run: ls /dev/input/by-id/ to find them.
KEYBOARD_HOME="/dev/input/by-id/usb-ROYUAN_2.4G_Wireless_Keyboard-event-kbd"
KEYBOARD_WORK="/dev/input/by-path/pci-0000:00:14.0-usb-0:6.3.1:1.0-event-kbd"

# Fallback: integrated/built-in keyboard by-id path.
# Run: ls /dev/input/by-id/ | grep -i "AT\|integrated\|isa"
# or check: cat /proc/bus/input/devices
KEYBOARD_BUILTIN="/dev/input/by-path/platform-i8042-serio-0-event-kbd"

# Your base KMonad config file (input device line will be rewritten).
BASE_CONFIG="$HOME/.config/kmonad/config.kbd"

# Where the patched (runtime) config is written.
RUNTIME_CONFIG="/tmp/kmonad-runtime.kbd"

# KMonad binary path.
KMONAD_BIN="$(command -v kmonad || echo /usr/bin/kmonad)"

# ─── DETECTION ────────────────────────────────────────────────────────────────

detect_keyboard() {
  if [[ -e "$KEYBOARD_HOME" ]]; then
    echo "$KEYBOARD_HOME"
    return
  fi

  if [[ -e "$KEYBOARD_WORK" ]]; then
    echo "$KEYBOARD_WORK"
    return
  fi

  if [[ -e "$KEYBOARD_BUILTIN" ]]; then
    echo "$KEYBOARD_BUILTIN"
    return
  fi

  echo ""
}

# ─── CONFIG PATCHING ──────────────────────────────────────────────────────────

patch_config() {
  local device="$1"

  if [[ ! -f "$BASE_CONFIG" ]]; then
    echo "ERROR: Base config not found at $BASE_CONFIG" >&2
    exit 1
  fi

  # Replaces the 'device' line inside the defcfg block.
  # Handles both quoted and unquoted paths, with optional spaces around the value.
  sed -E "s|(device\-file[[:space:]]+)[^)]*|\1\"$device\"|g" "$BASE_CONFIG" >"$RUNTIME_CONFIG"

  echo "Patched config written to $RUNTIME_CONFIG (device: $device)"
}

# ─── MAIN ─────────────────────────────────────────────────────────────────────

main() {
  echo "=== KMonad autostart $(date) ==="

  local device
  device="$(detect_keyboard)"

  if [[ -z "$device" ]]; then
    echo "ERROR: No known keyboard found and no built-in fallback detected." >&2
    echo "Checked:" >&2
    echo "  HOME:    $KEYBOARD_HOME" >&2
    echo "  WORK:    $KEYBOARD_WORK" >&2
    echo "  BUILTIN: $KEYBOARD_BUILTIN" >&2
    exit 1
  fi

  echo "Using keyboard: $device"
  patch_config "$device"

  echo "Starting KMonad..."
  exec "$KMONAD_BIN" "$RUNTIME_CONFIG"
}

main "$@"
