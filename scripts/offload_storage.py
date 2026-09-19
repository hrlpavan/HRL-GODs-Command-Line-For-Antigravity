#!/usr/bin/env python3
"""
offload_storage.py
------------------
HRL GOD's High-Speed Storage Offload Engine

Performs high-speed 16MB chunked file transfers from internal SSD to external storage,
verifies byte-size matching, and unlinks source files only after successful verification.
"""

import argparse
import os
import sys
import time

BUF_SIZE = 16 * 1024 * 1024  # 16 MB block size for optimal sequential write

def copy_chunked(src, dst):
    with open(src, 'rb') as fsrc, open(dst, 'wb') as fdst:
        while True:
            chunk = fsrc.read(BUF_SIZE)
            if not chunk:
                break
            fdst.write(chunk)
        fdst.flush()
        os.fsync(fdst.fileno())

def offload_file(src_path, dst_dir):
    os.makedirs(dst_dir, exist_ok=True)
    base = os.path.basename(src_path)
    dst_path = os.path.join(dst_dir, base)
    
    if not os.path.exists(src_path):
        print(f"[-] Source not found: {src_path}", file=sys.stderr)
        return False
        
    src_size = os.path.getsize(src_path)
    size_mb = src_size / (1024 * 1024)
    print(f"[*] Copying: {base} ({size_mb:.1f} MB)...", end="", flush=True)
    
    t0 = time.time()
    try:
        copy_chunked(src_path, dst_path)
        t1 = time.time()
        duration = max(t1 - t0, 0.001)
        speed = size_mb / duration
        
        # Strict byte size validation
        dst_size = os.path.getsize(dst_path)
        if dst_size == src_size:
            os.remove(src_path)
            print(f" [✓] Verified & Unlinked ({speed:.1f} MB/s)")
            return True
        else:
            print(f" [!] ERROR: Size mismatch ({dst_size} != {src_size}). Source retained.")
            return False
    except Exception as e:
        print(f" [!] ERROR: {e}")
        return False

def offload_directory_large_files(src_dir, dst_dir, min_size_mb=100):
    src_dir = os.path.expanduser(src_dir)
    dst_dir = os.path.expanduser(dst_dir)
    min_bytes = min_size_mb * 1024 * 1024
    
    print(f"[*] Scanning {src_dir} for files larger than {min_size_mb} MB...")
    candidates = []
    for root, _, files in os.walk(src_dir):
        for f in files:
            p = os.path.join(root, f)
            try:
                if os.path.isfile(p) and os.path.getsize(p) >= min_bytes:
                    candidates.append(p)
            except (PermissionError, FileNotFoundError):
                pass
                
    if not candidates:
        print("[+] No files exceeding threshold.")
        return
        
    total_gb = sum(os.path.getsize(p) for p in candidates) / (1024**3)
    print(f"[+] Found {len(candidates)} candidate files totaling {total_gb:.2f} GB.")
    
    freed = 0
    for i, p in enumerate(candidates, 1):
        print(f"[{i}/{len(candidates)}] ", end="")
        sz = os.path.getsize(p)
        if offload_file(p, dst_dir):
            freed += sz
            
    print(f"\n[✓] Offload complete. Total reclaimed space: {freed / (1024**3):.2f} GB.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="High-Speed Storage Offload Engine")
    parser.add_argument("--src", default="~/Downloads", help="Source directory (default: ~/Downloads)")
    parser.add_argument("--dst", default="/Volumes/My Passport/Macintosh_HD_Offloaded_Files/Downloads", help="Target external directory")
    parser.add_argument("--min-size", type=int, default=100, help="Minimum file size in MB (default: 100)")
    
    args = parser.parse_args()
    offload_directory_large_files(args.src, args.dst, args.min_size)
