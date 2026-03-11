#Region '.\_PrefixCode.ps1' -1

# Code in here will be prepended to top of the psm1-file.
#EndRegion '.\_PrefixCode.ps1' 2
#Region '.\Classes\EnvironmentVariableItems.ps1' -1

class EnvironmentVariableItems {

    ### Class variables

    [ValidatePattern("^[^=]+$")] [String] $Name;
    [System.EnvironmentVariableTarget] $Scope;
    [String] $Separator;
    [String] $Value;
    [System.Collections.ArrayList] $Items;

    ### Hidden variables

    hidden $defaultSeparator = ';'
    hidden $defaultScope = [System.EnvironmentVariableTarget]::Process

    ### Constructors

    # Name
    EnvironmentVariableItems(
        [String] $Name
    ) {
        $this.Init($Name, $this.defaultScope, $this.defaultSeparator)
    } 

    # Name, Scope
    EnvironmentVariableItems(
        [String] $Name, 
        [System.EnvironmentVariableTarget] $Scope
    ) {
        $this.Init($Name, $Scope, $this.defaultSeparator)
    } 

    # Name, Separator
    EnvironmentVariableItems(
        [String] $Name, 
        [String] $Separator
    ) {
        $this.Init($Name, $this.defaultScope, $Separator)
    } 

    # Name, Scope, Separator
    EnvironmentVariableItems(
            [String] $Name, 
            [System.EnvironmentVariableTarget] $Scope,
            [String] $Separator
    ) {
        $this.Init($Name, $Scope, $Separator)
    }

    ### Methods 
    
    ### Getter & setter methods

    # Name
    [String] GetName() {
        return $this.Name
    }

    [void] SetName(
        [String] $Name
    ) {
        $this.Name = $Name
    }

    # Scope
    [String] GetScope() {
        return $this.Scope
    }

    [void] SetScope(
        [System.EnvironmentVariableTarget] $Scope
    ) {
        $this.Scope = $Scope
    }

    # Separator
    [String] GetSeparator() {
        return $this.Separator
    }

    [void] SetSeparator(
        [String] $Separator
    ) {
        $this.Separator = $Separator
    }

    # Value
    [String] GetValue() {
        return $this.Value
    }

    [String] GetValue(
        [String] $Name,
        [System.EnvironmentVariableTarget] $Scope
    ) {
        $this.SetValue($Name, $Scope)
        return $this.Value
    }

    [void] SetValue(
        [String] $Value
    ) {
        $this.Value = $Value
    }

    [void] SetValue(
        [String] $Name,
        [System.EnvironmentVariableTarget] $Scope
    ) {
        $this.Value = $this.GetEnvironmentVariable($Name, $Scope)
    }

    # Items
    [System.Collections.ArrayList] GetItems() {
        return $this.Items
    }

    [void] SetItems(
        [String] $Name,
        [System.EnvironmentVariableTarget] $Scope,
        [String] $Separator
    ) {
        # tidy (trim) local copy of value
        $val = $this.GetValue($Name, $Scope)
        if ($val) {$val = $val.Trim($Separator)}

        $this.Items = [System.Collections.ArrayList] @()
        if ($val) {
            $this.Items = $val -split $Separator
        }
    }

    ### Hidden methods

    hidden [bool] AddItem(
        [String] $Item
    ) {
        $this.GetItems().add($Item)
        return $True
    }

    hidden [bool] AddItem(
        [String] $Item,        
        [int] $Index
    ) {
        # Add 1 to items count reflecting length after addition
        $items_ = $this.GetItems()
        if (($ind = $this.GetPositiveIndex($Index, $items_.count + 1)) -is [int]) {
            $items_.insert($ind, $Item)
            return $True
        }                    
        return $False
    }

    hidden [String] GetEnvironmentVariable($Name, $Scope) {
        return [Environment]::GetEnvironmentVariable($Name, $Scope)
    }

    hidden [System.Collections.ArrayList] GetItemsForScope($Scope) {
        if ($Scope -eq $this.GetScope()) {
            return $this.GetItems()
        } else {
            return [EnvironmentVariableItems]::new($this.Name, $Scope, $this.Separator).GetItems()
        }
    }


    # check index is within range and return (as positive value if required)
    hidden [int] GetPositiveIndex(
        [int] $Index,
        [int] $ItemsCount
    ) {
        if ($Index -lt $ItemsCount -and $(-($Index) -le $ItemsCount)) {
            if ($Index -lt 0) {
                return $ItemsCount + $Index
            } else {
                return $Index
            }
        } else {
            Write-Host
            Write-Host  -ForegroundColor Red "Index $Index is out of range"
            Write-Host
        }
        return $False
    }

    hidden [void] Init(
            [String] $Name, 
            [System.EnvironmentVariableTarget] $Scope,
            [String] $Separator
    ) {
        #$this.Name = $Name
        $this.SetName($Name)
        $this.SetScope($Scope)
        $this.SetSeparator($Separator)
        $this.SetValue($this.Name, $this.Scope)
        $this.SetItems($this.Name, $this.Scope, $this.Separator)
    }

    hidden [bool] RemoveItemByIndex(
            [int] $Index
    ) {
        $items_ = $this.GetItems()
        if (($ind = $this.GetPositiveIndex($Index, $items_.count)) -is [int]) {
            $items_.RemoveAt($ind)
            return $True
        }                    
        return $False
    }
    
    hidden [bool] RemoveItemByItem(
            [String] $Item
    ) {
        $items_ = $this.GetItems()
        if (($items_.IndexOf($Item)) -ge 0) {
            $items_.Remove($Item)
            return $True
        }
        Write-Host
        Write-Host  -ForegroundColor Red "Item $Item not found"
        Write-Host
        return $False
    }

    hidden [void] SetEnvironmentVariable(
            [String] $Name,        
            [String] $Value,        
            [System.EnvironmentVariableTarget] $Scope = [System.EnvironmentVariableTarget]::Process
    ) {
        [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
        $this.SetValue($Value)
    }


    ### Public methods

    [void] ShowIndex(
            [System.EnvironmentVariableTarget] $Scope
    ) {
        $items_ = $this.GetItemsForScope($Scope)
        $this.ShowIndex($Scope, $items_)
    }

    [void] ShowIndex(
        [System.EnvironmentVariableTarget] $Scope,
        [System.Collections.ArrayList] $items_
    ) {
        Write-Host $Scope
        for ($i = 0; $i -lt $items_.count; $i++) {
            Write-Host -ForegroundColor Blue "${i}: $($items_[$i].ToString())"
        }
        Write-Host
    }

    [void] ShowIndexes() {
        Write-Host 
        $this.ShowIndex([System.EnvironmentVariableTarget]::Machine)
        $this.ShowIndex([System.EnvironmentVariableTarget]::User)
        $this.ShowIndex([System.EnvironmentVariableTarget]::Process)
        Write-Host
        Write-Host
    }

    [String] ToString() { 
        $s = ''
        $items_ = $this.GetItems()
        for ($i = 0; $i -lt $items_.count; $i++) {
            if ($i) { $s += $this.Separator}
            $s += $items_[$i]
        }
        return $s
    }
}
#EndRegion '.\Classes\EnvironmentVariableItems.ps1' 274
#Region '.\Private\ConfirmAction.ps1' -1

function ConfirmAction {
    param (
        [String] $Message,
        [switch] $NoConfirmationRequired
    )
    Write-Host $Message
    if ($NoConfirmationRequired) { return $True }
    $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
        [System.Management.Automation.Host.ChoiceDescription]::new('&Yes'),
        [System.Management.Automation.Host.ChoiceDescription]::new('&No')
    )
    $Host.UI.PromptForChoice('Confirm', 'Are you sure you want to perform this action?', $choices, 0) -eq 0
}
#EndRegion '.\Private\ConfirmAction.ps1' 14
#Region '.\Private\GetWhatIf.ps1' -1

function GetScopeWhatIf {
    param ($evis)
    @"

    [$($evis.Scope)]
    Current Value:
        $($evis.Value)
    New Value:
        $($evis.ToString())
"@
}

#EndRegion '.\Private\GetWhatIf.ps1' 13
#Region '.\Private\Resolve-ScopeParameter.ps1' -1

function Resolve-ScopeParameter {
    param (
        [Parameter(Mandatory)]
        [string] $Scope
    )
    switch ($Scope) {
        { $_ -in 'ProcessAndMachine', 'pam' } {
            return @([System.EnvironmentVariableTarget]::Process, [System.EnvironmentVariableTarget]::Machine)
        }
        { $_ -in 'ProcessAndUser', 'pau' } {
            return @([System.EnvironmentVariableTarget]::Process, [System.EnvironmentVariableTarget]::User)
        }
        'MachineOnly' { return @([System.EnvironmentVariableTarget]::Machine) }
        'UserOnly'    { return @([System.EnvironmentVariableTarget]::User) }
        default       { return @([System.EnvironmentVariableTarget]::Process) }
    }
}
#EndRegion '.\Private\Resolve-ScopeParameter.ps1' 18
#Region '.\Public\Add-EnvironmentVariableItem.ps1' -1

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
#EndRegion '.\Public\Add-EnvironmentVariableItem.ps1' 102
#Region '.\Public\Get-EnvironmentVariableItems.ps1' -1


<#
.SYNOPSIS
Gets EnvironmentVariableItems PSCustomObject(s) for a given Name, Scope (default: 'ProcessOnly') and Separator (';').
Returns one object per resolved scope.

.PARAMETER Name
Environment variable name

.PARAMETER Scope
Target scope(s) for the operation. Valid values:
  ProcessOnly             - returns object for Process scope only [default]
  ProcessAndMachine (pam) - returns objects for both Process and Machine scopes
  ProcessAndUser    (pau) - returns objects for both Process and User scopes
  MachineOnly             - returns object for Machine scope only
  UserOnly                - returns object for User scope only

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

PS> Get-EnvironmentVariableItems -Name Path -Scope UserOnly

Name      : Path
Scope     : User
Separator : ;
Value     : C:\foo;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps
Items     : {C:\foo, C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps}

.EXAMPLE

Get user $env:foo EnvironmentVariableItems PSCustomObject

PS> gevis foo -Scope UserOnly -Separator '#'

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
        [ValidateSet('ProcessAndMachine', 'pam', 'ProcessAndUser', 'pau', 'ProcessOnly', 'MachineOnly', 'UserOnly')]
            [String] $Scope = 'ProcessOnly',
        [Parameter()]
            [String] $Separator = ';'
    )
    process {
        foreach ($target in (Resolve-ScopeParameter $Scope)) {
            [EnvironmentVariableItems]::new($Name, $target, $Separator)
        }
    }
}
#EndRegion '.\Public\Get-EnvironmentVariableItems.ps1' 87
#Region '.\Public\Remove-EnvironmentVariableItem.ps1' -1

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
#EndRegion '.\Public\Remove-EnvironmentVariableItem.ps1' 101
#Region '.\Public\Show-EnvironmentVariableItems.ps1' -1

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
  ProcessOnly             - shows Process scope only
  MachineOnly             - shows Machine scope only
  UserOnly                - shows User scope only

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

PS> Show-EnvironmentVariableItems PSModulePath -Scope MachineOnly

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
        [ValidateSet('ProcessAndMachine', 'pam', 'ProcessAndUser', 'pau', 'ProcessOnly', 'MachineOnly', 'UserOnly')]
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
#EndRegion '.\Public\Show-EnvironmentVariableItems.ps1' 98
