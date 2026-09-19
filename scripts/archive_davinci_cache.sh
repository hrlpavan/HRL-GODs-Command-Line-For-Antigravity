#!/usr/bin/env bash
#
# archive_davinci_cache.sh
# ------------------------
# Streams DaVinci Resolve render cache directory into a single sequential tar archive
# on an external drive, bypassing ExFAT thousands-of-files write bottlenecks.
#

set -euo pipefail

SRC_DIR="${1:-$HOME/DaVinci Resolve/FileDaVInci/CacheClip}"
DST_TAR="${2:-/Volumes/My Passport/Macintosh_HD_Offloaded_Files/DaVinci_Resolve_Cache/CacheClip_backup.tar}"

echo "[*] DaVinci Resolve Cache Archiver"
echo "[*] Source: $SRC_DIR"
echo "[*] Target Archive: $DST_TAR"

if [ ! -d "$SRC_DIR" ]; then
    echo "[-] Source directory not found: $SRC_DIR"
    exit 0
fi

# Ensure parent directory of destination exists
mkdir -p "$(dirname "$DST_TAR")"

PARENT_DIR="$(dirname "$SRC_DIR")"
BASE_NAME="$(basename "$SRC_DIR")"

echo "[*] Measuring source cache size..."
du -sh "$SRC_DIR"

echo "[*] Creating streaming sequential tar archive on external drive..."
tar -cf "$DST_TAR" -C "$PARENT_DIR" "$BASE_NAME"

echo "[✓] Archive created successfully:"
ls -lh "$DST_TAR"

echo "[*] Cleaning local CacheClip directory and recreating empty container..."
rm -rf "$SRC_DIR"
mkdir -p "$SRC_DIR"

echo "[✓] DaVinci Resolve cache offloaded successfully. Scratch container ready."
