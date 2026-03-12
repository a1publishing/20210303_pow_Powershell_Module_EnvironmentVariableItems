# EnvironmentVariableItems
> Show, add, remove or get Windows environment variable items.

## Why this module?

There are some Windows environment variables, such as `$env:Path`, which are semicolon-delimited lists and trying to update items within them isn't always easy.  Built-in tools are available, for example at;
```powershell
Windows 11 -> Settings -> System -> About -> Advanced System Settings -> Advanced -> Environment Variables -> User or System variables -> Path
```
 and even then you're left wondering whether you then need a restart or not? Typing commands directly into a shell isn't much fun either.  Try this in your favourite copilot, for example; "which framework and command to update windows path environment variable?"  If you know what you're doing you could do something like;

```powershell
$addToPath = "C:\MyTool"
$scope = "Machine"
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
and then same again with `$scope = "Process"` when you don't want to close and reopen your shell.  

This module simplifies the process wrapping the .NET framework commands with easy to use and remember Powershell cmdlets.  One command is all that's needed to simultaneously update the registry and currently running process, for example, shell or IDE.

```powershell
# Add C:\MyTool to Path 
Add-EnvironmentVariableItem -Name Path -Item C:\MyTool -Scope ProcessAndMachine
```
or

```powershell
# Add C:\MyTool to Path (shorthand)
aevi path C:\MyTool -sc pam

# Add C:\MyTool to Path (if you know what you're doing)
aevi path C:\MyTool -sc pam -noc
sevis path
```

There's also options to insert an item by index; useful when you need a particular order for your environment variable items or to remove by index; easier for items like long path strings.

I wonder whether Microsoft deliberately make it difficult to update your path variable with   inexperienced operators in mind?  Maybe so but at the expense of those who do know what they're doing! Hence EnvironmentVariableItems..

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
# inspect all Path scopes (Machine, User, Process)
Show-EnvironmentVariableItems -Name Path    
# (sevis path)

# add to current session (Process, default)
Add-EnvironmentVariableItem -Name Path -Item C:\MyTool
# (aevi path C:\MyTool)

# add to session AND persist to Machine registry
Add-EnvironmentVariableItem -Name Path -Item C:\MyTool -Scope ProcessAndMachine -NoConfirmationRequired
# (aevi path C:\MyTool -Scope pam -noc)

# remove from current session
Remove-EnvironmentVariableItem -Name Path C:\OldTool -Scope ProcessAndMachine
# (revi path C:\OldTool -sc pam)

# add environment variable
Add-EnvironmentVariableItem -Name trifle -Item 'sponge#custard#jelly#cream#topping'
# (aevi trifle 'sponge#custard#jelly#cream#topping')

# add an item by index (to environment variable with custom separator)
Add-EnvironmentVariableItem -Name trifle -Item fruit -Index 1 -Separator '#'
# (aevi trifle fruit -in 1 -se '#')

# remove an item by index 
Remove-EnvironmentVariableItem -Name trifle -Index -3 -Separator '#'
# (revi trifle -in -3 -se '#')

# remove environment variable
Remove-EnvironmentVariableItem -Name trifle -Index 0
# (revi trifle -in 0)
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

### v2.3.1
When `-NoConfirmationRequired` is set, the current/new value block is no longer shown — only the result object is output.

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
