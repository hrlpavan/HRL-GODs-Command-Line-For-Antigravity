# Contributing to HRL GOD's Command Line For Antigravity

Thank you for your interest in contributing to **HRL GOD's Command Line For Antigravity**!

## Core Principles
1. **Zero Cloud Dependencies:** All AI and image/OCR workflows must execute 100% on-device (e.g. Apple Vision framework on Apple Silicon).
2. **Strict Verification:** Never unlink or delete a file without strict size and integrity verification.
3. **No Hardcoded User Information:** Never hardcode user paths, drive names, or personal identities. Always use dynamic resolution (`$HOME`, `NSHomeDirectory()`, `Path.home()`, `/Volumes`).
4. **Platform Compatibility:** Support all modern macOS releases (Monterey, Ventura, Sonoma, Sequoia) across both Apple Silicon and Intel.

## Development Setup
```bash
git clone https://github.com/hrlpavan/HRL-GODs-Command-Line-For-Antigravity.git
cd HRL-GODs-Command-Line-For-Antigravity
./install.sh
```

## Pull Request Guidelines
- Ensure all scripts pass syntax checks (`python3 -m py_compile`, `swiftc -parse`).
- Test against dataless iCloud files and edge cases.
- Update documentation in `docs/` when adding new features or subcommands.
