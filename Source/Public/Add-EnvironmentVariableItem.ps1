<#
.SYNOPSIS
Adds an environment variable item for given Name, Item, Scope (default; 'Process') and Separator (';') and optional Index.

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

Add 'C:\tmp' to $env:Path user environment variable

PS> Add-EnvironmentVariableItem -Name path -Item C:\tmp -Scope User -WhatIf
What if:
    Current Value:
        C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
    New Value:
        C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin;C:\tmp

.EXAMPLE

Insert 'C:\tmp' as first item in $env:Path user environment variable

PS> Add-EnvironmentVariableItem -Name path -Item C:\tmp -Scope User -Index 0 -WhatIf
What if:
    Current Value:
        C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin
    New Value:
        C:\tmp;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps;C:\Users\michaelf\AppData\Local\Programs\Microsoft VS Code\bin

.EXAMPLE

Insert 'C:\tmp' as second last item in $env:Path process environment variable

PS> Add-EnvironmentVariableItem -Name path -Item C:\tmp -Scope Process -Index -2 -WhatIf
What if:
    Current Value:
        C:\Program Files\PowerShell\7;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files (x86)\ATI Technologies\ATI.ACE\Core-Static;C:\ProgramData\chocolatey\bin;C:\Program Files\PowerShell\7\;C:\Program Files\Git\cmd;C:\Program Files\Microsoft VS Code\bin;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps
    New Value:
        C:\Program Files\PowerShell\7;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files (x86)\ATI Technologies\ATI.ACE\Core-Static;C:\ProgramData\chocolatey\bin;C:\Program Files\PowerShell\7\;C:\Program Files\Git\cmd;C:\Program Files\Microsoft VS Code\bin;C:\tmp;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps

.EXAMPLE

PS > Add 'cake' as second item of $env:foo user environment variable

PS> aevi foo cake -sc user -in 1 -se '#' -wh
What if:
    Current Value:
        foo#bar#cup
    New Value:
        foo#cake#bar#cup

.INPUTS

.OUTPUTS
EnvironmentVariableItems PSCustomObject

#>
function Add-EnvironmentVariableItem {
    [CmdletBinding()]
    [Alias('aevi')]
    param (
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [ValidatePattern("^[^=]+$")]
            [String] $Name,
        [Parameter(
            Mandatory,
            Position = 1
        )]
            [String] $Item,
        [Parameter()]
            [System.EnvironmentVariableTarget] $Scope = [System.EnvironmentVariableTarget]::Process,
        [Parameter()]
            [String] $Separator = ';',
        [Parameter()]
            [int] $Index,
        [Parameter()]
            [switch] $NoConfirmationRequired
    )
    process {
        $evis = [EnvironmentVariableItems]::new($Name, $Scope, $Separator)

        if ($PSBoundParameters.ContainsKey('Index')) {
            $result = $evis.AddItem($Item, $Index)
        } else {
            $result = $evis.AddItem($Item)
        }

        if ($result -eq $True) {
            if (ConfirmAction -Message (GetWhatIf) -NoConfirmationRequired:$NoConfirmationRequired) {
                $evis.SetEnvironmentVariable($evis.Name, $evis.ToString(), $evis.Scope)
                $evis
            }
        } else {
            return
        }
    }
}
