#!/usr/bin/env python3
"""
hrl_god_cli.py
--------------
HRL GOD's Command Line For Antigravity (Open Source Edition)
Unified Administration, Storage & Vision AI Toolkit for macOS

Commands:
  organize      Analyze screenshot contents using Apple Vision OCR and sort into Important vs Trash
  screenshots   Find and clean screenshots via Spotlight metadata in milliseconds
  recordings    Clean dataless iCloud screen recordings via Swift Foundation
  storage       Analyze disk usage and perform 16MB chunked high-speed offload
  vm            Inspect and migrate Parallels Desktop Virtual Machines
"""

import argparse
import os
import subprocess
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SCRIPTS_DIR = os.path.join(BASE_DIR, "scripts")

def banner():
    print("""
===================================================================
       ⚡ HRL GOD's Command Line For Antigravity ⚡
   macOS Performance, Storage & Vision AI Automation Engine
===================================================================
""")

def detect_external_volume():
    """Detect first connected external volume under /Volumes."""
    volumes_dir = "/Volumes"
    if not os.path.exists(volumes_dir):
        return None
    for entry in os.listdir(volumes_dir):
        full = os.path.join(volumes_dir, entry)
        if os.path.ismount(full) and not entry.startswith(".") and entry not in ["Macintosh HD", "Recovery"]:
            return full
    return None

def cmd_organize(args):
    script = os.path.join(SCRIPTS_DIR, "organize_screenshots.swift")
    cmd = ["swift", script]
    if args.src:
        cmd.append(args.src)
    if args.dest:
        cmd.append(args.dest)
    subprocess.run(cmd)

def cmd_screenshots(args):
    if getattr(args, "organize", False):
        cmd_organize(args)
        return
    script = os.path.join(SCRIPTS_DIR, "clean_screenshots.py")
    cmd = [sys.executable, script]
    if args.scope:
        cmd.extend(["--scope", args.scope])
    if args.dest:
        cmd.extend(["--dest", args.dest])
    subprocess.run(cmd)

def cmd_recordings(args):
    script = os.path.join(SCRIPTS_DIR, "clean_screen_recordings.swift")
    cmd = ["swift", script]
    if args.scope:
        cmd.append(args.scope)
    subprocess.run(cmd)

def cmd_vm(args):
    if args.action == "status":
        subprocess.run(["prlctl", "list", "-a"])
    elif args.action == "migrate":
        script = os.path.join(SCRIPTS_DIR, "migrate_parallels_vm.sh")
        cmd = ["bash", script]
        if args.name:
            cmd.append(args.name)
        if args.dst:
            cmd.append(args.dst)
        subprocess.run(cmd)

def cmd_storage(args):
    if args.action == "status":
        print("[*] Current macOS Volume Space:")
        subprocess.run(["df", "-h", os.path.expanduser("~")])
    elif args.action == "offload":
        script = os.path.join(SCRIPTS_DIR, "offload_storage.py")
        cmd = [sys.executable, script]
        if args.src:
            cmd.extend(["--src", args.src])
        if args.dst:
            cmd.extend(["--dst", args.dst])
        if args.min_size:
            cmd.extend(["--min-size", str(args.min_size)])
        subprocess.run(cmd)

def interactive_menu():
    banner()
    ext = detect_external_volume()
    ext_label = f" ({os.path.basename(ext)})" if ext else " (None detected)"
    
    print("Select an option:")
    print("1) Check System Storage & Disk Space")
    print("2) Organize Screenshots via Apple Vision OCR (Important vs Trash)")
    print("3) Fast Clean Screenshots (Spotlight + ThreadPool)")
    print("4) Clean Dataless Screen Recordings (Swift Foundation)")
    print("5) High-Speed Storage Offload" + ext_label)
    print("6) Parallels Virtual Machine Status & Management")
    print("0) Exit")
    print("-" * 67)
    
    choice = input("Enter choice [0-6]: ").strip()
    if choice == "1":
        subprocess.run(["df", "-h", os.path.expanduser("~")])
    elif choice == "2":
        subprocess.run(["swift", os.path.join(SCRIPTS_DIR, "organize_screenshots.swift")])
    elif choice == "3":
        subprocess.run([sys.executable, os.path.join(SCRIPTS_DIR, "clean_screenshots.py")])
    elif choice == "4":
        subprocess.run(["swift", os.path.join(SCRIPTS_DIR, "clean_screen_recordings.swift")])
    elif choice == "5":
        subprocess.run([sys.executable, os.path.join(SCRIPTS_DIR, "offload_storage.py")])
    elif choice == "6":
        subprocess.run(["prlctl", "list", "-a"])
    elif choice == "0":
        print("Goodbye!")
        sys.exit(0)
    else:
        print("[!] Invalid option.")

def main():
    parser = argparse.ArgumentParser(description="HRL GOD's Command Line For Antigravity")
    subparsers = parser.add_subparsers(dest="command")

    # Organize
    p_org = subparsers.add_parser("organize", help="Analyze screenshots with Vision OCR into Important vs Trash")
    p_org.add_argument("--src", default="~/Desktop", help="Source directory (default: ~/Desktop)")
    p_org.add_argument("--dest", default="~/Organized_Screenshots", help="Target taxonomy directory")
    p_org.set_defaults(func=cmd_organize)

    # Screenshots
    p_sc = subparsers.add_parser("screenshots", help="Manage screenshots")
    p_sc.add_argument("--scope", default="~/Desktop", help="Directory scope")
    p_sc.add_argument("--dest", default="~/Screenshots_Removed", help="Destination folder")
    p_sc.add_argument("--organize", action="store_true", help="Run content-aware Vision OCR organizer")
    p_sc.set_defaults(func=cmd_screenshots)

    # Recordings
    p_rec = subparsers.add_parser("recordings", help="Clean dataless screen recordings via Swift")
    p_rec.add_argument("--scope", default="~/Desktop", help="Directory scope")
    p_rec.set_defaults(func=cmd_recordings)

    # VM
    p_vm = subparsers.add_parser("vm", help="Parallels VM management")
    p_vm.add_argument("action", choices=["status", "migrate"], help="Action to perform")
    p_vm.add_argument("--name", default=None, help="VM Name (auto-detects if omitted)")
    p_vm.add_argument("--dst", default=None, help="Target relocation path (auto-detects external drive)")
    p_vm.set_defaults(func=cmd_vm)

    # Storage
    p_st = subparsers.add_parser("storage", help="Storage analyzer and chunked offloader")
    p_st.add_argument("action", choices=["status", "offload"], help="Action to perform")
    p_st.add_argument("--src", default="~/Downloads", help="Source directory to offload")
    p_st.add_argument("--dst", default=None, help="Target directory (auto-detects external volume)")
    p_st.add_argument("--min-size", type=int, default=100, help="Min file size in MB")
    p_st.set_defaults(func=cmd_storage)

    if len(sys.argv) == 1:
        interactive_menu()
    else:
        args = parser.parse_args()
        if hasattr(args, "func"):
            banner()
            args.func(args)
        else:
            parser.print_help()

if __name__ == "__main__":
    main()
