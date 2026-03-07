<#
.SYNOPSIS
Show indexed list of environment variable items for given Name, Scope and Separator (default: ';').  Omitting Scope parameter shows list for all, ie., Machine, User and Process.

.PARAMETER Name
Environment variable name

.PARAMETER Scope
Environment variable scope  (.NET enum System.EnvironmentVariableTarget)

.PARAMETER Separator
Environment variable item separator (eg., ';' in $env:Path of 'C:\foo;C:\bar')

.EXAMPLE

Show $env:PSModulePath items

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

.EXAMPLE

Show PSModulePath system variable items

PS> Show-EnvironmentVariableItems PSModulePath -Scope Machine

Machine
0: C:\Program Files\WindowsPowerShell\Modules
1: C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
2: N:\lib\pow\mod

.EXAMPLE

Show system, user and process items for $env:TMP environment variable

PS> Show-EnvironmentVariableItems TMP

Machine
0: C:\WINDOWS\TEMP

User
0: C:\Users\michaelf\AppData\Local\Temp

Process
0: C:\Users\michaelf\AppData\Local\Temp
#>
function Show-EnvironmentVariableItems {
    [CmdletBinding()]
    [Alias('sevis')]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern("^[^=]+$")]
            [String] $Name,
        [Parameter()]
            [System.EnvironmentVariableTarget] $Scope,
        [Parameter()]
            [String] $Separator = ';'
    )    
    process {
        if ($null -eq $Scope) {
            [EnvironmentVariableItems]::new($Name, $Separator).ShowIndexes()
        } else {
            [EnvironmentVariableItems]::new($Name, $Scope, $Separator).ShowIndex($Scope)
        }
    }
}
