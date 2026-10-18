#!/usr/bin/env swift
//
// organize_screenshots.swift
// -------------------------
// Native macOS Content-Aware Screenshot Organizer
// Part of HRL GOD's Command Line For Antigravity (Open Source Edition)
//
// Analyzes visual contents of screenshots using Apple's native Vision framework OCR
// (accelerated on Apple Silicon Neural Engine) and automatically sorts them into
// Important Documents vs. Trash Documents. Works for any macOS user and directory.
//

import Foundation
import Vision
import AppKit

struct ClassificationResult: Codable {
    let filename: String
    let sourcePath: String
    let targetPath: String
    let category: String
    let subcategory: String
    let confidenceReason: String
    let lineCount: Int
    let sampleText: String
}

enum Category: String, Codable {
    case important = "Important_Documents"
    case trash = "Trash_Documents"
}

enum Subcategory: String, Codable {
    case academic = "Academic_and_Study"
    case finance = "Finance_and_Receipts"
    case technical = "Code_and_Technical"
    case official = "Official_and_Legal"
    case generalImportant = "General_Important"
    case socialMeme = "Memes_and_Social"
    case lowContent = "Low_Content_and_Misc"
}

func classifyText(text: String, lineCount: Int) -> (Category, Subcategory, String) {
    let lower = text.lowercased()
    let trimmed = lower.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Low content threshold (blank captures, UI noise, icons)
    if trimmed.count < 15 || lineCount <= 1 {
        return (.trash, .lowContent, "Minimal or no textual information (\(trimmed.count) chars, \(lineCount) lines)")
    }
    
    // Academic & Education
    let academicKeywords = [
        "algorithm", "syllabus", "semester", "exam", "assignment", "university",
        "faculty", "college", "lecture", "module", "question paper", "marks", "student",
        "engineering", "notes", "attendance", "cgpa", "sgpa", "lab", "practical",
        "cie", "midterm", "final exam", "textbook", "homework"
    ]
    for kw in academicKeywords {
        if lower.contains(kw) {
            return (.important, .academic, "Matched academic keyword: '\(kw)'")
        }
    }
    
    // Finance & Transactions
    let financeKeywords = [
        "receipt", "invoice", "payment", "paid", "transaction", "upi", "gpay", "phonepe",
        "paytm", "order id", "billing", "amount paid", "total:", "subtotal", "bank",
        "debited", "credited", "tax invoice", "dollar", "usd", "inr", "eur", "gbp", "₹", "$"
    ]
    for kw in financeKeywords {
        if lower.contains(kw) {
            return (.important, .finance, "Matched financial keyword: '\(kw)'")
        }
    }
    
    // Official & Legal / Credentials
    let officialKeywords = [
        "certificate", "license", "agreement", "contract", "confidential", "authorized",
        "passport", "identity card", "id card", "verification code", "one time password",
        "appointment", "offer letter", "payroll", "policy", "terms of service", "tax"
    ]
    for kw in officialKeywords {
        if lower.contains(kw) {
            return (.important, .official, "Matched official/legal keyword: '\(kw)'")
        }
    }
    
    // Technical & Code
    let techKeywords = [
        "github", "gitlab", "commit", "pull request", "repository", "terminal", "zsh", "bash",
        "def ", "class ", "import ", "function", "error:", "exception:", "traceback", "docker",
        "kubernetes", "k8s", "api key", "aws", "gcp", "azure", "curl ", "npm ", "pip ",
        "python", "swift", "developer", "console", "ssh", "sudo", "config", "stack trace"
    ]
    for kw in techKeywords {
        if lower.contains(kw) {
            return (.important, .technical, "Matched technical keyword: '\(kw)'")
        }
    }
    
    // Social / Memes / Casual
    let memeKeywords = [
        "meme", "lmao", "rofl", "reels", "tiktok", "instagram story", "views", "followers",
        "following", "like comment share", "fyp", "for you page", "subscribed"
    ]
    for kw in memeKeywords {
        if lower.contains(kw) {
            return (.trash, .socialMeme, "Matched social/meme keyword: '\(kw)'")
        }
    }
    
    // Substantial text document fallback
    if lineCount >= 6 || trimmed.count >= 150 {
        return (.important, .generalImportant, "Substantial structured text document (\(lineCount) lines, \(trimmed.count) chars)")
    }
    
    return (.trash, .lowContent, "Brief snippet or casual capture without document indicators")
}

// Dynamic Path Resolution
let fileManager = FileManager.default
let homeDir = NSHomeDirectory()

var sourceDirectoryPath = "\(homeDir)/Desktop"
var targetDirectoryPath = "\(homeDir)/Organized_Screenshots"

let args = CommandLine.arguments
if args.count > 1 {
    sourceDirectoryPath = (args[1] as NSString).expandingTildeInPath
}
if args.count > 2 {
    targetDirectoryPath = (args[2] as NSString).expandingTildeInPath
}

print("""
===================================================================
      🔍 Native macOS Content-Aware Screenshot Classifier
   Apple Vision Framework (Neural Engine Accelerated)
===================================================================
[*] Source: \(sourceDirectoryPath)
[*] Target: \(targetDirectoryPath)
""")

guard let files = try? fileManager.contentsOfDirectory(atPath: sourceDirectoryPath) else {
    print("[!] Error: Unable to read directory: \(sourceDirectoryPath)")
    exit(1)
}

let screenshotFiles = files.filter { 
    ($0.hasPrefix("Screenshot") || $0.hasPrefix("Screen Shot")) && 
    ($0.hasSuffix(".png") || $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg")) 
}.sorted()

print("[+] Discovered \(screenshotFiles.count) screenshots to analyze.")

if screenshotFiles.isEmpty {
    print("[+] No screenshots found in source directory. Target is clean!")
    exit(0)
}

// Create destination taxonomy folders
let categories: [(Category, Subcategory)] = [
    (.important, .academic),
    (.important, .finance),
    (.important, .technical),
    (.important, .official),
    (.important, .generalImportant),
    (.trash, .socialMeme),
    (.trash, .lowContent)
]

for (cat, sub) in categories {
    let dir = "\(targetDirectoryPath)/\(cat.rawValue)/\(sub.rawValue)"
    try? fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
}

var results: [ClassificationResult] = []
let lock = NSLock()
let queue = OperationQueue()
queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount

let startTime = CFAbsoluteTimeGetCurrent()

for file in screenshotFiles {
    queue.addOperation {
        let srcPath = "\(sourceDirectoryPath)/\(file)"
        let url = URL(fileURLWithPath: srcPath)
        
        var recognizedText = ""
        var lineCount = 0
        
        if let image = NSImage(contentsOf: url),
           let tiff = image.tiffRepresentation,
           let ci = CIImage(data: tiff) {
            
            let req = VNRecognizeTextRequest()
            req.recognitionLevel = .fast
            req.usesLanguageCorrection = false
            
            let handler = VNImageRequestHandler(ciImage: ci, options: [:])
            if let _ = try? handler.perform([req]), let obs = req.results {
                let lines = obs.compactMap { $0.topCandidates(1).first?.string }
                lineCount = lines.count
                recognizedText = lines.joined(separator: "\n")
            }
        }
        
        let (cat, sub, reason) = classifyText(text: recognizedText, lineCount: lineCount)
        let targetDir = "\(targetDirectoryPath)/\(cat.rawValue)/\(sub.rawValue)"
        let targetPath = "\(targetDir)/\(file)"
        
        var moved = false
        do {
            try fileManager.moveItem(atPath: srcPath, toPath: targetPath)
            moved = true
        } catch {
            print("[-] Error moving \(file): \(error.localizedDescription)")
        }
        
        if moved {
            let sample = recognizedText.components(separatedBy: .newlines).prefix(3).joined(separator: " | ")
            let record = ClassificationResult(
                filename: file,
                sourcePath: srcPath,
                targetPath: targetPath,
                category: cat.rawValue,
                subcategory: sub.rawValue,
                confidenceReason: reason,
                lineCount: lineCount,
                sampleText: String(sample.prefix(120))
            )
            
            lock.lock()
            results.append(record)
            let completed = results.count
            if completed % 100 == 0 || completed == screenshotFiles.count {
                let elapsed = CFAbsoluteTimeGetCurrent() - startTime
                let rate = Double(completed) / max(elapsed, 0.001)
                print("  -> Analyzed & Organized: \(completed)/\(screenshotFiles.count) (\(String(format: "%.1f", rate)) img/sec)")
            }
            lock.unlock()
        }
    }
}

queue.waitUntilAllOperationsAreFinished()
let totalElapsed = CFAbsoluteTimeGetCurrent() - startTime
print("[✓] Processed \(results.count) screenshots in \(String(format: "%.2f", totalElapsed))s")

// Save manifest index
let manifestPath = "\(targetDirectoryPath)/classification_manifest.json"
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
if let data = try? encoder.encode(results) {
    try? data.write(to: URL(fileURLWithPath: manifestPath))
    print("[+] Saved complete classification manifest to: \(manifestPath)")
}

let importantCount = results.filter { $0.category == Category.important.rawValue }.count
let trashCount = results.filter { $0.category == Category.trash.rawValue }.count

print("""

=================== CLASSIFICATION SUMMARY ===================
Total Screenshots Processed: \(results.count)
📂 Important Documents:     \(importantCount)
🗑️ Trash Documents:         \(trashCount)
Destination:                \(targetDirectoryPath)
==============================================================
""")
