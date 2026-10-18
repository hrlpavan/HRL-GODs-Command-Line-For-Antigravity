#!/usr/bin/env bash
#
# archive_davinci_cache.sh
# ------------------------
# General Streaming Cache Archiver for Media Editors (Open Source Edition)
#
# Streams large video render cache directories (DaVinci Resolve, Final Cut Pro, Premiere)
# into a single sequential tar archive on external storage, bypassing ExFAT thousands-of-files bottlenecks.
#

set -euo pipefail

# Auto-detect default DaVinci Resolve cache directory if not supplied
DEFAULT_SRC="$HOME/DaVinci Resolve/FileDaVInci/CacheClip"
SRC_DIR="${1:-$DEFAULT_SRC}"

EXT_VOL=$(find /Volumes -maxdepth 1 -mindepth 1 -not -name "Macintosh HD" -not -name "Recovery" -not -name ".*" 2>/dev/null | head -n 1 || echo "")
if [ -n "$EXT_VOL" ]; then
    DEFAULT_DST="$EXT_VOL/Media_Cache_Archives/CacheClip_backup.tar"
else
    DEFAULT_DST="$HOME/Media_Cache_Archives/CacheClip_backup.tar"
fi

DST_TAR="${2:-$DEFAULT_DST}"

echo "=================================================="
echo "      High-Speed Media Render Cache Archiver       "
echo "=================================================="
echo "[*] Source: $SRC_DIR"
echo "[*] Target Archive: $DST_TAR"

if [ ! -d "$SRC_DIR" ]; then
    echo "[-] Source directory not found: $SRC_DIR"
    exit 0
fi

mkdir -p "$(dirname "$DST_TAR")"

PARENT_DIR="$(dirname "$SRC_DIR")"
BASE_NAME="$(basename "$SRC_DIR")"

echo "[*] Measuring source cache size..."
du -sh "$SRC_DIR"

echo "[*] Creating streaming sequential tar archive..."
tar -cf "$DST_TAR" -C "$PARENT_DIR" "$BASE_NAME"

echo "[✓] Archive created successfully:"
ls -lh "$DST_TAR"

echo "[*] Cleaning local cache directory and recreating clean container..."
rm -rf "$SRC_DIR"
mkdir -p "$SRC_DIR"

echo "[✓] Render cache offloaded successfully. Scratch directory initialized."
