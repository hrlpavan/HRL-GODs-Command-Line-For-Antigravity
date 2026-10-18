#!/usr/bin/env bash
#
# migrate_parallels_vm.sh
# -----------------------
# Parallels Desktop VM Live Migration Engine (Open Source Edition)
#
# Safely suspends, relocates, updates virtual hardware registry,
# and resumes a Parallels Virtual Machine across storage volumes.
#

set -euo pipefail

# Dynamic VM Name Detection
if [ "${1:-}" != "" ]; then
    VM_NAME="$1"
else
    # Auto-detect first available VM
    VM_NAME=$(prlctl list -a -o name --no-header 2>/dev/null | head -n 1 | sed 's/^[ \t]*//;s/[ \t]*$//' || echo "")
fi

if [ -z "$VM_NAME" ]; then
    echo "[!] No Parallels Virtual Machine detected. Provide VM name as argument: $0 <VM_NAME>"
    exit 1
fi

# Dynamic External Volume Detection
if [ "${2:-}" != "" ]; then
    TARGET_DIR="$2"
else
    EXT_VOL=$(find /Volumes -maxdepth 1 -mindepth 1 -not -name "Macintosh HD" -not -name "Recovery" -not -name ".*" 2>/dev/null | head -n 1 || echo "")
    if [ -n "$EXT_VOL" ]; then
        TARGET_DIR="$EXT_VOL/Parallels"
    else
        TARGET_DIR="$HOME/Parallels_Relocated"
    fi
fi

echo "=================================================="
echo "    Parallels Desktop Live VM Migration Tool      "
echo "=================================================="
echo "[*] Target VM: $VM_NAME"
echo "[*] Destination: $TARGET_DIR"

if ! command -v prlctl &>/dev/null; then
    echo "[!] Error: prlctl CLI not found. Is Parallels Desktop installed?"
    exit 1
fi

CURRENT_STATE=$(prlctl status "$VM_NAME" 2>/dev/null | awk '{print $4}' || echo "not_found")

if [ "$CURRENT_STATE" = "not_found" ]; then
    echo "[!] Error: Virtual machine '$VM_NAME' not found in Parallels registry."
    exit 1
fi

echo "[*] Current VM State: $CURRENT_STATE"

if [ "$CURRENT_STATE" = "running" ]; then
    echo "[*] Suspending VM to preserve memory state and active work..."
    prlctl suspend "$VM_NAME"
    echo "[✓] VM suspended successfully."
fi

mkdir -p "$TARGET_DIR"

echo "[*] Executing native prlctl relocation to $TARGET_DIR..."
prlctl move "$VM_NAME" --dst "$TARGET_DIR"

echo "[✓] Move complete. Re-verifying VM location in Parallels registry..."
prlctl list -i "$VM_NAME" | grep -E "Home:|State:"

echo "[*] Resuming VM on new drive location..."
prlctl resume "$VM_NAME"

echo "[✓] Parallels VM migration completed successfully."
