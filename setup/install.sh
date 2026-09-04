#!/usr/bin/env bash
#
# One-time setup for the Bongo Cat Omarchy widget.
#
# Makes the keyboard input devices readable by your user so the widget's
# key_monitor.py can read keypresses — without you having to remember the
# `usermod -aG input` + re-login dance yourself.
#
# What this does (all privileged, so it needs your sudo password / fingerprint):
#   1. Adds your user to the `input` group (kernel input devices).
#   2. Installs a udev rule that ensures keyboard event devices are owned by the
#      `input` group, readable by its members.
#   3. Reloads udev rules and re-applies them to existing devices, so the change
#      takes effect immediately for users already in the group.
#
# Usage:
#   sudo ./setup/install.sh
#
# Notes:
#   - A fresh shell (or a re-login) is still needed for the CURRENT shell to pick
#     up a newly-added group. If drums don't work right after this script,
#     log out and back in once.
#   - This is a deliberate, privileged global-input read — review the udev rule
#     before trusting it on a shared/sensitive machine.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "This setup must run as root (it installs a udev rule to /etc)." >&2
  echo "Try: sudo $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULE_SOURCE="$SCRIPT_DIR/50-bongocat-input.rules"
RULE_TARGET="/etc/udev/rules.d/50-bongocat-input.rules"
INPUT_GROUP="input"

# The user to grant access to. Default: the first non-root sudo caller (SUDO_USER)
# if available, otherwise the current user.
TARGET_USER="${SUDO_USER:-$(id -un)}"
if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
  echo "Could not determine the non-root target user." >&2
  exit 1
fi

echo "Setting up keyboard read access for user: $TARGET_USER"

# 1. Add the user to the input group (idempotent).
if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx "$INPUT_GROUP"; then
  echo "  • $TARGET_USER is already in the '$INPUT_GROUP' group."
else
  usermod -aG "$INPUT_GROUP" "$TARGET_USER"
  echo "  • Added $TARGET_USER to the '$INPUT_GROUP' group."
  REAUTH=1
fi

# 2. Install the udev rule (idempotent).
if [[ -f "$RULE_TARGET" ]] && cmp -s "$RULE_SOURCE" "$RULE_TARGET"; then
  echo "  • udev rule already installed and up to date."
else
  install -m 0644 "$RULE_SOURCE" "$RULE_TARGET"
  echo "  • Installed $RULE_TARGET"
fi

# 3. Reload and re-apply rules so existing devices pick up the change.
echo "  • Reloading udev rules…"
udevadm control --reload-rules
udevadm trigger --subsystem-match=input
echo "  • Re-applied rules to input devices."

echo
echo "Done. Your keyboard devices are now readable by the '$INPUT_GROUP' group."
if [[ "${REAUTH:-}" == "1" ]]; then
  echo "Note: your current session was started before the group change."
  echo "Log out and back in once (or reboot) for it to fully take effect in this shell."
else
  echo "You were already in the group, so it should work immediately."
fi