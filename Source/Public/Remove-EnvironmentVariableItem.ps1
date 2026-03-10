<#
.SYNOPSIS
Removes an environment variable item for given Name, Item or Index, Scope (default: 'ProcessOnly') and Separator (';').

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

Remove 'C:\foo' from $env:Path in both Process and Machine scopes (default)

PS> revi path C:\foo -NoConfirmationRequired

.EXAMPLE

Remove 'C:\foo' from $env:Path in User scope only

PS> Remove-EnvironmentVariableItem -Name path -Item 'C:\foo' -Scope UserOnly -NoConfirmationRequired

.EXAMPLE

Remove last item from $env:Path in both Process and User scopes

PS> revi path -Index -1 -Scope pau -NoConfirmationRequired

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
        )]
            [int] $Index,
        [Parameter()]
        [ValidateSet('ProcessAndMachine', 'pam', 'ProcessAndUser', 'pau', 'ProcessOnly', 'MachineOnly', 'UserOnly')]
            [String] $Scope = 'ProcessOnly',
        [Parameter()]
            [String] $Separator = ";",
        [Parameter()]
            [switch] $NoConfirmationRequired
    )
    process {
        $pending = [System.Collections.Generic.List[object]]::new()
        foreach ($target in (Resolve-ScopeParameter $Scope)) {
            $evis = [EnvironmentVariableItems]::new($Name, $target, $Separator)
            $result = if ($PSCmdlet.ParameterSetName -eq 'ByIndex') {
                $evis.RemoveItemByIndex($Index) -ne $False
            } elseif ($PSCmdlet.ParameterSetName -eq 'ByItem') {
                $evis.RemoveItemByItem($Item) -ne $False
            }
            if ($result -ne $False) { $pending.Add($evis) }
        }
        if ($pending.Count -gt 0) {
            $message = ($pending | ForEach-Object { GetScopeWhatIf $_ }) -join "`n"
            if (ConfirmAction -Message $message -NoConfirmationRequired:$NoConfirmationRequired) {
                foreach ($evis in $pending) {
                    $evis.SetEnvironmentVariable($evis.Name, $evis.ToString(), $evis.Scope)
                    $evis
                }
            }
        }
    }
}
