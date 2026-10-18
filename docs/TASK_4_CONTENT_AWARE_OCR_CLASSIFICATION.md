# Task 4: Native Content-Aware Screenshot Classification via Apple Vision OCR

## Executive Summary
This document details the architecture and implementation of an automated, on-device OCR categorization engine for macOS. It reads the textual information inside screenshots using Apple's Vision framework (`VNRecognizeTextRequest`) and classifies them into structured **Important Documents** versus disposable **Trash Documents** with zero cloud transmission.

---

## 1. Problem Statement
Users frequently accumulate thousands of screenshots over months of academic study, software development, financial transactions, and casual web browsing. 

Traditional approaches either:
1. Treat all screenshots as disposable and risk deleting sensitive receipts, certificates, or code.
2. Require manual human sorting of thousands of files.
3. Transmit private screenshots to third-party cloud vision APIs, raising serious privacy, data security, and latency concerns.

---

## 2. Engineering Architecture

```text
┌────────────────────────────────────────────────────────────────────────┐
│             HRL NATIVE VISION CLASSIFICATION PIPELINE                  │
│                                                                        │
│  [Source Directory: ~/Desktop]                                         │
│               │                                                        │
│               ▼                                                        │
│  [Apple Vision Framework: VNRecognizeTextRequest]                      │
│  (Accelerated via Apple Silicon Neural Engine / GPU)                   │
│               │                                                        │
│               ▼                                                        │
│  [Text Normalization & Lexical Classifier Engine]                      │
│               │                                                        │
│       ┌───────┴────────────────────────┐                               │
│       ▼                                ▼                               │
│  [Important Documents]           [Trash Documents]                     │
│  • Academic & Study              • Memes & Social Media                │
│  • Finance & Receipts            • Low Content / Accidental            │
│  • Code & Technical                                                    │
│  • Official & Legal                                                    │
│  • General Structured Text                                             │
│               │                                                        │
│               ▼                                                        │
│  [Atomic APFS Relocation + Manifest Generation: classification_manifest.json]
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Classification Taxonomy

### A. Important Documents
- **`Academic_and_Study/`**: Identifies academic tokens (`algorithm`, `syllabus`, `exam`, `assignment`, `lecture`, `module`, `notes`, `practical`, `cie`, `attendance`).
- **`Finance_and_Receipts/`**: Detects monetary and transaction tokens (`receipt`, `invoice`, `payment`, `upi`, `gpay`, `phonepe`, `order id`, `billing`, `tax invoice`, currency symbols `₹`, `$`).
- **`Code_and_Technical/`**: Matches developer indicators (`github`, `gitlab`, `commit`, `pull request`, `terminal`, `def `, `class `, `error:`, `exception:`, `docker`, `kubernetes`, `aws`, `gcp`, `api key`).
- **`Official_and_Legal/`**: Matches verification, identity, and governance terms (`certificate`, `passport`, `license`, `agreement`, `verification code`, `authorized`, `contract`).
- **`General_Important/`**: Catches structured, dense textual documents (line count $\ge 6$ or character count $\ge 150$) that do not match casual patterns.

### B. Trash Documents
- **`Memes_and_Social/`**: Matches social media engagement tokens (`meme`, `reels`, `tiktok`, `story`, `followers`, `like comment share`, `fyp`).
- **`Low_Content_and_Misc/`**: Catches blank screenshots, random partial UI crops, icons, or snippets with $< 15$ characters of readable text.

---

## 4. Key Performance Characteristics
- **Processing Rate:** ~20–35 screenshots per second on Apple Silicon (M1/M2/M3/M4).
- **On-Device Execution:** 100% offline; zero bytes transmitted over the network.
- **Auditability:** Automatically emits a JSON classification manifest (`classification_manifest.json`) recording line count, sample text, confidence rationale, and source-to-target paths.

---

## 5. Usage Command
```bash
# Analyze and sort ~/Desktop into ~/Organized_Screenshots
hrl-god organize

# Specify custom source and target paths:
hrl-god organize --src ~/Downloads --dest ~/My_Organized_Archive
```
