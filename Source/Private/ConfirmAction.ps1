function ConfirmAction {
    param (
        [String] $Message,
        [switch] $NoConfirmationRequired
    )
    if ($NoConfirmationRequired) { return $True }
    Write-Host $Message
    $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
        [System.Management.Automation.Host.ChoiceDescription]::new('&Yes'),
        [System.Management.Automation.Host.ChoiceDescription]::new('&No')
    )
    $Host.UI.PromptForChoice('Confirm', 'Are you sure you want to perform this action?', $choices, 0) -eq 0
}
