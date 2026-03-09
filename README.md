# EnvironmentVariableItems

## Description
Powershell module with commands to easily add or remove items from 'collection type' Windows environment variables.  For example, adding 'C:\foo' to $env:Path.

## Installation

a) install from PowershellGallery
```
PS> 
Install-Module EnvironmentVariableItems
```

or b) save from PowershellGallery and install manually, eg.;
```
PS> 
Save-Module -Name EnvironmentVariableItems -Repository PSGallery -Path C:\tmp
Copy-Item -r C:\tmp\EnvironmentVariableItems $HOME\Documents\PowerShell\Modules

```

or c) download from GitHub (https://github.com/a1publishing/Powershell_Module_EnvironmentVariableItems/archive/master.zip) and install manually, eg.;
```
PS>
Expand-Archive $HOME\Downloads\Powershell_Module_EnvironmentVariableItems-master.zip C:\tmp
Copy-Item -r C:\tmp\Powershell_Module_EnvironmentVariableItems-master\bin\EnvironmentVariableItems $HOME\Documents\PowerShell\Modules\
```

### Check for successful installation
```
PS> 
Get-Module EnvironmentVariableItems -ListAvailable

    Directory: C:\Users\michaelf\Documents\PowerShell\Modules

ModuleType Version    PreRelease Name                                PSEdition ExportedCommands
---------- -------    ---------- ----                                --------- ----------------
Script     2.1.0                 EnvironmentVariableItems            Desk

```

## What's New in v2.1.0

**Multi-scope support** — a single command can now update multiple scopes simultaneously, eliminating the need to run the same command twice.

```
# Before: two commands required
aevi path C:\foo -Scope Process
aevi path C:\foo -Scope Machine

# After: one command
aevi path C:\foo                  # default scope is now ProcessAndMachine
aevi path C:\foo -Scope pam       # explicit alias
```

### New `-Scope` values

| Value | Alias | Description |
|-------|-------|-------------|
| `ProcessAndMachine` | `pam` | Updates Process **and** Machine scopes **[default]** |
| `ProcessAndUser` | `pau` | Updates Process **and** User scopes |
| `ProcessOnly` | | Updates Process scope only |
| `MachineOnly` | | Updates Machine scope only |
| `UserOnly` | | Updates User scope only |

> **Note:** The old `-Scope Machine`, `-Scope User`, and `-Scope Process` values are no longer valid.
> Migrate to `MachineOnly`, `UserOnly`, and `ProcessOnly` respectively.

## Usage

### Cmdlets
```
PS> Get-Command *-EnvironmentVariableItem*

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Add-EnvironmentVariableItem                        2.1.0      environmentvariableitems
Function        Get-EnvironmentVariableItems                       2.1.0      environmentvariableitems
Function        Remove-EnvironmentVariableItem                     2.1.0      environmentvariableitems
Function        Show-EnvironmentVariableItems                      2.1.0      environmentvariableitems

```

### Get-EnvironmentVariableItems
```
PS> Get-Help Get-EnvironmentVariableItems

NAME
    Get-EnvironmentVariableItems

SYNOPSIS
    Gets EnvironmentVariableItems object(s) for a given Name, Scope (default: 'ProcessAndMachine') and Separator (';').


SYNTAX
    Get-EnvironmentVariableItems [-Name] <String> [[-Scope] {ProcessAndMachine | pam | ProcessAndUser | pau | ProcessOnly | MachineOnly | UserOnly}] [[-Separator] <String>] [<CommonParameters>]
..    
```

#### Examples
```
PS> Get-Help Get-EnvironmentVariableItems -Examples
..
    -------------------------- EXAMPLE 1 --------------------------

    PS > Get $env:Path EnvironmentVariableItems for Process and Machine scopes (default)

    PS> Get-EnvironmentVariableItems -Name Path

    Name      : Path
    Scope     : Process
    Separator : ;
    Value     : C:\Program Files\PowerShell\7;C:\WINDOWS\system32
    Items     : {C:\Program Files\PowerShell\7, C:\WINDOWS\system32}

    Name      : Path
    Scope     : Machine
    Separator : ;
    Value     : C:\WINDOWS\system32;C:\WINDOWS
    Items     : {C:\WINDOWS\system32, C:\WINDOWS}
```

```
    -------------------------- EXAMPLE 2 --------------------------

    PS > Get user $env:Path EnvironmentVariableItems object

    PS> Get-EnvironmentVariableItems -Name Path -Scope UserOnly

    Name      : Path
    Scope     : User
    Separator : ;
    Value     : C:\foo;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps
    Items     : {C:\foo, C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps}
```

```
    -------------------------- EXAMPLE 3 --------------------------

    PS > Get user $env:foo EnvironmentVariableItems object

    PS> gevis foo -Scope UserOnly -Separator '#'

    Name      : foo
    Scope     : User
    Separator : #
    Value     : foo#cake#bar#cup
    Items     : {foo, cake, bar, cup}
```

### Show-EnvironmentVariableItems
```
Get-Help Show-EnvironmentVariableItems

NAME
    Show-EnvironmentVariableItems

SYNOPSIS
    Show indexed list of environment variable items for given Name, Scope and Separator (default: ';').  Omitting Scope parameter shows
    list for all, ie., Machine, User and Process.


SYNTAX
    Show-EnvironmentVariableItems [-Name] <String> [[-Scope] {ProcessAndMachine | pam | ProcessAndUser | pau | ProcessOnly | MachineOnly | UserOnly}] [[-Separator] <String>] [<CommonParameters>]
..
```

#### Examples
```
PS> Get-Help Show-EnvironmentVariableItems -Examples
..
    -------------------------- EXAMPLE 1 --------------------------

    PS > Show $env:PSModulePath items

    PS> Show-EnvironmentVariableItems PSModulePath

    Machine
    0: C:\Program Files\WindowsPowerShell\Modules
    1: C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
    2: N:\lib\pow\mod

    User
    0: H:\lib\pow\mod

    Process
    0: C:\Users\michaelf\Documents\PowerShell\Modules
    1: C:\Program Files\PowerShell\Modules
    2: c:\program files\powershell\7\Modules
    3: H:\lib\pow\mod
    4: C:\Program Files\WindowsPowerShell\Modules
    5: C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
    6: N:\lib\pow\mod
```
```
    -------------------------- EXAMPLE 2 --------------------------

    PS > Show $env:PSModulePath items for Process and Machine scopes

    PS> Show-EnvironmentVariableItems PSModulePath -Scope pam

    Machine
    0: C:\Program Files\WindowsPowerShell\Modules
    1: C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
    2: N:\lib\pow\mod

    Process
    0: C:\Users\michaelf\Documents\PowerShell\Modules
    1: C:\Program Files\PowerShell\Modules
```
```
    -------------------------- EXAMPLE 3 --------------------------

    PS > Show $env:PSModulePath items for Machine scope only

    PS> Show-EnvironmentVariableItems PSModulePath -Scope MachineOnly

    Machine
    0: C:\Program Files\WindowsPowerShell\Modules
    1: C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
    2: N:\lib\pow\mod
```

### Add-EnvironmentVariableItem
```
PS> Get-Help Add-EnvironmentVariableItem

NAME
    Add-EnvironmentVariableItem

SYNOPSIS
    Adds an environment variable item for given Name, Item, Scope (default: 'ProcessAndMachine') and Separator (';') and optional Index.


SYNTAX
    Add-EnvironmentVariableItem [-Name] <String> [-Item] <String> [-Scope {ProcessAndMachine | pam | ProcessAndUser | pau | ProcessOnly | MachineOnly | UserOnly}] [-Separator <String>] [-Index
    <Int32>] [-NoConfirmationRequired] [<CommonParameters>]
..
```

#### Examples
```
PS> Get-Help Add-EnvironmentVariableItem -Examples
..
    -------------------------- EXAMPLE 1 --------------------------

    PS > Add 'C:\foo' to $env:Path user environment variable

    PS> Add-EnvironmentVariableItem -Name path -Item C:\foo -Scope UserOnly -NoConfirmationRequired
    What if:
        Current Value:
            C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
        New Value:
            C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin;C:\foo
```

```
    -------------------------- EXAMPLE 2 --------------------------

    PS > Insert 'C:\foo' as first item in $env:Path user environment variable

    PS> Add-EnvironmentVariableItem -Name path -Item C:\foo -Scope UserOnly -Index 0 -NoConfirmationRequired
    What if:
        Current Value:
            C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
        New Value:
            C:\foo;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
```

```
    -------------------------- EXAMPLE 3 --------------------------

    PS > Insert 'C:\foo' as second last item in $env:Path process environment variable

    PS> Add-EnvironmentVariableItem -Name path -Item C:\foo -Scope ProcessOnly -Index -2 -NoConfirmationRequired
    What if:
        Current Value:
            C:\Program Files\PowerShell\7;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files (x86)\ATI Technologies\ATI.ACE\Core-Static;C:\ProgramData\chocolatey\bin;C:\Program Files\PowerShell\7\;C:\Program Files\Git\cmd;C:\Program Files\Microsoft VS Code\bin;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps
        New Value:
            C:\Program Files\PowerShell\7;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files (x86)\ATI Technologies\ATI.ACE\Core-Static;C:\ProgramData\chocolatey\bin;C:\Program Files\PowerShell\7\;C:\Program Files\Git\cmd;C:\Program Files\Microsoft VS Code\bin;C:\foo;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps
```

```
    -------------------------- EXAMPLE 4 --------------------------

    PS > Add 'cake' as second item of $env:foo user environment variable

    PS> aevi foo cake -Scope UserOnly -Index 1 -Separator '#'

        Current Value:
            foo#bar#cup
        New Value:
            foo#cake#bar#cup

    Confirm
    Are you sure you want to perform this action?
    [Y] Yes  [N] No  [?]: y

    Name      : foo
    Scope     : User
    Separator : #
    Value     : foo#cake#bar#cup
    Items     : {foo, cake, bar, cup}

    -------------------------- EXAMPLE 5 --------------------------

    PS > Add 'C:\foo' to $env:Path in both Process and Machine scopes (default)

    PS> aevi path C:\foo -NoConfirmationRequired

    Name      : Path
    Scope     : Process
    Separator : ;
    Value     : C:\Program Files\PowerShell\7;C:\WINDOWS\system32;C:\foo
    Items     : {C:\Program Files\PowerShell\7, C:\WINDOWS\system32, C:\foo}

    Name      : Path
    Scope     : Machine
    Separator : ;
    Value     : C:\WINDOWS\system32;C:\WINDOWS;C:\foo
    Items     : {C:\WINDOWS\system32, C:\WINDOWS, C:\foo}
```

### Remove-EnvironmentVariableItem
```
PS> Get-Help Remove-EnvironmentVariableItem

NAME
    Remove-EnvironmentVariableItem

SYNOPSIS
    Removes an environment variable item for a given Name, Item or Index, Scope (default: 'ProcessAndMachine') and Separator (';').


SYNTAX
    Remove-EnvironmentVariableItem [-Name] <String> [-Item] <String> [-Scope {ProcessAndMachine | pam | ProcessAndUser | pau | ProcessOnly | MachineOnly | UserOnly}] [-Separator <String>]
    [-NoConfirmationRequired] [<CommonParameters>]

    Remove-EnvironmentVariableItem [-Name] <String> [-Index] <Int32> [-Scope {ProcessAndMachine | pam | ProcessAndUser | pau | ProcessOnly | MachineOnly | UserOnly}] [-Separator <String>]
    [-NoConfirmationRequired] [<CommonParameters>]
..    
```

#### Examples
```
PS> Get-Help Remove-EnvironmentVariableItem -Examples
..
    -------------------------- EXAMPLE 1 --------------------------

    PS > Remove 'C:\foo' from $env:Path user environment variable

    PS> Remove-EnvironmentVariableItem -Name path -Item 'C:\foo' -Scope UserOnly -NoConfirmationRequired
    What if:
        Current Value:
            C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\foo;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
        New Value:
            C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
```

```
    -------------------------- EXAMPLE 2 --------------------------

    PS > Remove last item from $env:Path user environment variable

    PS> Remove-EnvironmentVariableItem -Name path -Scope UserOnly -Index -1 -NoConfirmationRequired
    What if:
        Current Value:
            C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
        New Value:
            C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps
```

```
    -------------------------- EXAMPLE 3 --------------------------

    PS > Remove second item from $env:foo user environment variable

    PS> sevis foo

    Machine
    0: mat#mop

    User
    0: foo#cake#bar#cup

    Process
    0: foo#cake#bar#cup

    PS> sevis foo -Scope UserOnly -Separator '#'

    User
    0: foo
    1: cake
    2: bar
    3: cup

    PS> revi foo -Index 1 -Scope UserOnly -Separator '#'


        Current Value:
            foo#cake#bar#cup
        New Value:
            foo#bar#cup

    Confirm
    Are you sure you want to perform this action?
    [Y] Yes  [N] No  [?]: y

    Name      : foo
    Scope     : User
    Separator : #
    Value     : foo#bar#cup
    Items     : {foo, bar, cup}

    PS> sevis foo

    Machine
    0: mat#mop

    User
    0: foo#bar#cup

    Process
    0: foo#cake#bar#cup

    PS> $env:foo
    foo#cake#bar#cup

    PS> [Environment]::GetEnvironmentVariable('foo', 'User')
    foo#bar#cup

    -------------------------- EXAMPLE 4 --------------------------

    PS > Remove 'C:\foo' from $env:Path in both Process and Machine scopes (default)

    PS> revi path C:\foo -NoConfirmationRequired

    Name      : Path
    Scope     : Process
    Separator : ;
    Value     : C:\Program Files\PowerShell\7;C:\WINDOWS\system32
    Items     : {C:\Program Files\PowerShell\7, C:\WINDOWS\system32}

    Name      : Path
    Scope     : Machine
    Separator : ;
    Value     : C:\WINDOWS\system32;C:\WINDOWS
    Items     : {C:\WINDOWS\system32, C:\WINDOWS}
```

> **Note:** When using `-Index` with a multi-scope default (`ProcessAndMachine`), index positions may differ
> between scopes — the same index may refer to different items in Process vs Machine. When removing by
> index, specify a single scope (e.g., `-Scope MachineOnly`) to avoid unintended removals.


## Contributors

- [Mike Flynn](https://github.com/a1publishing) — author
- [Claude Sonnet 4.6](https://claude.ai) (Anthropic) — v2.0.0: `-NoConfirmationRequired` parameter

[MIT License (c) 2021](../master/LICENSE) [a1publishing.com](https://www.a1publishing.com)