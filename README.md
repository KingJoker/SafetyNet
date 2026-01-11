# SafetyNet

**SafetyNet** is a lightweight, privacy-focused "rolling buffer" utility designed to save you from the "accidental refresh" disaster. 

Unlike traditional keyloggers which act as spyware (logging everything to disk constantly), SafetyNet sits silently in RAM, maintaining a temporary buffer of your last ~10,000 keystrokes for specific applications only. It writes to disk **only** when you explicitly trigger a "Panic Dump."

![Status](https://img.shields.io/badge/Status-Active-success)
![Platform](https://img.shields.io/badge/Platform-Windows-blue)
![Language](https://img.shields.io/badge/Language-AutoHotkey_v2-green)

## 🚀 Features

* **🛡️ RAM-Only Buffer:** Keystrokes are held in a volatile ring buffer. Nothing is written to your hard drive until you ask for it.
* **🎯 Target-Specific:** Monitors only the applications you whitelist (e.g., Chrome, Firefox). Ignored apps (like your Password Manager or Terminal) are never logged.
* **👻 Stealth & Lightweight:** Runs silently in the system tray (~3MB RAM).
* **🔌 Hot-Swappable Config:** Add/remove monitored apps on the fly.
* **🔋 Battery Friendly:** Optimized to run efficiently on laptops.

## 🛠️ Installation

### Prerequisites
* **Windows 10/11**
* **AutoHotkey v2** (Required only if compiling, not for running the final `.exe`)

### Step 1: Download
1. Download already compiled release [here]!(https://github.com/KingJoker/SafetyNet/releases)

### Step 1b: Compile (Optional)
1.  Open **Ahk2Exe** (AutoHotkey Compiler).
2.  **Source:** Select `SafetyNet.ahk`.
3.  **Base File:** Ensure you select a **v2.0** base file (e.g., `AutoHotkey64.exe`).
4.  Click **Convert**.
5.  Place the resulting `SafetyNet.exe` into a permanent folder (e.g., `C:\Tools\SafetyNet`).

### Step 2: Whitelist (Crucial)
Because SafetyNet uses a global `InputHook` to capture keystrokes, **Windows Defender** and other AV solutions may flag it as a "Keylogger" or "Trojan."
* **Action:** Add a **Folder Exclusion** in your Antivirus for the directory where `SafetyNet.exe` resides.

### Step 3: Install Service
Run the provided PowerShell script to register SafetyNet as a high-privilege Scheduled Task (runs at login).
1.  Right-click `Install_SafetyNet.ps1`.
2.  Select **Run with PowerShell**.

## 🎮 Usage

SafetyNet runs in the background. Look for the green **H** icon in your System Tray.

### Hotkeys

| Hotkey | Function | Description |
| :--- | :--- | :--- |
| **`Ctrl` + `F12`** | **Panic Dump** | Saves the current buffer to a timestamped `.txt` file in the script directory. |
| **`Ctrl` + `Alt` + `M`** | **Toggle Monitor** | Adds or removes the *active* window from the monitoring whitelist. |
| **`Ctrl` + `Alt` + `P`** | **Pause/Resume** | Temporarily stops all logging. (Tray icon indicates status). |

### Tray Menu
Right-click the tray icon to:
* **Clear Buffer:** Wipe current memory without saving.
* **Reload Settings:** Force reload the `.ini` file (useful if you edited buffer size manually).
* **Open Script Folder:** Quickly access your logs and config.

## ⚙️ Configuration

A `SafetyNet.ini` file is generated automatically in the script directory.

```ini
[Config]
; Maximum characters to keep in RAM. Oldest keys are dropped first.
BufferSize=10000

; Comma-separated list of process names to monitor.
Apps=chrome.exe,msedge.exe,firefox.exe,notepad++.exe
```

## 🗑️ Uninstallation

To cleanly remove the Scheduled Task and stop the process:
1.  Right-click `Uninstall_SafetyNet.ps1`.
2.  Select **Run with PowerShell**.
3.  Follow the prompt to optionally delete configuration and log files.

## ⚠️ Disclaimer

**This tool captures keystrokes.**
While designed for data recovery and personal use, it utilizes technologies identical to malicious keyloggers.
* **Use responsibly.** Only install this on machines you own or have explicit permission to monitor.
* **Security:** Ensure the folder containing `SafetyNet.exe` is secure. Anyone with access to this machine can trigger a "Dump" to see what you have recently typed in monitored windows.

## License


MIT License. Feel free to modify and distribute.
