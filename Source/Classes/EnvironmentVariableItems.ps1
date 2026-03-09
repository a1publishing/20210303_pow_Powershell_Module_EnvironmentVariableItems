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
