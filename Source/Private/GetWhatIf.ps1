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

