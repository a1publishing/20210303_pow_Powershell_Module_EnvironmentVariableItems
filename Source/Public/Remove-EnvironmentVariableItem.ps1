<#
.SYNOPSIS
Removes an environment variable item for given Name, Item or Index, and Scope (default; 'Process') and Separator (';').

.PARAMETER Name
Environment variable name

.PARAMETER Item
An item of an environment variable (eg., 'C:\foo' in $env:Path of 'C:\foo;C:\bar')

.PARAMETER Scope
Environment variable scope  (.NET enum System.EnvironmentVariableTarget)

.PARAMETER Separator
Environment variable item separator (eg., ';' in $env:Path of 'C:\foo;C:\bar')

.PARAMETER Index
Item index position (negative values work backwards through collection,-1 being the last item)

.EXAMPLE

Remove 'C:\tmp' from $env:Path user environment variable

PS> Remove-EnvironmentVariableItem -Name path -Item 'C:\tmp' -Scope User -WhatIf

What if:
    Current Value:
        C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\tmp;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
    New Value:
        C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin

.EXAMPLE

Remove last item from $env:Path user environment variable

PS> Remove-EnvironmentVariableItem -Name path -Scope User -Index -1 -WhatIf

What if:

    Current Value:
        C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
    New Value:
        C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps

.EXAMPLE

Remove second item from $env:foo user environment variable

PS> sevis foo

Machine
0: mat#mop

User
0: foo#cake#bar#cup

Process
0: foo#cake#bar#cup

PS> sevis foo -sc user -se '#'

User
0: foo
1: cake
2: bar
3: cup

PS> revi foo -in 1 -sc user -se '#'

Confirm
Are you sure you want to perform this action?

    Current Value:
        foo#cake#bar#cup
    New Value:
        foo#bar#cup
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y

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

.INPUTS

.OUTPUTS
EnvironmentVariableItems PSCustomObject
#>
function Remove-EnvironmentVariableItem {
    [CmdletBinding()]
    [Alias('revi')]
    param (
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [ValidatePattern("^[^=]+$")]
            [String] $Name,
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByItem',
            Position = 1
        )]
            [String] $Item,
        [Parameter(
            ParameterSetName = 'ByIndex',
            Position = 1,
            Mandatory
        )] [int] $Index,
        [Parameter()]
            [System.EnvironmentVariableTarget] $Scope = [System.EnvironmentVariableTarget]::Process,
        [Parameter()]
            [String] $Separator = ";",
        [Parameter()]
            [switch] $NoConfirmationRequired

    )
    process {
        $evis = [EnvironmentVariableItems]::new($Name, $Scope, $Separator)

        if ($PSCmdlet.ParameterSetName -eq 'ByIndex') {
            $result = $evis.RemoveItemByIndex($Index) -ne $False
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByItem') {
            $result = $evis.RemoveItemByItem($Item) -ne $False
        }

        if ($result -ne $False) {
            if (ConfirmAction -Message (GetWhatIf) -NoConfirmationRequired:$NoConfirmationRequired) {
                $evis.SetEnvironmentVariable($evis.Name, $evis.ToString(), $evis.Scope)
                $evis
            }
        } else {
            return
        }
    }
}