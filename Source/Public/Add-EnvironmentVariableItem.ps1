<#
.SYNOPSIS
Adds an environment variable item for given Name, Item, Scope (default: 'ProcessOnly') and Separator (';') and optional Index.

.PARAMETER Name
Environment variable name

.PARAMETER Item
An item of an environment variable (eg., 'C:\foo' in $env:Path of 'C:\foo;C:\bar')

.PARAMETER Scope
Target scope(s) for the operation. Valid values:
  ProcessOnly             - updates Process scope only [default]
  ProcessAndMachine (pam) - updates both Process and Machine scopes
  ProcessAndUser    (pau) - updates both Process and User scopes
  MachineOnly             - updates Machine scope only
  UserOnly                - updates User scope only

.PARAMETER Separator
Environment variable item separator (eg., ';' in $env:Path of 'C:\foo;C:\bar')

.PARAMETER Index
Item index position (negative values work backwards through collection, -1 being the last item)

.EXAMPLE

Add 'C:\foo' to $env:Path in both Process and Machine scopes (default)

PS> aevi path C:\foo -NoConfirmationRequired

.EXAMPLE

Add 'C:\foo' to $env:Path in both Process and User scopes

PS> aevi path C:\foo -Scope pau -NoConfirmationRequired

.EXAMPLE

Insert 'C:\foo' as first item in $env:Path Machine scope only

PS> Add-EnvironmentVariableItem -Name path -Item C:\foo -Scope MachineOnly -Index 0 -NoConfirmationRequired

.EXAMPLE

Add 'cake' as second item of $env:foo user environment variable

PS> aevi foo cake -Scope UserOnly -Index 1 -Separator '#' -NoConfirmationRequired

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
        [ValidateSet('ProcessAndMachine', 'pam', 'ProcessAndUser', 'pau', 'ProcessOnly', 'MachineOnly', 'UserOnly')]
            [String] $Scope = 'ProcessOnly',
        [Parameter()]
            [String] $Separator = ';',
        [Parameter()]
            [int] $Index,
        [Parameter()]
            [switch] $NoConfirmationRequired
    )
    process {
        $pending = [System.Collections.Generic.List[object]]::new()
        foreach ($target in (Resolve-ScopeParameter $Scope)) {
            $evis = [EnvironmentVariableItems]::new($Name, $target, $Separator)
            $result = if ($PSBoundParameters.ContainsKey('Index')) {
                $evis.AddItem($Item, $Index)
            } else {
                $evis.AddItem($Item)
            }
            if ($result -eq $True) { $pending.Add($evis) }
        }
        if ($pending.Count -gt 0) {
            $message = ($pending | ForEach-Object { GetScopeWhatIf $_ }) -join ''
            if (ConfirmAction -Message $message -NoConfirmationRequired:$NoConfirmationRequired) {
                foreach ($evis in $pending) {
                    $evis.SetEnvironmentVariable($evis.Name, $evis.ToString(), $evis.Scope)
                    $evis
                }
            }
        }
    }
}
