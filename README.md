# Mac Keyboard Shortcuts on Windows 11 with AutoHotkey v2 (and a real Cmd+Tab fix)

**An AutoHotkey v2 script to remap a Windows keyboard** so it behaves like a Mac, written for the current AutoHotkey, not the abandoned v1. It brings the **essential macOS key combinations to Windows**, and it solves the one thing every older script gets wrong on Windows 11: Cmd+Tab opens the sticky task view after the second press instead of cycling. This one keeps cycling until you let go.

**With this AutoHotKey script, you can use most macOS style shortcuts** on a Windows 10 or Windows 11 laptop or desktop: Cmd+Tab to switch windows, Cmd+Q to quit, Cmd+Arrow to jump to the start or end of a line, Option+Backspace to delete a word, and more.

What sets it apart from the v1 gists floating around:

- **AutoHotkey v2 only.** Function-style hotkeys, `try` for error handling, no v1 commands. It will not run under v1, by design.
- **Windows 11 Cmd+Tab that actually cycles.** The script holds Alt across repeated Tab presses and never leaks Ctrl+Alt+Tab, so the sticky switcher never appears.
- **The whole laptop setup, documented.** SharpKeys registry swap, the Lenovo ThinkPad Fn/Ctrl swap, startup folder, admin relaunch. Not just a script, the full recipe.
- **Reversible.** Suspend the hotkeys from the tray or undo the SharpKeys swap, and you are back on a stock PC keyboard.

I built it for one reason: to **allow me to use Mac-style keyboard shortcuts in Windows** without retraining twenty years of muscle memory. It was written and tested on a Lenovo ThinkPad P16s, but the mappings work on any keyboard once the modifier keys are in the right places.

> **In short:** [SharpKeys](https://github.com/randyrants/sharpkeys) moves the modifier keys at the registry level, and this **AutoHotkey mac keyboard on Windows** script rewrites the shortcuts on top of that. Together they give you **Windows with a Mac keyboard** feel on ordinary PC hardware, or put a real **Mac keyboard on Windows** with its **macOS keys on Windows** doing what you expect. It is an **AutoHotKey V2 Script for Mac Users on Windows**, not a v1 leftover.

---

## Contents

- [What this script does](#what-this-script-does)
- [Steps to Set Up AHK v2 for a Mac Keyboard](#steps-to-set-up-ahk-v2-for-a-mac-keyboard)
- [Remap the Windows key (and the other modifiers)](#remap-the-windows-key-and-the-other-modifiers)
- [About the AHK v2 Key Mappings](#about-the-ahk-v2-key-mappings)
- [Full key map](#full-key-map)
- [Switchable between Mac Keyboard and PC Keyboard](#switchable-between-mac-keyboard-and-pc-keyboard)
- [FAQ](#faq)
- [Compatibility](#compatibility)
- [Changelog](#changelog)

---

## What this script does

- **Flawless Cmd+Tab.** Bypasses Windows 11's sticky Alt-Tab task view for native, Mac-like window switching that keeps cycling while you hold the key.
- **Mac cursor navigation.** Cmd+Arrows for Home, End, and top or bottom of document. Option+Backspace deletes the previous word. Cmd+Backspace deletes to the start of the line.
- **System shortcuts.** Cmd+Q to quit, Cmd+M to minimize, Cmd+Shift+Z to redo.
- **Browser tabs.** Physical Ctrl+Tab still cycles tabs, exactly as on a Mac.
- **Failsafes.** An emergency modifier reset (Cmd+Esc) releases every stuck key, and the click-and-hold shortcut times out after two seconds.
- **Works in elevated apps.** The script relaunches itself as administrator once, so the shortcuts also work inside Task Manager and admin terminals.

Roughly **20 keyboard shortcuts are remapped** by the script, on top of **3 physical modifier keys** moved with SharpKeys and the Lenovo keyboard settings.

---

## Steps to Set Up AHK v2 for a Mac Keyboard

These are the exact steps I used. Expect about fifteen minutes, including one reboot.

1. **Install AutoHotkey v2.** Download it from [autohotkey.com](https://www.autohotkey.com/) and pick the v2 installer. The script starts with `#Requires AutoHotkey v2.0` and refuses to run under v1.
2. **Remap the Windows key with SharpKeys.** Install [SharpKeys](https://github.com/randyrants/sharpkeys), add a mapping that swaps **Left Ctrl ↔ Left Windows**, click *Write to Registry*, and reboot. This is what puts a "Cmd" key next to the spacebar. Details in the next section.
3. **Swap Fn and Ctrl (Lenovo only).** On a ThinkPad the leftmost key is Fn. Open Lenovo Vantage (Device → Input & Accessories → Fn and Ctrl key swap) or the BIOS Config → Keyboard/Mouse page and enable the swap. If you do not have a Lenovo, skip this step.
4. **Download the script.** Clone this repository or download `macify.ahk`.
5. **Run it.** Double-click `macify.ahk`. Approve the one-time UAC prompt so the remaps also work in elevated apps. Declining the prompt still works, but only in normal apps.
6. **Start it at login.** Press Win+R, enter `shell:startup`, and drop a shortcut to `macify.ahk` in that folder.
7. **Test it.** Hold the key next to your spacebar and tap Tab. The window switcher should open and keep cycling until you let go.

---

## Remap the Windows key (and the other modifiers)

A Mac keyboard puts Cmd next to the spacebar. A PC keyboard puts Ctrl in the corner and Win next to Alt. AutoHotkey can remap shortcuts, but it cannot move a modifier key reliably at the system level, so the modifiers are moved first with **SharpKeys**, a free tool that writes the Windows *Scancode Map* registry key. Because the swap lives in the registry, it survives reboots and applies before any app loads.

My ThinkPad P16s layout, left to right, after all the swaps:

| Physical key (printed) | What Windows now sees | Mac role  | AHK prefix |
| ---------------------- | --------------------- | --------- | ---------- |
| Fn                     | Ctrl (Lenovo swap)    | Control   | `^`        |
| Ctrl                   | Win (SharpKeys)       | Win / Fn  | `<#`       |
| Win                    | Ctrl (SharpKeys)      | **Cmd**   | `<^`       |
| Alt                    | Alt (unchanged)       | Option    | `<!`       |

Only the left side is swapped. The right-hand Ctrl, Alt and Win keys keep their PC meaning, which is useful as an escape hatch.

**Using an actual Apple keyboard?** You can plug a Mac keyboard into Windows and use the same script. On my Mac I use [Raycast](https://www.raycast.com/), whose *Hyper Key* setting turns the right ⌘ key into Ctrl+Alt+Shift+Cmd pressed together, for app-launching shortcuts. That Hyper key lives in Raycast on the Mac side and is not part of this script; on Windows the right ⌘ stays a plain Win key.

---

## About the AHK v2 Key Mappings

The script is organised into short sections, each with a comment block explaining the intent. Every hotkey uses AutoHotkey v2 syntax (function-style hotkeys, `Send` with quoted strings, no v1 commands).

- **Emergency reset.** `<^Esc` sends an explicit *up* for every modifier. If something ever feels stuck, press Cmd+Esc.
- **Window switching.** `*<^Tab` sends Alt Down + Tab, and a separate `~*LCtrl Up` handler releases Alt when you let go of Cmd. The `*` wildcard matters: after the first Tab, Alt is held artificially, and without the wildcard the hotkey stops matching and Windows sees raw Ctrl+Alt+Tab, which opens the sticky task view. The release handler only releases Alt that the script pressed itself, so a physically held Option key is left alone.
- **Tab cycling.** `$<#Tab` turns the logical Win key (physical Ctrl) plus Tab back into Ctrl+Tab, so browser tab switching stays where your fingers expect it.
- **System and app navigation.** Cmd+M minimizes, Cmd+Q closes, Cmd+Shift+Z sends Ctrl+Y for redo. Cmd+Option+Win+D right-clicks at the mouse position and Cmd+Option+Win+F holds the left mouse button for up to two seconds.
- **Cursor navigation.** Cmd+Left/Right become Home/End, Cmd+Up/Down become Ctrl+Home/End, and the Shift variants extend the selection. Cmd+Backspace deletes to the start of the line.
- **Option modifier.** Option+Backspace sends Ctrl+Backspace to delete the previous word.
- **Housekeeping.** `#SingleInstance Force` stops duplicate copies, `A_MenuMaskKey` is set so the Start menu never pops open from a stray Win press, and the admin relaunch is wrapped in `try` so a declined UAC prompt does not crash the script.

Two commented-out hotkeys map Cmd+Backtick to Ctrl+Tab for people who prefer the macOS "cycle windows of the same app" gesture. Uncomment them in `macify.ahk` if you want that.

---

## Full key map

Keys below are the **printed labels on the laptop**, after the SharpKeys and Lenovo swaps.

| Press (physical keys)           | Result                                        |
| ------------------------------- | --------------------------------------------- |
| Win + Tab / Win + Shift + Tab   | Window switcher, keeps cycling while held     |
| Ctrl + Tab / Ctrl + Shift + Tab | Next / previous browser or app tab            |
| Win + Q                         | Close active window                           |
| Win + M                         | Minimize active window                        |
| Win + Shift + Z                 | Redo                                          |
| Win + Left / Right              | Home / End                                    |
| Win + Shift + Left / Right      | Select to start / end of line                 |
| Win + Up / Down                 | Top / bottom of document                      |
| Win + Shift + Up / Down         | Select to top / bottom of document            |
| Win + Backspace                 | Delete to start of line                       |
| Alt + Backspace                 | Delete previous word                          |
| Win + Alt + Ctrl + D            | Right-click at the mouse position             |
| Win + Alt + Ctrl + F            | Left-click and hold (2-second safety timeout) |
| Win + Esc                       | Emergency reset: release every modifier       |

That is 20 shortcuts in total, plus the 2 optional backtick mappings.

---

## Switchable between Mac Keyboard and PC Keyboard

You do not have to commit. The two layers can be switched independently:

- **Pause the Mac shortcuts.** Right-click the green AutoHotkey icon in the system tray and choose *Suspend Hotkeys*. The keyboard instantly behaves like a normal PC keyboard with the modifiers still swapped. Choose it again to resume, or *Exit* to stop the script entirely.
- **Undo the modifier swap.** Open SharpKeys, delete the Left Ctrl ↔ Left Windows mapping, click *Write to Registry*, and reboot. Your keyboard is back to stock.
- **Use both.** Keep the script running and the swap in place on your laptop, and plug in a standard PC keyboard when you want the Windows layout; the right-hand modifier keys are never remapped, so Ctrl+C and Ctrl+V on the right side always work.

---

## FAQ

### Can I use my Mac keyboard on Windows?

Yes. Windows recognises any Apple keyboard over USB or Bluetooth. Out of the box the ⌘ key acts as the Windows key, so Cmd+C does nothing useful. Run this script and the ⌘ key next to the spacebar drives the Mac-style shortcuts above. You do not need SharpKeys on a real Apple keyboard, because ⌘ is already in the right place; just change the `<^` prefixes in the script to `<#` if you skip the registry swap.

### Can I use a Mac keyboard layout on Windows?

Yes, in two senses. The physical layout (Cmd next to the spacebar, Option beside it) is recreated with SharpKeys. The shortcut layout (Cmd+Q, Cmd+Arrow, Option+Backspace and friends) is recreated by this AutoHotkey v2 script. Neither piece touches your typing layout, so letters, numbers and punctuation stay exactly as before.

### How can I use Mac keys on a Windows keyboard?

Follow the [setup steps](#steps-to-set-up-ahk-v2-for-a-mac-keyboard): install AutoHotkey v2, swap Left Ctrl and Left Win with SharpKeys, reboot, and run `macify.ahk`. The whole process takes about fifteen minutes and is fully reversible.

### Which macOS keys on Windows does it cover?

The ones you reach for all day: Cmd+Tab, Cmd+Q, Cmd+M, Cmd+Shift+Z, Cmd+Arrow and Cmd+Shift+Arrow for line and document navigation, Cmd+Backspace, and Option+Backspace. Copy, paste, undo, save and the rest already work because the swapped Cmd key sends Ctrl. See the [full key map](#full-key-map).

### Does this replace Microsoft PowerToys Keyboard Manager?

PowerToys can remap individual keys and shortcuts, but it cannot hold Alt down across repeated Tab presses, which is why Cmd+Tab never feels right there. AutoHotkey can, and it also runs inside elevated apps once it has admin rights.

### Why AutoHotkey v2 instead of v1?

AutoHotkey v1 is no longer developed. v2 has cleaner function syntax, proper error handling (`try`), and explicit `Send` behaviour. This script is written for v2 only and will not run under v1.

### Something got stuck. What now?

Press Win+Esc (physical keys) to release every modifier. If the tray icon has vanished, run `macify.ahk` again; `#SingleInstance Force` replaces any stale copy.

---

## Compatibility

Tested on the hardware and software below. Anything newer should work the same, because the script only uses core AutoHotkey v2 features and a standard registry scancode map.

**Windows**

- Windows 11 (22H2 through 25H2), where the Cmd+Tab fix for the sticky task view matters most
- Windows 10 (21H2 and 22H2)
- Not supported: Windows 7 or 8, because AutoHotkey v2 requires Windows 10 or later

**AutoHotkey**

- AutoHotkey v2.0 and v2.1. The script declares `#Requires AutoHotkey v2.0` and will not run under v1.1.

**Keyboards**

- Lenovo ThinkPad P16s built-in keyboard (primary test machine), and other ThinkPads with the Fn/Ctrl swap
- Standard 104-key PC keyboards with SharpKeys moving Left Ctrl and Left Win
- Apple Magic Keyboard and other Mac keyboards over USB or Bluetooth, with ⌘ already next to the spacebar

**macOS shortcuts emulated**

The shortcut behaviour matches the keyboard conventions that have been stable from OS X through macOS Ventura, Sonoma, Sequoia and Tahoe. If you are coming from any of those releases, your Cmd+Tab, Cmd+Q, Cmd+Arrow and Option+Backspace habits carry over unchanged.

**Tools used**

- [SharpKeys](https://github.com/randyrants/sharpkeys) 3.9 for the registry-level modifier swap
- Lenovo Vantage or ThinkPad BIOS for the Fn ↔ Ctrl swap
- [Raycast](https://www.raycast.com/) on the Mac side for the right-⌘ Hyper key (optional, Mac only)

---

## Changelog

**2026-10-22**

- Repo description and topics set for GitHub search; README leads with the v2 and Windows 11 Cmd+Tab angle.
- README rewritten with setup steps, modifier table, mapping descriptions, FAQ, compatibility list, Raycast Hyper key note and the Lenovo Fn/Ctrl swap.
- Renamed `script-26-05-29` to `macify.ahk` so Windows opens it with AutoHotkey.
- Fixed Cmd+Tab: after the first Tab, Alt is held artificially and the old `<^Tab` hotkey stopped matching. The second Tab reached Windows as raw Ctrl+Alt+Tab and opened the sticky switcher. The hotkey now uses the `*` wildcard prefix and handles Shift in the handler, so every Tab press cycles.
- The LCtrl-release handler only releases Alt the script pressed itself, so a physically held Option key is no longer released under you.
- The run-as-admin relaunch is wrapped in `try`, so declining the UAC prompt no longer crashes the script.

**2026-05-29**

- First public version of the script.

---

## License

GPL-3.0. See [LICENSE](LICENSE).
