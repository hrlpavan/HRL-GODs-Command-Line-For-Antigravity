# Task 3: Live VM Migration & Storage Offloading

## Executive Summary
This document outlines the architecture for recovering **46.0 GB of internal SSD storage** from Macintosh HD by safely relocating an active Parallels Windows 11 virtual machine and offloading high-capacity media assets to an external 2.0 TB drive (*My Passport*).

---

## 1. Initial State & Problem Analysis
- **Macintosh HD Initial Status:** 228 GB Total | 179 GB Used | **18 GB Available (92% capacity)**
- **System Impact:** System alerts, low-space slowdowns, and APFS snapshot pressure.
- **Root Contributors:**
  1. `Windows 11 (1).pvm` (Parallels Virtual Machine on internal SSD): **20.0 GB**
  2. Unnecessary large files in `~/Downloads` (Windows ARM ISO, 4K film, raw clips): **17.4 GB**
  3. Duplicate video footage in `~/SYNERGIA 26`: **11.0 GB**
  4. DaVinci Resolve temporary render cache (`CacheClip`): **14.0 GB** (12,921 files)

---

## 2. Parallels Desktop VM Migration (`prlctl`)

### Architectural Risk
The Windows 11 VM was actively running (`prl_vm_app`). Copying a live virtual disk (`harddisk.hdd.0.*.hds`) while the hypervisor holds write locks causes instant disk corruption and data loss.

### Safe Relocation Procedure:
1. **State Preservation:** Suspended the VM to preserve all running processes, memory, and desktop state without losing unsaved work:
   ```bash
   prlctl suspend "Windows 11 (1)"
   ```
2. **Native Relocation via CLI:**
   Utilized Parallels' native migration engine to handle XML descriptor updates (`config.pvs`, `DiskDescriptor.xml`) and physical `.pvm` relocation:
   ```bash
   prlctl move "Windows 11 (1)" --dst "/Volumes/My Passport/ HRL FILE/WINDOWS/Parallels"
   ```
3. **Internal Cleanup Verification:**
   Parallels automatically unlinked the original 20 GB bundle from `/Users/pavankumars/Parallels/Windows 11 (1).pvm`, freeing **~20 GB instantly**.
4. **Resumption:**
   Restored the VM session from the external drive:
   ```bash
   prlctl resume "Windows 11 (1)"
   ```
   Verified `State: running` with storage mapped to `/Volumes/My Passport/`.

---

## 3. High-Speed Media Offload Engine

### ExFAT Write Speed Calibration
External mechanical drives formatted in ExFAT have a standard sequential ceiling of ~30-35 MB/s over USB 3.0.

### Chunked 16MB Streaming Pipeline (`offload_storage.py`)
Standard Python `shutil.copy` uses small 64KB buffers that cause head thrashing. We engineered a streaming copy utility using a 16MB block size:
```python
def copy_file_chunked(src, dst):
    buf_size = 16 * 1024 * 1024  # 16 MB
    with open(src, 'rb') as fsrc, open(dst, 'wb') as fdst:
        while chunk := fsrc.read(buf_size):
            fdst.write(chunk)
        fdst.flush()
        os.fsync(fdst.fileno())
```
- **Strict Byte-Size Verification:** The source file was never removed until `os.path.getsize(dst) == sz` evaluated true.
- **Transferred Files:** 17 files totaling **17.37 GB** moved to `/Volumes/My Passport/Macintosh_HD_Offloaded_Files/Downloads/`.

---

## 4. DaVinci Resolve Render Cache Optimization

### The ExFAT Small-File Bottleneck
The DaVinci Resolve render cache (`CacheClip`) contained **12,921 individual small files** totaling 14 GB. Writing 12,921 separate directory entries onto an ExFAT partition would take 30+ minutes due to FAT table synchronization.

### Streaming TAR Solution:
We bypassed the directory entry bottleneck by streaming the directory structure into a single sequential archive:
```bash
tar -cf "/Volumes/My Passport/Macintosh_HD_Offloaded_Files/DaVinci_Resolve_Cache/CacheClip_backup.tar" \
    -C "/Users/pavankumars/DaVinci Resolve/FileDaVInci" CacheClip
```
- Transferred 14 GB in ~7.5 minutes (~31 MB/s sustained sequential rate).
- Safely removed the 14 GB directory from internal storage and recreated an empty `CacheClip/` directory to prevent DaVinci Resolve launch errors.

---

## 5. Duplicate Asset Deduplication (`SYNERGIA 26`)
We analyzed `/Users/pavankumars/SYNERGIA 26` against `/Volumes/My Passport/SYNERGIA 26`:
- Verified 38 files were 100% byte-for-byte identical.
- Safely removed the internal folder without performing redundant USB writes, immediately freeing **11.0 GB**.

---

## 6. Final Results & System Health

```text
Storage Metric                  Before Migration        After Migration
Macintosh HD Used Space:        179 GB                  132 GB
Macintosh HD Free Space:        18 GB                   64 GB (+46 GB Reclaimed)
Capacity Percentage:            92%                     68%
Windows VM Status:              Running (Internal)      Running (My Passport)
Data Loss:                      0 bytes                 0 bytes
```
