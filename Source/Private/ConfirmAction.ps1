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
