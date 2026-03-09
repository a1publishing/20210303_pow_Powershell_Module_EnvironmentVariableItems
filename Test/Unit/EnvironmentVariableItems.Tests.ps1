<#
param(
    $ModulePath = "$PSScriptRoot\..\..\Source\"
)

# Remove trailing slash or backslash
$ModulePath = $ModulePath -replace '[\\/]*$'
$ModuleName = (Get-Item "$ModulePath\..").Name
$ModuleManifestName = 'EnvironmentVariableItems.psd1'
$ModuleManifestPath = Join-Path -Path $ModulePath -ChildPath $ModuleManifestName
#>

param (
    [Parameter(Mandatory)]
    [string] $File
)

BeforeAll {
    Get-Content $File | Foreach-Object {
        $var = $_.Split('=')
        New-Variable -Name $var[0] -Value $var[1]
    }

    $ModulePath = $ModulePath -replace '[\\/]*$'
    $ModuleManifestName = 'EnvironmentVariableItems.psd1'
    $ModuleManifestPath = Join-Path -Path $ModulePath -ChildPath $ModuleManifestName

    $script:IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}


Describe 'Core Module Tests' -Tags 'CoreModule', 'Unit' {

    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath
        $? | Should -Be $true
    }

    It 'Loads from module path without errors' {
        { Import-Module "$ModulePath\$ModuleName.psd1" -ErrorAction Stop } | Should -Not -Throw
    }

    AfterAll {
        Get-Module -Name $ModuleName | Remove-Module -Force
    }
}


Describe 'Resolve-ScopeParameter' -Tag 'Unit' {
    BeforeAll {
        Import-Module "$ModulePath\$ModuleName.psd1"
    }
    AfterAll {
        Get-Module -Name $ModuleName | Remove-Module -Force
    }

    It 'ProcessOnly returns [Process]' {
        InModuleScope EnvironmentVariableItems {
            $r = Resolve-ScopeParameter 'ProcessOnly'
            $r | Should -HaveCount 1
            $r[0] | Should -Be ([System.EnvironmentVariableTarget]::Process)
        }
    }
    It 'MachineOnly returns [Machine]' {
        InModuleScope EnvironmentVariableItems {
            $r = Resolve-ScopeParameter 'MachineOnly'
            $r | Should -HaveCount 1
            $r[0] | Should -Be ([System.EnvironmentVariableTarget]::Machine)
        }
    }
    It 'UserOnly returns [User]' {
        InModuleScope EnvironmentVariableItems {
            $r = Resolve-ScopeParameter 'UserOnly'
            $r | Should -HaveCount 1
            $r[0] | Should -Be ([System.EnvironmentVariableTarget]::User)
        }
    }
    It 'ProcessAndMachine returns [Process, Machine]' {
        InModuleScope EnvironmentVariableItems {
            $r = Resolve-ScopeParameter 'ProcessAndMachine'
            $r | Should -HaveCount 2
            $r[0] | Should -Be ([System.EnvironmentVariableTarget]::Process)
            $r[1] | Should -Be ([System.EnvironmentVariableTarget]::Machine)
        }
    }
    It 'pam returns same as ProcessAndMachine' {
        InModuleScope EnvironmentVariableItems {
            $r = Resolve-ScopeParameter 'pam'
            $r | Should -HaveCount 2
            $r[0] | Should -Be ([System.EnvironmentVariableTarget]::Process)
            $r[1] | Should -Be ([System.EnvironmentVariableTarget]::Machine)
        }
    }
    It 'ProcessAndUser returns [Process, User]' {
        InModuleScope EnvironmentVariableItems {
            $r = Resolve-ScopeParameter 'ProcessAndUser'
            $r | Should -HaveCount 2
            $r[0] | Should -Be ([System.EnvironmentVariableTarget]::Process)
            $r[1] | Should -Be ([System.EnvironmentVariableTarget]::User)
        }
    }
    It 'pau returns same as ProcessAndUser' {
        InModuleScope EnvironmentVariableItems {
            $r = Resolve-ScopeParameter 'pau'
            $r | Should -HaveCount 2
            $r[0] | Should -Be ([System.EnvironmentVariableTarget]::Process)
            $r[1] | Should -Be ([System.EnvironmentVariableTarget]::User)
        }
    }
}


Describe 'Add-EnvironmentVariableItem' -Tag 'Unit' {
    BeforeAll {
        Import-Module "$ModulePath\$ModuleName.psd1"
        $script:TestVar = 'EVI_TEST_Add'
    }
    AfterEach {
        [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'Process')
        [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'User')
        if ($script:IsAdmin) {
            [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'Machine')
        }
    }
    AfterAll {
        Get-Module -Name $ModuleName | Remove-Module -Force
    }

    It 'ProcessOnly adds to Process scope only' {
        Add-EnvironmentVariableItem -Name $script:TestVar -Item 'foo' -Scope ProcessOnly -NoConfirmationRequired
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Process') | Should -Be 'foo'
        [Environment]::GetEnvironmentVariable($script:TestVar, 'User') | Should -BeNullOrEmpty
    }

    It 'UserOnly adds to User scope only' {
        Add-EnvironmentVariableItem -Name $script:TestVar -Item 'foo' -Scope UserOnly -NoConfirmationRequired
        [Environment]::GetEnvironmentVariable($script:TestVar, 'User') | Should -Be 'foo'
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Process') | Should -BeNullOrEmpty
    }

    It 'ProcessAndUser (pau) adds to Process and User scopes' {
        Add-EnvironmentVariableItem -Name $script:TestVar -Item 'foo' -Scope pau -NoConfirmationRequired
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Process') | Should -Be 'foo'
        [Environment]::GetEnvironmentVariable($script:TestVar, 'User') | Should -Be 'foo'
    }

    It 'ProcessAndMachine adds to Process and Machine scopes' -Skip:(-not $script:IsAdmin) {
        Add-EnvironmentVariableItem -Name $script:TestVar -Item 'foo' -Scope ProcessAndMachine -NoConfirmationRequired
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Process') | Should -Be 'foo'
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Machine') | Should -Be 'foo'
    }

    It 'pam alias works identically to ProcessAndMachine' -Skip:(-not $script:IsAdmin) {
        Add-EnvironmentVariableItem -Name $script:TestVar -Item 'foo' -Scope pam -NoConfirmationRequired
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Process') | Should -Be 'foo'
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Machine') | Should -Be 'foo'
    }

    It 'Returns an EnvironmentVariableItems object per scope' {
        $result = Add-EnvironmentVariableItem -Name $script:TestVar -Item 'foo' -Scope pau -NoConfirmationRequired
        $result | Should -HaveCount 2
        $result[0].Name | Should -Be $script:TestVar
        $result[0].Items | Should -Contain 'foo'
    }
}


Describe 'Remove-EnvironmentVariableItem' -Tag 'Unit' {
    BeforeAll {
        Import-Module "$ModulePath\$ModuleName.psd1"
        $script:TestVar = 'EVI_TEST_Remove'
    }
    AfterEach {
        [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'Process')
        [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'User')
        if ($script:IsAdmin) {
            [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'Machine')
        }
    }
    AfterAll {
        Get-Module -Name $ModuleName | Remove-Module -Force
    }

    It 'ProcessOnly removes from Process scope only' {
        [Environment]::SetEnvironmentVariable($script:TestVar, 'foo;bar', 'Process')
        [Environment]::SetEnvironmentVariable($script:TestVar, 'foo;bar', 'User')
        Remove-EnvironmentVariableItem -Name $script:TestVar -Item 'foo' -Scope ProcessOnly -NoConfirmationRequired
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Process') | Should -Be 'bar'
        [Environment]::GetEnvironmentVariable($script:TestVar, 'User') | Should -Be 'foo;bar'
    }

    It 'pau removes from Process and User scopes' {
        [Environment]::SetEnvironmentVariable($script:TestVar, 'foo;bar', 'Process')
        [Environment]::SetEnvironmentVariable($script:TestVar, 'foo;bar', 'User')
        Remove-EnvironmentVariableItem -Name $script:TestVar -Item 'foo' -Scope pau -NoConfirmationRequired
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Process') | Should -Be 'bar'
        [Environment]::GetEnvironmentVariable($script:TestVar, 'User') | Should -Be 'bar'
    }

    It 'Removes by index with ProcessOnly' {
        [Environment]::SetEnvironmentVariable($script:TestVar, 'foo;bar;baz', 'Process')
        Remove-EnvironmentVariableItem -Name $script:TestVar -Index 1 -Scope ProcessOnly -NoConfirmationRequired
        [Environment]::GetEnvironmentVariable($script:TestVar, 'Process') | Should -Be 'foo;baz'
    }
}


Describe 'Get-EnvironmentVariableItems' -Tag 'Unit' {
    BeforeAll {
        Import-Module "$ModulePath\$ModuleName.psd1"
        $script:TestVar = 'EVI_TEST_Get'
        [Environment]::SetEnvironmentVariable($script:TestVar, 'foo;bar', 'Process')
        [Environment]::SetEnvironmentVariable($script:TestVar, 'baz', 'User')
    }
    AfterAll {
        [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'Process')
        [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'User')
        Get-Module -Name $ModuleName | Remove-Module -Force
    }

    It 'ProcessOnly returns single object with Process scope' {
        $result = Get-EnvironmentVariableItems -Name $script:TestVar -Scope ProcessOnly
        $result | Should -HaveCount 1
        $result.Scope | Should -Be 'Process'
        $result.Items | Should -Contain 'foo'
    }

    It 'UserOnly returns single object with User scope' {
        $result = Get-EnvironmentVariableItems -Name $script:TestVar -Scope UserOnly
        $result | Should -HaveCount 1
        $result.Scope | Should -Be 'User'
        $result.Items | Should -Contain 'baz'
    }

    It 'pau returns two objects for Process and User scopes' {
        $result = Get-EnvironmentVariableItems -Name $script:TestVar -Scope pau
        $result | Should -HaveCount 2
        $result[0].Scope | Should -Be 'Process'
        $result[1].Scope | Should -Be 'User'
    }
}


Describe 'Show-EnvironmentVariableItems' -Tag 'Unit' {
    BeforeAll {
        Import-Module "$ModulePath\$ModuleName.psd1"
        $script:TestVar = 'EVI_TEST_Show'
        [Environment]::SetEnvironmentVariable($script:TestVar, 'foo', 'Process')
        [Environment]::SetEnvironmentVariable($script:TestVar, 'bar', 'User')
    }
    AfterAll {
        [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'Process')
        [Environment]::SetEnvironmentVariable($script:TestVar, $null, 'User')
        Get-Module -Name $ModuleName | Remove-Module -Force
    }

    It 'No scope shows all scopes without error' {
        { Show-EnvironmentVariableItems -Name $script:TestVar } | Should -Not -Throw
    }

    It 'ProcessOnly shows without error' {
        { Show-EnvironmentVariableItems -Name $script:TestVar -Scope ProcessOnly } | Should -Not -Throw
    }

    It 'pau shows without error' {
        { Show-EnvironmentVariableItems -Name $script:TestVar -Scope pau } | Should -Not -Throw
    }

    It 'ProcessAndUser shows without error' {
        { Show-EnvironmentVariableItems -Name $script:TestVar -Scope ProcessAndUser } | Should -Not -Throw
    }
}
