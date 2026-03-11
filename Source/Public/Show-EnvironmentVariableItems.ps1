<#
.SYNOPSIS
Shows indexed list of environment variable items for given Name, Scope and Separator (default: ';').
Omitting Scope shows all three scopes (Machine, User, Process).

.PARAMETER Name
Environment variable name

.PARAMETER Scope
Target scope(s) for the operation. Omit to show all three scopes. Valid values:
  ProcessAndMachine (pam) - shows both Process and Machine scopes
  ProcessAndUser    (pau) - shows both Process and User scopes
  Process             - shows Process scope only
  Machine             - shows Machine scope only
  User                - shows User scope only

.PARAMETER Separator
Environment variable item separator (eg., ';' in $env:Path of 'C:\foo;C:\bar')

.EXAMPLE

Show $env:PSModulePath items for all scopes

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

Show $env:PSModulePath items for Process and Machine scopes

PS> Show-EnvironmentVariableItems PSModulePath -Scope pam

Machine
0: C:\Program Files\WindowsPowerShell\Modules
1: C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
2: N:\lib\pow\mod

Process
0: C:\Users\michaelf\Documents\PowerShell\Modules
1: C:\Program Files\PowerShell\Modules

.EXAMPLE

Show $env:PSModulePath items for Machine scope only

PS> Show-EnvironmentVariableItems PSModulePath -Scope Machine

Machine
0: C:\Program Files\WindowsPowerShell\Modules
1: C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
2: N:\lib\pow\mod

#>
function Show-EnvironmentVariableItems {
    [CmdletBinding()]
    [Alias('sevis')]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern("^[^=]+$")]
            [String] $Name,
        [Parameter()]
        [ValidateSet('ProcessAndMachine', 'pam', 'ProcessAndUser', 'pau', 'Process', 'Machine', 'User')]
            [String] $Scope,
        [Parameter()]
            [String] $Separator = ';'
    )
    process {
        if (-not $PSBoundParameters.ContainsKey('Scope')) {
            [EnvironmentVariableItems]::new($Name, $Separator).ShowIndexes()
        } else {
            $targets = Resolve-ScopeParameter $Scope
            $evis = [EnvironmentVariableItems]::new($Name, $targets[0], $Separator)
            Write-Host
            foreach ($target in $targets) {
                $evis.ShowIndex($target)
            }
            Write-Host
            Write-Host
        }
    }
}
