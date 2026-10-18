# Task 3: Live VM Migration & Storage Offloading

## Executive Summary
This document outlines the architecture for recovering tens of gigabytes of internal SSD storage from macOS by safely relocating active Parallels Virtual Machines and offloading high-capacity media assets to external storage volumes.

---

## 1. Problem Statement & Architecture
Internal Mac SSDs are frequently constrained by:
1. Virtual Machine bundles (`.pvm`, `.vmdk`) consuming 20–50+ GB on the primary APFS boot container.
2. Large uncompressed installers, ISO images, and 4K media in `~/Downloads`.
3. Temporary media render caches (e.g., DaVinci Resolve, Final Cut Pro `CacheClip`) containing tens of thousands of tiny files.

---

## 2. Parallels Desktop VM Relocation (`prlctl`)

### Architectural Risk
Copying a live virtual disk (`harddisk.hdd.0.*.hds`) while the hypervisor holds active write locks causes immediate disk corruption and system failure.

### Safe Relocation Procedure:
1. **State Preservation:** Suspend the VM to preserve all running processes, memory, and desktop state without losing unsaved work:
   ```bash
   prlctl suspend "<VM_NAME>"
   ```
2. **Native Relocation via CLI:**
   Utilize Parallels' native migration engine to handle XML descriptor updates (`config.pvs`, `DiskDescriptor.xml`) and physical `.pvm` relocation:
   ```bash
   prlctl move "<VM_NAME>" --dst "/Volumes/<EXTERNAL_DRIVE>/Parallels"
   ```
3. **Internal Cleanup:**
   Parallels automatically unlinks the original bundle from the internal storage, freeing internal SSD space immediately.
4. **Resumption:**
   Restore the VM session from the external drive:
   ```bash
   prlctl resume "<VM_NAME>"
   ```
   The VM continues running seamlessly directly from the external drive.

---

## 3. High-Speed Media Offload Engine

### ExFAT Write Speed Calibration
External mechanical and flash drives formatted in ExFAT have a standard sequential ceiling of ~30–120 MB/s over USB 3.0.

### Chunked 16MB Streaming Pipeline (`offload_storage.py`)
Standard Python `shutil.copy` uses small 64KB buffers that cause heavy head thrashing on external drives. We engineered a streaming copy utility using a 16MB block size:
```python
def copy_file_chunked(src, dst):
    buf_size = 16 * 1024 * 1024  # 16 MB block size
    with open(src, 'rb') as fsrc, open(dst, 'wb') as fdst:
        while chunk := fsrc.read(buf_size):
            fdst.write(chunk)
        fdst.flush()
        os.fsync(fdst.fileno())
```
- **Strict Byte-Size Verification:** Source files are never removed until `os.path.getsize(dst) == src_size` evaluates true.

---

## 4. Render Cache Optimization & Archiving

### The ExFAT Small-File Bottleneck
Video editor render caches (such as DaVinci Resolve `CacheClip`) frequently contain 10,000+ tiny files totaling 10–20+ GB. Writing thousands of individual directory entries onto an ExFAT partition causes severe disk thrashing due to continuous FAT table updates.

### Streaming TAR Solution:
Bypass directory entry overhead by streaming the directory structure sequentially into a single archive:
```bash
tar -cf "/Volumes/<EXTERNAL_DRIVE>/CacheClip_backup.tar" -C "$HOME/DaVinci Resolve/FileDaVInci" CacheClip
```
- Sustains maximum sequential hardware write speeds.
- Local scratch directory is safely cleaned and recreated with an empty container to prevent application launch errors.
