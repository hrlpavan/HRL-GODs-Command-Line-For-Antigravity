#!/usr/bin/env swift
//
// clean_screen_recordings.swift
// -----------------------------
// HRL GOD's Native Apple Screen Recording Cleaner
//
// Uses Apple's native Foundation FileManager API to trash screen recordings
// without triggering network downloads on APFS `compressed,dataless` iCloud stubs.
//

import Foundation

let arguments = CommandLine.arguments
var targetDirectoryPath = ("~/Desktop" as NSString).expandingTildeInPath

if arguments.count > 1 {
    targetDirectoryPath = (arguments[1] as NSString).expandingTildeInPath
}

let targetURL = URL(fileURLWithPath: targetDirectoryPath)
let fileManager = FileManager.default

print("[*] Scanning \(targetURL.path) for Screen Recording video files...")

do {
    let contents = try fileManager.contentsOfDirectory(at: targetURL, includingPropertiesForKeys: nil)
    var count = 0
    var failed = 0
    
    for file in contents {
        let name = file.lastPathComponent
        let ext = file.pathExtension.lowercased()
        
        if (name.hasPrefix("Screen Recording") || name.hasPrefix("Screen recording")) && (ext == "mov" || ext == "mp4") {
            print("[+] Trashing dataless stub: \(name)...")
            do {
                try fileManager.trashItem(at: file, resultingItemURL: nil)
                count += 1
            } catch {
                print("[-] Failed to trash \(name): \(error.localizedDescription)")
                failed += 1
            }
        }
    }
    
    print("[✓] Finished. Successfully moved \(count) screen recordings to macOS Trash (Failures: \(failed)).")
} catch {
    print("[!] Error reading directory: \(error.localizedDescription)")
    exit(1)
}
