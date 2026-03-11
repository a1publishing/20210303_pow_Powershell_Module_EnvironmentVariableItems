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
        'Machine' { return @([System.EnvironmentVariableTarget]::Machine) }
        'User'    { return @([System.EnvironmentVariableTarget]::User) }
        default       { return @([System.EnvironmentVariableTarget]::Process) }
    }
}
