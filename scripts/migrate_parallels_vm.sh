#!/usr/bin/env bash
#
# migrate_parallels_vm.sh
# -----------------------
# Safely suspends, relocates, and resumes a Parallels Desktop Virtual Machine
# using native Parallels CLI tools (`prlctl`).
#

set -euo pipefail

VM_NAME="${1:-Windows 11 (1)}"
TARGET_DIR="${2:-/Volumes/My Passport/ HRL FILE/WINDOWS/Parallels}"

echo "=================================================="
echo "    Parallels Desktop Live VM Migration Tool      "
echo "=================================================="
echo "[*] Target VM: $VM_NAME"
echo "[*] Destination: $TARGET_DIR"

if ! command -v prlctl &>/dev/null; then
    echo "[!] Error: prlctl command not found. Is Parallels Desktop installed?"
    exit 1
fi

# Check VM status
CURRENT_STATE=$(prlctl status "$VM_NAME" 2>/dev/null | awk '{print $4}' || echo "not_found")

if [ "$CURRENT_STATE" = "not_found" ]; then
    echo "[!] Error: Virtual machine '$VM_NAME' not found in Parallels registry."
    exit 1
fi

echo "[*] Current VM State: $CURRENT_STATE"

# If VM is running, suspend it safely
if [ "$CURRENT_STATE" = "running" ]; then
    echo "[*] Suspending VM to preserve memory state and active work..."
    prlctl suspend "$VM_NAME"
    echo "[✓] VM suspended successfully."
fi

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

echo "[*] Executing native prlctl relocation to $TARGET_DIR..."
prlctl move "$VM_NAME" --dst "$TARGET_DIR"

echo "[✓] Move complete. Re-verifying VM location in Parallels registry..."
prlctl list -i "$VM_NAME" | grep -E "Home:|State:"

echo "[*] Resuming VM on new drive location..."
prlctl resume "$VM_NAME"

echo "[✓] Parallels VM migration completed successfully."
