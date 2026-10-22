#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook()
InstallMouseHook()

; SendMode defaults to "Input" in v2, but we declare it explicitly for clarity.
SendMode "Input"
A_MenuMaskKey := "vkFF"  ; Complete protection against Start Menu popups

; Ensure administrative privileges for elevated apps (Task Manager, CMD, etc.)
; Wrapped in try so a declined UAC prompt leaves the script running unelevated
; instead of crashing with an error dialog.
if (!A_IsAdmin) {
    try {
        Run('*RunAs "' A_ScriptFullPath '"')
        ExitApp()
    }
}

; ============================================================
; HARDWARE & REGISTRY ASSUMPTIONS (LEFT SIDE ONLY)
; Lenovo P16s Physical Layout: Fn, Win, Alt, Ctrl, Space
; SharpKeys Registry Swap: LCtrl <-> LWin
;
; Logical Mapping Result:
; - Position 2 (Physical Win)  -> Sends LCtrl [AHK: <^] -> "Cmd" (Thumb-adjacent LCtrl)
; - Position 3 (Physical Alt)  -> Sends LAlt  [AHK: <!] -> "Option"
; - Position 4 (Physical Ctrl) -> Sends LWin  [AHK: <#] -> "Win"
; ============================================================

; ============================================================
; EMERGENCY RESET
; Pressing Left Ctrl + Esc (Physical Win + Esc) releases all modifiers
; ============================================================
<^Esc:: {
    Send "{LCtrl up}{RCtrl up}{LAlt up}{RAlt up}{LShift up}{RShift up}{LWin up}{RWin up}"
    MsgBox "Keyboard states explicitly cleared!", "System", "T1"
}

; ============================================================
; WINDOW SWITCHING (Physical Win + Tab -> Native Alt-Tab)
; Maps your thumb-adjacent LCtrl + Tab to native window switching.
;
; WHY THE "*" PREFIX:
; After the first Tab, Alt is held down artificially by Send. A plain "<^Tab"
; hotkey only fires when NO extra modifiers are down, so the second Tab press
; did not match the hotkey at all. Windows then saw raw Ctrl+Alt+Tab, which
; opens the sticky task-view switcher instead of cycling. "*" makes the hotkey
; fire even while Alt (or Shift) is already down, so every Tab press cycles.
;
; Send (non-Blind) temporarily releases the physically held LCtrl before
; sending Tab, so Windows only ever sees Alt+Tab, never Ctrl+Alt+Tab.
; ============================================================
*<^Tab:: {
    if GetKeyState("Shift", "P")
        Send "{Alt Down}+{Tab}"
    else
        Send "{Alt Down}{Tab}"
}

; Releases Alt when you release the physical LCtrl key, even if Shift is still
; held down. Only releases Alt that WE put down artificially: if the user is
; physically holding Option (LAlt) for another chord, leave it alone.
~*LCtrl Up:: {
    if (GetKeyState("Alt") && !GetKeyState("Alt", "P")) {
        Send "{Alt Up}"
    }
}

; ============================================================
; TAB CYCLING (Physical Ctrl + Tab -> Cycles browser/app tabs)
; Maps Logical LWin (Physical Ctrl) + Tab to cycle browser tabs.
; The "$" prefix prevents infinite loops.
; ============================================================
$<#Tab::Send "^{Tab}"
$+<#Tab::Send "^+{Tab}"

; ============================================================
; BACKTICK TAB CYCLING (Physical Win + ` -> Cycles browser/app tabs)
; Maps your thumb-adjacent LCtrl + Backtick to send Ctrl+Tab.
; ============================================================
; $<^SC029::Send "^{Tab}"
; $+<^SC029::Send "^+{Tab}"

; ============================================================
; SYSTEM & APPLICATION NAVIGATION (Thumb-LCtrl Modifier: <^)
; ============================================================

; Cmd + M -> Minimize active window
<^m::WinMinimize "A"

; Cmd + Q -> Close active window
<^q::WinClose "A"

; Cmd + Shift + Z -> Redo (Sends Ctrl+Y safely)
+<^z::Send "^{y}"

; Cmd + Option + Win + D -> Right-click at mouse position
<^<!<#d::Click "Right"

; Cmd + Option + Win + F -> Left-click and hold
; Includes a 2-second safety timeout to prevent permanent mouse lock
<^<!<#f:: {
    Click "Down"
    KeyWait "f", "T2"
    Click "Up"
}

; ============================================================
; CURSOR NAVIGATION OVERRIDES (Thumb-LCtrl Modifier: <^)
; ============================================================
; Cmd + Left / Right -> Home / End
<^Left::Send  "{Home}"
<^Right::Send "{End}"

; Cmd + Shift + Left / Right -> Shift + Home / End
+<^Left::Send  "+{Home}"
+<^Right::Send "+{End}"

; Cmd + Up / Down -> Ctrl + Home / End (top/bottom of document)
<^Up::Send   "^{Home}"
<^Down::Send "^{End}"

; Cmd + Shift + Up / Down -> Ctrl + Shift + Home / End
+<^Up::Send   "^+{Home}"
+<^Down::Send "^+{End}"

; Cmd + Backspace -> Delete to start of line
<^Backspace::Send "+{Home}{Backspace}"

; ============================================================
; OPTION MODIFIER NAVIGATION (Physical Alt Modifier: <!)
; ============================================================
; Option + Backspace -> Delete previous word
<!Backspace::Send "^{Backspace}"
