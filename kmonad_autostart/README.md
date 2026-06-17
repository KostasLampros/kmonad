# KMonad Auto-Keyboard Setup

## Files

| File | Destination |
|------|-------------|
| `kmonad-autostart.sh` | `~/.config/kmonad/kmonad-autostart.sh` |
| `kmonad.service` | `~/.config/systemd/user/kmonad.service` |

---

## Step 1 — Find your keyboard IDs

Plug in each keyboard and run:

```bash
ls /dev/input/by-id/
```

Then unplug it and run again — the entry that disappears is your keyboard.
Do this for both external keyboards and note the names.

For the built-in keyboard, it's usually always present:

```bash
ls /dev/input/by-id/ | grep -iE "AT|isa|i8042"
# or browse:
cat /proc/bus/input/devices | grep -A5 "keyboard"
```

---

## Step 2 — Edit the script

Open `kmonad-autostart.sh` and fill in the three variables at the top:

```bash
KEYBOARD_HOME="/dev/input/by-id/usb-Vendor_HomeKeyboard_Name-event-kbd"
KEYBOARD_WORK="/dev/input/by-id/usb-Vendor_WorkKeyboard_Name-event-kbd"
KEYBOARD_BUILTIN="/dev/input/by-id/isa0060-serio0-event-kbd"
```

Also set the path to your base config:

```bash
BASE_CONFIG="$HOME/.config/kmonad/config.kbd"
```

---

## Step 3 — Check your config's device line

The script patches the `device` line inside your `defcfg` block.
Make sure yours looks like one of these (both are handled):

```
(defcfg
  input  (device-file "/dev/input/by-id/anything-here")
  ...
)
```

---

## Step 4 — Install

```bash
# Copy files
mkdir -p ~/.config/kmonad
cp kmonad-autostart.sh ~/.config/kmonad/
chmod +x ~/.config/kmonad/kmonad-autostart.sh

mkdir -p ~/.config/systemd/user
cp kmonad.service ~/.config/systemd/user/

# Enable the service
systemctl --user daemon-reload
systemctl --user enable --now kmonad.service
```

---

## Useful commands

```bash
# Check status
systemctl --user status kmonad

# View live logs
journalctl --user -u kmonad -f

# Restart manually (e.g. after swapping keyboard)
systemctl --user restart kmonad

# Stop
systemctl --user stop kmonad
```

---

## Notes

- The service uses a **2-second pre-sleep** to let udev settle before detection.
  If your external keyboard is still not detected on boot, bump `ExecStartPre=/bin/sleep 2`
  to `3` or `4` in the service file, then re-run `systemctl --user daemon-reload`.
- The patched config is written to `/tmp/kmonad-runtime.kbd` — your original is never modified.
- The detection order is: **Home keyboard → Work keyboard → Built-in**. Change the order
  in `kmonad-autostart.sh`'s `detect_keyboard()` function if needed.
