function Get-RawUI {(Get-Host).UI.RawUI}

function Get-Prompt ($state, $config) {
    $config.Prompt + '> ' + $state.Query
}

function Get-FilterType ($state) {
    $type = ''
    if ($state.CaseSensitive) {$type += 'c'}
    if ($state.InvertFilter) {$type += 'not'}
    $type += $state.Filter
    
    $type -replace 'noteq', 'neq'
}

function Get-Entry ($state, $config) {
    $config.Input |
        Select-Object -Property $config.Property |
        Where-Query $state
}