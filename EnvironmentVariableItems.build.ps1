#Requires -Modules @{ModuleName='InvokeBuild';ModuleVersion='5.6.7'}
#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.1.1'}

<#
.SYNOPSIS
    Build script for EnvironmentVariableItems PowerShell module.

.USAGE
    Invoke-Build                  # Clean, test source, compile, test build
    Invoke-Build Deploy           # Full build + install to module library
    Invoke-Build Install          # Install existing bin output to module library (no rebuild)
    Invoke-Build Publish          # Publish to PSGallery (prompts for API key if $env:PSGALLERY_KEY not set)

.PARAMETERS
    -PesterOutput  Pester output verbosity: None, Normal, Detailed, Diagnostic (default: Normal)
#>

param(
    $PesterOutput = 'Normal'
)

$Script:ModuleName = 'EnvironmentVariableItems'
Get-Module -Name $Script:ModuleName | Remove-Module -Force

task Clean {
    Remove-Item -Path ".\bin" -Recurse -Force -ErrorAction SilentlyContinue
}

task TestCode {
    Write-Build Yellow "`n`n`nTesting dev code before build"
    $f = "$PSScriptRoot\Test\tmp\data.ps1"
    New-Item -ItemType Directory -Path "$PSScriptRoot\Test\tmp" -Force | Out-Null
    "ModulePath=$PSScriptRoot\Source\`nModuleName=$Script:ModuleName" | Out-File $f
    $container = New-PesterContainer -Path 'EnvironmentVariableItems.Tests.ps1' -Data @{ File = $f }
    $TestResult = Invoke-Pester -Path "$PSScriptRoot\Test\Unit" -Tag Unit -Output $PesterOutput -Container $container -PassThru

    if ($TestResult.FailedCount -gt 0) { throw 'Tests failed' }
}

task CompilePSM {
    Write-Build Yellow "`n`n`nCompiling all code into single psm1"
    try {
        $BuildParams = @{}
        if ((Get-Command -ErrorAction Stop -Name gitversion)) {
            $GitVersion = gitversion | ConvertFrom-Json | Select-Object -ExpandProperty InformationalVersion
            $BuildParams['SemVer'] = $GitVersion
        }
    }
    catch {
        Write-Warning 'gitversion not found, keeping current version'
    }
    Push-Location -Path "$BuildRoot\Source" -StackName 'InvokeBuildTask'
    $Script:CompileResult = Build-Module @BuildParams -Passthru
    Get-ChildItem -Path "$BuildRoot\LICENSE*" | Copy-Item -Destination $Script:CompileResult.ModuleBase
    Pop-Location -StackName 'InvokeBuildTask'
}

task TestBuild {
    Write-Build Yellow "`n`n`nTesting compiled module"
    $f = "$PSScriptRoot\Test\tmp\data.ps1"
    New-Item -ItemType Directory -Path "$PSScriptRoot\Test\tmp" -Force | Out-Null
    "ModulePath=$($Script:CompileResult.ModuleBase)`nModuleName=$Script:ModuleName" | Out-File $f
    $container = New-PesterContainer -Path 'EnvironmentVariableItems.Tests.ps1' -Data @{ File = $f }
    $TestResult = Invoke-Pester -Path "$PSScriptRoot\Test\Unit" -Container $container -PassThru

    if ($TestResult.FailedCount -gt 0) {
        Write-Warning "Failing Tests:"
        $TestResult.Tests.Where{ $_.Result -eq 'Failed' } | ForEach-Object {
            Write-Warning $_.Name
            Write-Verbose $_.ErrorRecord -Verbose
        }
        throw 'Tests failed'
    }
}

task Install {
    Write-Build Yellow "`n`n`nInstalling to module library"
    $moduleBase = (Get-ChildItem -Path "$BuildRoot\bin\$Script:ModuleName" -Directory | Sort-Object Name -Descending | Select-Object -First 1).FullName
    $version = Split-Path $moduleBase -Leaf
    $destination = "S:\lib\pow\mod\$Script:ModuleName\$version"
    Copy-Item -Path $moduleBase -Destination $destination -Recurse -Force
    Write-Build Green "Installed to $destination"
}

task Publish {
    Write-Build Yellow "`n`n`nPublishing to PowerShell Gallery"
    $apiKey = $env:PSGALLERY_KEY
    if (-not $apiKey) {
        $apiKey = Read-Host -Prompt 'Enter NuGet API key for PSGallery' -AsSecureString
        $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)
        )
    }
    $moduleBase = (Get-ChildItem -Path "$BuildRoot\bin\$Script:ModuleName" -Directory | Sort-Object Name -Descending | Select-Object -First 1).FullName
    Publish-Module -Path $moduleBase -NuGetApiKey $apiKey -Repository PSGallery
}

task . Clean, TestCode, Build

task Build CompilePSM, TestBuild

task Deploy Build, Install
