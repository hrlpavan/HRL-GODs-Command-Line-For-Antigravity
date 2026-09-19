#!/usr/bin/env python3
"""
hrl_god_cli.py
--------------
HRL GOD's Command Line For Antigravity
Unified Administration & Performance CLI for macOS & Parallels

Commands:
  screenshots   Manage and clean screenshots via Spotlight
  recordings    Manage and clean dataless screen recordings via Swift
  vm            Check status and migrate Parallels VMs
  storage       Analyze disk usage and offload large media to external drive
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
   macOS Performance, Storage & Parallels Automation Engine
===================================================================
""")

def cmd_screenshots(args):
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
        print("[*] Current Macintosh HD Space:")
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
    print("Select an option:")
    print("1) Check System Storage & Disk Space")
    print("2) Clean Desktop Screenshots (Spotlight + ThreadPool)")
    print("3) Clean Desktop Screen Recordings (Native Swift)")
    print("4) Parallels Virtual Machine Status")
    print("5) Offload Large Files from Downloads to My Passport")
    print("0) Exit")
    print("-" * 65)
    
    choice = input("Enter choice [0-5]: ").strip()
    if choice == "1":
        subprocess.run(["df", "-h", os.path.expanduser("~")])
    elif choice == "2":
        subprocess.run([sys.executable, os.path.join(SCRIPTS_DIR, "clean_screenshots.py")])
    elif choice == "3":
        subprocess.run(["swift", os.path.join(SCRIPTS_DIR, "clean_screen_recordings.swift")])
    elif choice == "4":
        subprocess.run(["prlctl", "list", "-a"])
    elif choice == "5":
        subprocess.run([sys.executable, os.path.join(SCRIPTS_DIR, "offload_storage.py")])
    elif choice == "0":
        print("Goodbye!")
        sys.exit(0)
    else:
        print("[!] Invalid option.")

def main():
    parser = argparse.ArgumentParser(description="HRL GOD's Command Line For Antigravity")
    subparsers = parser.add_subparsers(dest="command")

    # Screenshots
    p_sc = subparsers.add_parser("screenshots", help="Clean screenshots using Spotlight")
    p_sc.add_argument("--scope", default="~/Desktop", help="Directory scope")
    p_sc.add_argument("--dest", default="~/Screenshots_Removed", help="Destination folder")
    p_sc.set_defaults(func=cmd_screenshots)

    # Recordings
    p_rec = subparsers.add_parser("recordings", help="Clean dataless screen recordings via Swift")
    p_rec.add_argument("--scope", default="~/Desktop", help="Directory scope")
    p_rec.set_defaults(func=cmd_recordings)

    # VM
    p_vm = subparsers.add_parser("vm", help="Parallels VM commands")
    p_vm.add_argument("action", choices=["status", "migrate"], help="Action to perform")
    p_vm.add_argument("--name", default="Windows 11 (1)", help="VM Name")
    p_vm.add_argument("--dst", default="/Volumes/My Passport/ HRL FILE/WINDOWS/Parallels", help="Target relocation path")
    p_vm.set_defaults(func=cmd_vm)

    # Storage
    p_st = subparsers.add_parser("storage", help="Disk storage analyzer and offloader")
    p_st.add_argument("action", choices=["status", "offload"], help="Action to perform")
    p_st.add_argument("--src", default="~/Downloads", help="Source directory to offload")
    p_st.add_argument("--dst", default="/Volumes/My Passport/Macintosh_HD_Offloaded_Files/Downloads", help="Target directory")
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
