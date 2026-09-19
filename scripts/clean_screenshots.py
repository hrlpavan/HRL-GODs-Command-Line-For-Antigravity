#!/usr/bin/env python3
"""
clean_screenshots.py
--------------------
HRL GOD's Superfast Screenshot Cleanup Utility

Leverages native macOS Spotlight metadata indexing (`kMDItemIsScreenCapture == 1`)
to find all system screenshots in milliseconds, and uses ThreadPoolExecutor
for high-speed concurrent moving into macOS Trash or a safe backup folder.
"""

import argparse
import concurrent.futures
import os
import subprocess
import sys

def get_screenshots(search_dir=None):
    """Find screenshots in milliseconds using Spotlight mdfind."""
    cmd = ["mdfind"]
    if search_dir:
        cmd.extend(["-onlyin", os.path.expanduser(search_dir)])
    cmd.append("kMDItemIsScreenCapture == 1")
    
    try:
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        files = [line.strip() for line in res.stdout.splitlines() if line.strip() and os.path.exists(line.strip())]
        return files
    except Exception as e:
        print(f"[!] Spotlight search error: {e}", file=sys.stderr)
        return []

def move_worker(item):
    src, dst_dir = item
    os.makedirs(dst_dir, exist_ok=True)
    base = os.path.basename(src)
    dst = os.path.join(dst_dir, base)
    
    try:
        os.rename(src, dst)
        return True, src
    except FileNotFoundError:
        return False, src
    except Exception as e:
        return False, f"{src} -> {e}"

def clean_screenshots(target_dir="~/Screenshots_Removed", search_scope="~/Desktop", max_workers=32):
    target_path = os.path.expanduser(target_dir)
    scope_path = os.path.expanduser(search_scope)
    
    print(f"[*] Querying Spotlight for screenshots in {scope_path}...")
    files = get_screenshots(scope_path)
    
    if not files:
        print("[+] No screenshots found! Workspace is clean.")
        return 0
        
    print(f"[+] Found {len(files)} screenshots. Moving to: {target_path} using {max_workers} threads...")
    tasks = [(f, target_path) for f in files]
    
    success = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        for ok, detail in executor.map(move_worker, tasks):
            if ok:
                success += 1
            else:
                print(f"[-] Failed: {detail}", file=sys.stderr)
                
    print(f"[✓] Successfully moved {success}/{len(files)} screenshots.")
    return success

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Superfast macOS Screenshot Cleaner")
    parser.add_argument("--scope", default="~/Desktop", help="Directory scope to search (default: ~/Desktop)")
    parser.add_argument("--dest", default="~/Screenshots_Removed", help="Destination folder (default: ~/Screenshots_Removed)")
    parser.add_argument("--threads", type=int, default=32, help="Worker threads (default: 32)")
    
    args = parser.parse_args()
    clean_screenshots(target_dir=args.dest, search_scope=args.scope, max_workers=args.threads)
