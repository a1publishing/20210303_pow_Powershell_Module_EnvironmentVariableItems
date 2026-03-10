# EnvironmentVariableItems

> Add, remove, and inspect items in Windows environment variables — instantly, in your current shell, without restarting.

## Why this module?

Windows environment variables like `$env:Path` are semicolon-delimited lists — but the built-in tools treat them as opaque strings. Adding a path means copy, paste, edit, save. And if you want it live _right now_, you either restart your shell or write boilerplate to update both the registry and the process environment.

This module solves that. One command adds (or removes) an item and applies it immediately to your session.

```powershell
# Add C:\MyTool to Path — available right now, no restart needed
aevi path C:\MyTool
```

## Installation

```powershell
Install-Module EnvironmentVariableItems
```

Or save and copy manually:
```powershell
Save-Module -Name EnvironmentVariableItems -Repository PSGallery -Path C:\tmp
Copy-Item -Recurse C:\tmp\EnvironmentVariableItems $HOME\Documents\PowerShell\Modules
```

Verify:
```powershell
PS> Get-Module EnvironmentVariableItems -ListAvailable

    Directory: C:\Users\you\Documents\PowerShell\Modules

ModuleType Version  Name                      ExportedCommands
---------- -------  ----                      ----------------
Script     2.2.0    EnvironmentVariableItems  {Add-EnvironmentVariableItem, Get-EnvironmentVariableItems, ...}
```

## Quick Start

```powershell
sevis path                        # inspect all Path scopes (Machine, User, Process)
aevi path C:\MyTool               # add to current session (ProcessOnly, default)
aevi path C:\MyTool -Scope pam    # add to session AND persist to Machine registry
revi path C:\OldTool              # remove from current session
```

## Scope

All cmdlets accept a `-Scope` parameter controlling which environment store(s) are read or written.

| Value | Alias | Description |
|-------|-------|-------------|
| `ProcessOnly` | | Current session only — no elevation needed **[default]** |
| `ProcessAndMachine` | `pam` | Session + Machine registry (requires elevation) |
| `ProcessAndUser` | `pau` | Session + User registry |
| `MachineOnly` | | Machine registry only (requires elevation) |
| `UserOnly` | | User registry only |

**Why `ProcessOnly` is the default:** it's safe, immediate, and requires no elevation. If you restart your shell, the change is gone — which is exactly what you want when exploring. When you're ready to persist, add `-Scope pam` or `-Scope pau`.

## Cmdlets

### Show-EnvironmentVariableItems (`sevis`)

Displays an indexed list of items. Omit `-Scope` to see all three stores at once.

```powershell
# Show all scopes
PS> sevis path

Machine
0: C:\WINDOWS\system32
1: C:\WINDOWS
2: C:\Program Files\Git\cmd

User
0: C:\Users\you\AppData\Local\Microsoft\WindowsApps

Process
0: C:\Program Files\PowerShell\7
1: C:\WINDOWS\system32
...

# Filter to one scope
PS> sevis path -Scope MachineOnly

Machine
0: C:\WINDOWS\system32
1: C:\WINDOWS
2: C:\Program Files\Git\cmd
```

### Add-EnvironmentVariableItem (`aevi`)

Appends an item, or inserts it at a specific index position (negative indices count from the end).

```powershell
# Append to current session
PS> aevi path C:\MyTool

# Insert at position 0 (first)
PS> aevi path C:\MyTool -Index 0

# Insert second-to-last
PS> aevi path C:\MyTool -Index -2

# Persist to Machine as well
PS> aevi path C:\MyTool -Scope pam

# Custom separator (non-Path variable)
PS> aevi foo cake -Scope UserOnly -Index 1 -Separator '#'
```

### Remove-EnvironmentVariableItem (`revi`)

Removes by value or by index.

```powershell
# Remove by value
PS> revi path C:\OldTool

# Remove last item
PS> revi path -Index -1

# Remove from User scope by index
PS> revi path -Index 2 -Scope UserOnly
```

### Get-EnvironmentVariableItems (`gevis`)

Returns `EnvironmentVariableItems` objects — useful for scripting and piping.

```powershell
PS> gevis path -Scope ProcessOnly

Name      : Path
Scope     : Process
Separator : ;
Value     : C:\Program Files\PowerShell\7;C:\WINDOWS\system32;C:\MyTool
Items     : {C:\Program Files\PowerShell\7, C:\WINDOWS\system32, C:\MyTool}

# Both Process and Machine
PS> gevis path -Scope pam
```

## What's New

### v2.2.0
Reverted default `-Scope` from `ProcessAndMachine` back to `ProcessOnly` — the safer, non-destructive default. Use `-Scope pam` or `-Scope pau` to explicitly opt in to multi-scope persistence.

### v2.1.0
**Multi-scope support** — a single command can now update multiple scopes simultaneously:

```powershell
# Before: two commands required
aevi path C:\foo -Scope Process
aevi path C:\foo -Scope Machine

# After: one command
aevi path C:\foo -Scope pam
```

> **Note:** The old `-Scope Machine`, `-Scope User`, and `-Scope Process` values were replaced by `MachineOnly`, `UserOnly`, and `ProcessOnly` in v2.1.0.

## Contributors

- [Mike Flynn](https://github.com/a1publishing) — author
- [Claude Sonnet 4.6](https://claude.ai) (Anthropic) — v2.0.0: `-NoConfirmationRequired` parameter; v2.2.0: default scope revert + README overhaul

[MIT License (c) 2021](../master/LICENSE) · [a1publishing.com](https://www.a1publishing.com)
