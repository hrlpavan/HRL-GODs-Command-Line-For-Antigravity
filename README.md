# ⚡ HRL GOD's Command Line For Antigravity

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/Platform-macOS%20%7C%20Apple%20Silicon%20%26%20Intel-black.svg?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Language-Swift%20%7C%20Python%203-orange.svg?logo=swift)](https://swift.org)
[![GitHub](https://img.shields.io/badge/Mirror-GitHub-181717.svg?logo=github)](https://github.com/hrlpavan/HRL-GODs-Command-Line-For-Antigravity)
[![GitLab](https://img.shields.io/badge/Mirror-GitLab-FC6D26.svg?logo=gitlab)](https://gitlab.com/hrlpavan/HRL-GODs-Command-Line-For-Antigravity)

> **High-Performance System Administration, Storage Reclamation & On-Device Vision AI Toolkit for macOS**

---

## 📌 Overview

**HRL GOD's Command Line For Antigravity** is a production-grade, open-source command-line toolkit developed for macOS power users, software engineers, and digital creators.

It provides high-performance solutions for common macOS performance and storage bottlenecks:
- **Zero Cloud Transmission:** Uses on-device Apple Neural Engine OCR (Apple Vision framework) to categorize and clean up thousands of screenshots into structured **Important** vs. **Trash** documents.
- **Instant Spotlight Discovery:** Bypasses slow POSIX directory crawls using CoreServices metadata indexing (`mdfind`) and multi-threaded APFS batch relocation.
- **Native iCloud Dataless Handling:** Uses Apple Foundation APIs (`FileManager.default.trashItem`) to trash offloaded iCloud files without downloading gigabytes of cloud stubs over the network.
- **High-Speed Storage Offload:** 16MB chunked buffered file transfers and streaming `.tar` archives optimized for external ExFAT and APFS drives.
- **Parallels Desktop VM Relocation:** Automated CLI suspension, migration, and resumption of live virtual machines across drives without data loss.

---

## 🚀 Quick Install

### One-Line Install (macOS Monterey, Ventura, Sonoma, Sequoia):
```bash
git clone https://github.com/hrlpavan/HRL-GODs-Command-Line-For-Antigravity.git ~/.hrl-god-repo
~/.hrl-god-repo/install.sh
```

---

## 🛠️ CLI Usage & Command Reference

Run `hrl-god` in your terminal to launch the interactive dashboard, or pass commands directly:

### 1. Vision AI Content-Aware Screenshot Organizer
Extracts on-device text from every screenshot using Apple's Neural Engine Vision framework and automatically sorts them into structured categories:
```bash
# Organize ~/Desktop screenshots into ~/Organized_Screenshots
hrl-god organize

# Specify custom source and target paths
hrl-god organize --src ~/Downloads --dest ~/My_Organized_Screenshots
```
**Categories Generated:**
- `Important_Documents/Academic_and_Study/` (Exams, syllabus, algorithms, lectures)
- `Important_Documents/Finance_and_Receipts/` (UPI, payments, invoices, bills)
- `Important_Documents/Code_and_Technical/` (Git, terminal, exceptions, APIs, cloud)
- `Important_Documents/Official_and_Legal/` (Certificates, credentials, contracts)
- `Important_Documents/General_Important/` (Dense structured text documents)
- `Trash_Documents/Memes_and_Social/` (Reels, memes, casual chat screenshots)
- `Trash_Documents/Low_Content_and_Misc/` (Blank/accidental captures, noise)

---

### 2. High-Speed Spotlight Screenshot Cleaner
Finds all screenshots in milliseconds using Spotlight metadata and moves them concurrently:
```bash
hrl-god screenshots --scope ~/Desktop --dest ~/Screenshots_Removed
```

---

### 3. Native Dataless Screen Recording Cleaner
Trashes offloaded iCloud screen recordings (`compressed,dataless`) without triggering multi-gigabyte network downloads:
```bash
hrl-god recordings --scope ~/Desktop
```

---

### 4. High-Speed 16MB Chunked Storage Offload
Transfers large files (> 100MB) from internal storage to an external drive at maximum hardware throughput with byte-size verification before unlinking:
```bash
# Auto-detects connected external drive
hrl-god storage offload --src ~/Downloads

# Custom destination and size threshold
hrl-god storage offload --src ~/Downloads --dst /Volumes/MyExternalDrive/Archive --min-size 200
```

---

### 5. Parallels Desktop VM Live Relocation
Suspends, relocates, updates virtual hardware XML registries, and resumes virtual machines on external storage:
```bash
hrl-god vm status
hrl-god vm migrate --name "Windows 11" --dst "/Volumes/MyExternalDrive/Parallels"
```

---

## 📂 Project Architecture

```text
HRL-GODs-Command-Line-For-Antigravity/
├── README.md                               # Project documentation & usage manual
├── LICENSE                                 # MIT Open Source License
├── CONTRIBUTING.md                         # Contribution guidelines
├── install.sh                              # Standalone installer script
├── hrl_god_cli.py                          # Unified CLI entrypoint with subcommands
├── bin/
│   └── hrl-god                             # Terminal binary wrapper
├── scripts/
│   ├── organize_screenshots.swift          # Apple Vision Neural Engine OCR classifier
│   ├── clean_screenshots.py                # Spotlight-indexed parallel screenshot cleaner
│   ├── clean_screen_recordings.swift       # Swift Foundation cleaner for dataless iCloud stubs
│   ├── offload_storage.py                  # High-speed 16MB chunked external transfer engine
│   ├── archive_davinci_cache.sh            # Streaming tar archiver for ExFAT small-file optimization
│   └── migrate_parallels_vm.sh             # Native Parallels CLI live VM migration script
└── docs/
    ├── TASK_1_SCREENSHOT_CLEANUP.md        # Technical report: Spotlight indexing vs POSIX traversal
    ├── TASK_2_SCREEN_RECORDING_CLEANUP.md  # Technical report: APFS dataless stubs & Swift API
    ├── TASK_3_VM_MIGRATION_AND_STORAGE_OFFLOAD.md # Technical report: VM relocation & chunked I/O
    └── TASK_4_CONTENT_AWARE_OCR_CLASSIFICATION.md # Technical report: Vision framework OCR engine
```

---

## 📚 Technical Deep Dives
* [Task 1: Superfast Screenshot Cleanup & Spotlight Metadata Traversal](docs/TASK_1_SCREENSHOT_CLEANUP.md)
* [Task 2: Native Dataless Screen Recording Cleanup via Swift Foundation](docs/TASK_2_SCREEN_RECORDING_CLEANUP.md)
* [Task 3: Live Parallels VM Migration & Chunked Storage Offloading](docs/TASK_3_VM_MIGRATION_AND_STORAGE_OFFLOAD.md)
* [Task 4: Content-Aware Screenshot Classification via Apple Vision OCR](docs/TASK_4_CONTENT_AWARE_OCR_CLASSIFICATION.md)

---

## 🌐 Mirrors & Repository Links

* **GitHub:** [https://github.com/hrlpavan/HRL-GODs-Command-Line-For-Antigravity](https://github.com/hrlpavan/HRL-GODs-Command-Line-For-Antigravity)
* **GitLab:** [https://gitlab.com/hrlpavan/HRL-GODs-Command-Line-For-Antigravity](https://gitlab.com/hrlpavan/HRL-GODs-Command-Line-For-Antigravity)

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
