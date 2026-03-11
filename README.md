# EnvironmentVariableItems

> Add, remove, and inspect items in Windows environment variables — instantly, in your current shell, without restarting.

## Why this module?

There are Windows environment variables such as `$env:Path` which are semicolon-delimited lists and trying to update items within them just isn't easy.  Built-in tools are available but difficult to find.  Typing commands directly into a shell isn't much fun either.  Try this in your favourite copilot, for example; "Which framework and command to update window path environment variable?"  If you know what you're doing you could do something like;

```powershell
$addToPath = "C:\MyTool"
$scope = "Process"
$path = [System.Environment]::GetEnvironmentVariable(
    "PATH",
    [System.EnvironmentVariableTarget]::$scope
)
[System.Environment]::SetEnvironmentVariable(
    "PATH",
    $path + ";$addToPath",
    [System.EnvironmentVariableTarget]::$scope
)

```
and then what about the registry?  

This module simplifies the process. One command adds (or removes) an item and applies it immediately to your session and or registry if required. 

```powershell
# Add C:\MyTool to Path and Machine
Add-EnvironmentVariableItem Path C:\MyTool -Scope ProcessAndMachine
```

```powershell
# or shorthand
aevi path C:\MyTool -sc pam

# or if you know what you're doing
aevi path C:\MyTool -sc pam -noc
sevis path

```

There's also the option to insert an item by item index, useful when you need a particular order for your environment variable items.

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
Script     2.3.0    EnvironmentVariableItems  {Add-EnvironmentVariableItem, Get-EnvironmentVariableItems, ...}
```

## Quick Start

```powershell
sevis path                        # inspect all Path scopes (Machine, User, Process)
aevi path C:\MyTool               # add to current session (Process, default)
aevi path C:\MyTool -Scope pam    # add to session AND persist to Machine registry
revi path C:\OldTool              # remove from current session
```

## Scope

All cmdlets accept a `-Scope` parameter controlling which environment store(s) are read or written.

| Value | Alias | Description |
|-------|-------|-------------|
| `Process` | | Current session only — no elevation needed **[default]** |
| `ProcessAndMachine` | `pam` | Session + Machine registry (requires elevation) |
| `ProcessAndUser` | `pau` | Session + User registry |
| `Machine` | | Machine registry only (requires elevation) |
| `User` | | User registry only |

**Why `Process` is the default:** it's safe, immediate, and requires no elevation. If you restart your shell, the change is gone — which is exactly what you want when exploring. When you're ready to persist, add `-Scope pam` or `-Scope pau`.

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
PS> sevis path -Scope Machine

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
PS> aevi foo cake -Scope User -Index 1 -Separator '#'
```

### Remove-EnvironmentVariableItem (`revi`)

Removes by value or by index.

```powershell
# Remove by value
PS> revi path C:\OldTool

# Remove last item
PS> revi path -Index -1

# Remove from User scope by index
PS> revi path -Index 2 -Scope User
```

### Get-EnvironmentVariableItems (`gevis`)

Returns `EnvironmentVariableItems` objects — useful for scripting and piping.

```powershell
PS> gevis path -Scope Process

Name      : Path
Scope     : Process
Separator : ;
Value     : C:\Program Files\PowerShell\7;C:\WINDOWS\system32;C:\MyTool
Items     : {C:\Program Files\PowerShell\7, C:\WINDOWS\system32, C:\MyTool}

# Both Process and Machine
PS> gevis path -Scope pam
```

## What's New

### v2.3.0
Scope names simplified back to their original values: `MachineOnly` → `Machine`, `UserOnly` → `User`, `ProcessOnly` → `Process`.

> **Breaking change** for anyone on v2.1.0–v2.2.x using `MachineOnly`, `UserOnly`, or `ProcessOnly` in scripts — update those to `Machine`, `User`, `Process`.

### v2.2.2
Multi-scope confirmation prompt overhauled: all pending changes are now shown together — with `[Process]` / `[Machine]` / `[User]` labels — before a single confirm/cancel prompt, rather than prompting once per scope.

### v2.2.0
Reverted default `-Scope` from `ProcessAndMachine` back to `Process` — the safer, non-destructive default. Use `-Scope pam` or `-Scope pau` to explicitly opt in to multi-scope persistence.

### v2.1.0
**Multi-scope support** — a single command can now update multiple scopes simultaneously:

```powershell
# Before: two commands required
aevi path C:\foo -Scope Process
aevi path C:\foo -Scope Machine

# After: one command
aevi path C:\foo -Scope pam
```

> **Breaking change:** `-Scope Machine`, `-Scope User`, and `-Scope Process` were renamed to `MachineOnly`, `UserOnly`, `ProcessOnly` in v2.1.0, then simplified back to `Machine`, `User`, `Process` in v2.3.0.

## Contributors

- [Mike Flynn](https://github.com/a1publishing) — author
- [Claude Sonnet 4.6](https://claude.ai) (Anthropic) — v2.0.0: `-NoConfirmationRequired` parameter; v2.2.0: default scope revert + README overhaul

[MIT License (c) 2021](../master/LICENSE) · [a1publishing.com](https://www.a1publishing.com)
