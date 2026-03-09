#Region '.\_PrefixCode.ps1' 0
# Code in here will be prepended to top of the psm1-file.
#EndRegion '.\_PrefixCode.ps1' 1
#Region '.\Classes\EnvironmentVariableItems.ps1' 0
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
        if ($null -ne $val) {$val = $val.Trim($Separator)}

        $this.Items = [System.Collections.ArrayList] @()
        if ($null -ne $val) {        
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
#EndRegion '.\Classes\EnvironmentVariableItems.ps1' 273
#Region '.\Private\GetWhatIf.ps1' 0
function GetWhatIf() {
    @"

    Current Value: 
        $($evis.Value)
    New Value: 
        $($evis.ToString())

"@
}

#EndRegion '.\Private\GetWhatIf.ps1' 11
#Region '.\Public\Add-EnvironmentVariableItem.ps1' 0
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
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
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
            [int] $Index
    )    
    process {
        $evis = [EnvironmentVariableItems]::new($Name, $Scope, $Separator)

        if ($PSBoundParameters.ContainsKey('Index')) {
            $result = $evis.AddItem($Item, $Index)
        } else {
            $result = $evis.AddItem($Item)
        }

        if ($result -eq $True) {
                $s = GetWhatIf
            if ($PSCmdlet.ShouldProcess($s, '', '')){
                $evis.SetEnvironmentVariable($evis.Name, $evis.ToString(), $evis.Scope)
                $evis
            }
        } else { 
            return
        }
    }
}
#EndRegion '.\Public\Add-EnvironmentVariableItem.ps1' 110
#Region '.\Public\Get-EnvironmentVariableItems.ps1' 0

<#
.SYNOPSIS
_Gets an EnvironmentVariableItems PSCustomObject for a given Name, Scope (default; 'Process') and Separator (';').

.PARAMETER Name
Environment variable name

.PARAMETER Scope
Environment variable scope  (.NET enum System.EnvironmentVariableTarget)

.PARAMETER Separator
Environment variable item separator (eg., ';' in $env:Path of 'C:\foo;C:\bar')

.EXAMPLE

Get current process $env:Path EnvironmentVariableItems PSCustomObject

PS> Get-EnvironmentVariableItems -Name Path 

Name      : Path
Scope     : Process
Separator : ;
Value     : C:\Program Files\PowerShell\7;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.
            0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files (x86)\ATI
            Technologies\ATI.ACE\Core-Static;C:\ProgramData\chocolatey\bin;C:\Program Files\PowerShell\7\;C:\Program
            Files\Git\cmd;C:\Program Files\Microsoft VS Code\bin;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps
Items     : {C:\Program Files\PowerShell\7, C:\WINDOWS\system32, C:\WINDOWS, C:\WINDOWS\System32\Wbem…}

.EXAMPLE

Get user $env:Path EnvironmentVariableItems PSCustomObject

PS> Get-EnvironmentVariableItems -Name Path -Scope User

Name      : Path
Scope     : User
Separator : ;
Value     : C:\tmp;C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps
Items     : {C:\tmp, C:\Users\michaelf\AppData\Local\Microsoft\WindowsApps}

.EXAMPLE

Get user $env:foo EnvironmentVariableItems PSCustomObject

PS> gevis foo -sc user -se '#'

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
    param (
        [Parameter(Mandatory)]
        [ValidatePattern("^[^=]+$")]
            [String] $Name,
        [Parameter()]
            [System.EnvironmentVariableTarget] $Scope = [System.EnvironmentVariableTarget]::Process,
        [Parameter()]
            [String] $Separator = ';'
    )    
    process {
        [EnvironmentVariableItems]::new($Name, $Scope, $Separator)
    }
}
#EndRegion '.\Public\Get-EnvironmentVariableItems.ps1' 73
#Region '.\Public\Remove-EnvironmentVariableItem.ps1' 0
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
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
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
            [String] $Separator = ";"

    ) 
    process {
        $evis = [EnvironmentVariableItems]::new($Name, $Scope, $Separator)
        
        if ($PSCmdlet.ParameterSetName -eq 'ByIndex') {
            $result = $evis.RemoveItemByIndex($Index) -ne $False
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByItem') {
            $result = $evis.RemoveItemByItem($Item) -ne $False
        }
    
        if ($result -ne $False) {
            $s = GetWhatIf
            if ($PSCmdlet.ShouldProcess($s, '', '')){
                $evis.SetEnvironmentVariable($evis.Name, $evis.ToString(), $evis.Scope)
                $evis
            }
        } else { 
            return
        }
    }
}
#EndRegion '.\Public\Remove-EnvironmentVariableItem.ps1' 152
#Region '.\Public\Show-EnvironmentVariableItems.ps1' 0
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
#EndRegion '.\Public\Show-EnvironmentVariableItems.ps1' 81
