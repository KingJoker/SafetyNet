#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; COMPILER DIRECTIVES
; ==============================================================================
; Make sure 'Paused.ico' AND 'Main.ico' are in the script folder before compiling!
;@Ahk2Exe-SetMainIcon Main.ico
;@Ahk2Exe-AddResource Paused.ico, 206

; ==============================================================================
; SAFETY NET v17 - Crash Proof Resources
; ==============================================================================

; CONFIGURATION
PanicHotkey   := "^F12"
ToggleHotkey  := "^!m"
PauseHotkey   := "^!p"
IniPath       := A_ScriptDir . "\SafetyNet.ini"

; DEFAULTS
DefaultApps   := "chrome.exe,msedge.exe,firefox.exe,notepad++.exe"
DefaultSize   := 10000

; STATE
Global TextBuffer := ""   
Global IsPaused := false
Global TargetProcesses := []
Global MaxBufferSize := DefaultSize

; TRAY MENU
A_TrayMenu.Delete()
A_TrayMenu.Add("Dump Buffer", DumpBuffer)
A_TrayMenu.Add("Clear Buffer", ClearBuffer)
A_TrayMenu.Add("Open Script Folder", OpenScriptDir)
A_TrayMenu.Add()
A_TrayMenu.Add("Pause Collection", TogglePause)
A_TrayMenu.Add("Toggle Monitor for App", ToggleAppMonitor)
A_TrayMenu.Add()
A_TrayMenu.Add("Reload Settings (INI)", LoadConfig)
A_TrayMenu.Add("View Monitored Apps", ShowMonitoredApps)
A_TrayMenu.Add("Exit", (*) => ExitApp())

; ==============================================================================
; INITIALIZATION
; ==============================================================================
LoadConfig()

; ==============================================================================
; INPUT HOOK
; ==============================================================================
ih := InputHook("V")
ih.OnChar := OnCharReceived
ih.Start()

OnCharReceived(ih, char) {
    Global TextBuffer
    if (IsPaused || !IsTargetWindowActive())
        return

    TextBuffer .= char
    if (StrLen(TextBuffer) > MaxBufferSize)
        TextBuffer := SubStr(TextBuffer, -MaxBufferSize)
}

; ==============================================================================
; LOGIC
; ==============================================================================
LoadConfig(*) {
    Global MaxBufferSize, TargetProcesses, TextBuffer

    MaxBufferSize := IniRead(IniPath, "Config", "BufferSize", DefaultSize)
    IniWrite(MaxBufferSize, IniPath, "Config", "BufferSize")

    SavedApps := IniRead(IniPath, "Config", "Apps", "")
    if (SavedApps = "") {
        SavedApps := DefaultApps
        IniWrite(SavedApps, IniPath, "Config", "Apps")
    }
    
    TargetProcesses := []
    Loop Parse, SavedApps, ","
        TargetProcesses.Push(A_LoopField)

    if (StrLen(TextBuffer) > MaxBufferSize)
        TextBuffer := SubStr(TextBuffer, -MaxBufferSize)

    Notify("Settings Reloaded")
}

SaveAppsConfig() {
    csv := ""
    for proc in TargetProcesses
        csv .= proc . ","
    IniWrite(RTrim(csv, ","), IniPath, "Config", "Apps")
}

OpenScriptDir(*) {
    Run(A_ScriptDir)
}

TogglePause(*) {
    Global IsPaused := !IsPaused
    if IsPaused {
        A_TrayMenu.Check("Pause Collection")
        
        if A_IsCompiled {
            try {
                ; Try to load the embedded 'Dimmed Banana' (ID 206)
                TraySetIcon(A_ScriptFullPath, -206)
            } catch {
                ; If the compiler failed to pack it, use Red Stop Sign (Fallback)
                TraySetIcon("shell32.dll", 110)
            }
        } else {
            ; Development Mode
            if FileExist("Paused.ico")
                TraySetIcon("Paused.ico")
            else
                TraySetIcon("shell32.dll", 110)
        }
            
        Notify("SafetyNet PAUSED")
    } else {
        ; Restore Main Icon (The Glowing One)
        TraySetIcon("*") 
        A_TrayMenu.UnCheck("Pause Collection")
        Notify("SafetyNet RESUMED")
    }
}

ClearBuffer(*) {
    Global TextBuffer := ""
    Notify("Buffer Cleared")
}

ToggleAppMonitor(*) {
    try {
        currentProcess := WinGetProcessName("A")
        
        for index, proc in TargetProcesses {
            if (proc = currentProcess) {
                TargetProcesses.RemoveAt(index)
                SaveAppsConfig()
                Notify("STOPPED Monitoring: " . currentProcess)
                return
            }
        }
        
        TargetProcesses.Push(currentProcess)
        SaveAppsConfig()
        Notify("STARTED Monitoring: " . currentProcess)
    }
}

IsTargetWindowActive() {
    try {
        activeProcess := WinGetProcessName("A")
        for proc in TargetProcesses {
            if (activeProcess = proc)
                return true
        }
    }
    return false
}

ShowMonitoredApps(*) {
    appList := ""
    for proc in TargetProcesses
        appList .= proc . "`n"
    MsgBox("Buffer Size: " . MaxBufferSize . "`n`nMonitoring:`n" . appList, "SafetyNet", "Iconi")
}

DumpBuffer(*) {
    Global TextBuffer
    if (TextBuffer = "") {
        Notify("Buffer is empty")
        return
    }

    timestamp := FormatTime(A_Now, "yyyy-MM-dd_HH-mm-ss")
    filename := A_ScriptDir . "\Recovered_" . timestamp . ".txt"
    
    try {
        FileAppend(TextBuffer, filename)
        MsgBox("Saved: " . filename, "SafetyNet", "Iconi")
        TextBuffer := "" 
    } catch as err {
        MsgBox("Error: " . err.Message, "SafetyNet", "IconX")
    }
}

Notify(msg) {
    ToolTip(msg)
    SetTimer () => ToolTip(), -2000
}

Hotkey(PanicHotkey, DumpBuffer)
Hotkey(ToggleHotkey, ToggleAppMonitor)
Hotkey(PauseHotkey, TogglePause)