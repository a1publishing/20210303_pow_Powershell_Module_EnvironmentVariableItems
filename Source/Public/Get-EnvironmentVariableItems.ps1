
<#
.SYNOPSIS
Gets EnvironmentVariableItems PSCustomObject(s) for a given Name, Scope (default: 'Process') and Separator (';').
Returns one object per resolved scope.

.PARAMETER Name
Environment variable name

.PARAMETER Scope
Target scope(s) for the operation. Valid values:
  Process             - returns object for Process scope only [default]
  ProcessAndMachine (pam) - returns objects for both Process and Machine scopes
  ProcessAndUser    (pau) - returns objects for both Process and User scopes
  Machine             - returns object for Machine scope only
  User                - returns object for User scope only

.PARAMETER Separator
Environment variable item separator (eg., ';' in $env:Path of 'C:\foo;C:\bar')

.EXAMPLE

Get $env:Path EnvironmentVariableItems for Process and Machine scopes (default)

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

.EXAMPLE

Get user $env:Path EnvironmentVariableItems PSCustomObject

PS> Get-EnvironmentVariableItems -Name Path -Scope User

Name      : Path
Scope     : User
Separator : ;
Value     : C:\foo;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps
Items     : {C:\foo, C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps}

.EXAMPLE

Get user $env:foo EnvironmentVariableItems PSCustomObject

PS> gevis foo -Scope User -Separator '#'

Name      : foo
Scope     : User
Separator : #
Value     : foo#cake#bar#cup
Items     : {foo, cake, bar, cup}

.INPUTS

.OUTPUTS
EnvironmentVariableItems PSCustomObject
#>
function Get-EnvironmentVariableItems {
    [CmdletBinding()]
    [Alias('gevis')]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern("^[^=]+$")]
            [String] $Name,
        [Parameter()]
        [ValidateSet('ProcessAndMachine', 'pam', 'ProcessAndUser', 'pau', 'Process', 'Machine', 'User')]
            [String] $Scope = 'Process',
        [Parameter()]
            [String] $Separator = ';'
    )
    process {
        foreach ($target in (Resolve-ScopeParameter $Scope)) {
            [EnvironmentVariableItems]::new($Name, $target, $Separator)
        }
    }
}
