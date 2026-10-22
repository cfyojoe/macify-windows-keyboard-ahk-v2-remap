# **Macify Windows Keyboard (AHK v2)**

This repository contains an AutoHotkey **v2** script (`macify.ahk`) that brings the macOS keyboard experience to Windows. Built for laptops with a Fn, Win, Alt, Ctrl physical layout (like the Lenovo P16s), it works in tandem with a registry-level key swap (via SharpKeys) to emulate Mac modifiers.

> ## **Key Features:**
>
> -   **Flawless Cmd+Tab:** Bypasses Windows 11's sticky Alt-Tab menu for a native Mac-like window switching experience.
>
> -   **Mac Cursor Navigation:** Use Cmd+Arrows for Home/End and Option+Backspace to delete words.
>
> -   **System Shortcuts:** Cmd+Q to quit, Cmd+M to minimize, and Cmd+Shift+Z to redo.
>
> -   **Failsafes:** Includes an emergency modifier reset to prevent "stuck" keys.

---

## Setup

1. Install [AutoHotkey v2](https://www.autohotkey.com/) (v2.0 or later; the script refuses to run under v1).
2. In SharpKeys, swap **Left Ctrl ↔ Left Win** and reboot. After the swap, the physical Win key sends LCtrl ("Cmd"), physical Alt sends LAlt ("Option"), and physical Ctrl sends LWin.
3. Double-click `macify.ahk`. It asks for admin rights once so the remaps also work inside elevated apps (Task Manager, admin terminals). Declining the UAC prompt keeps the script running unelevated.
4. To start it at login, put a shortcut to `macify.ahk` in `shell:startup`.

## Key map

| Press (physical keys)      | Result                              |
| -------------------------- | ----------------------------------- |
| Win + Tab / Win + Shift + Tab | Alt-Tab window switcher, cycles while Win is held |
| Ctrl + Tab / Ctrl + Shift + Tab | Next / previous browser or app tab |
| Win + Q                    | Close active window                 |
| Win + M                    | Minimize active window              |
| Win + Shift + Z            | Redo                                |
| Win + Left / Right         | Home / End                          |
| Win + Up / Down            | Top / bottom of document            |
| Win + Shift + arrows       | Same, with selection                |
| Win + Backspace            | Delete to start of line             |
| Alt + Backspace            | Delete previous word                |
| Win + Alt + Ctrl + D       | Right-click at the mouse position   |
| Win + Alt + Ctrl + F       | Left-click and hold (2 s max)       |
| Win + Esc                  | Emergency reset: release every modifier |

## Changelog

**2026-10-22**

- Renamed `script-26-05-29` to `macify.ahk` so Windows opens it with AutoHotkey.
- Fixed Cmd+Tab: after the first Tab, Alt is held artificially, and the old `<^Tab` hotkey would not fire with an extra modifier down. The second Tab reached Windows as raw Ctrl+Alt+Tab and opened the sticky switcher. The hotkey now uses the `*` wildcard prefix and handles Shift inside the handler, so every Tab press cycles.
- The LCtrl-release handler now only lets go of Alt that the script pressed itself, so a physically held Option key is no longer released under you.
- The run-as-admin relaunch is wrapped in `try`, so declining the UAC prompt no longer crashes the script with an error dialog.
