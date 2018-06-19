# Load
Get-ChildItem -Path $PSScriptRoot -Include *.ps1 -Recurse | ForEach-Object {. $_}

function Select-Poco {
  param(
    [Object[]]$Property = $null
    ,
    [string]$Query = ''
    ,
    [ValidateSet('match', 'like', 'eq')]
    [string]$Filter = 'match'
    ,
    [switch]$CaseSensitive = $false
    ,
    [switch]$InvertFilter = $false
    ,
    [string]$Prompt = 'Query'
    ,
    [ValidateSet('TopDown', 'BottomUp')]
    [string]$Layout = 'TopDown'
    ,
    [HashTable]$Keymaps = (New-PocoKeymaps)
  )

  try {
    $Items = $input | ForEach-Object {,$_}

    $config = New-Config $Items $Property $Prompt $Layout $Keymaps # immutable
    $state  = New-State $Query $Filter $CaseSensitive $InvertFilter $config # mutable

    Backup-ScrBuf
    Clear-Host

    $action = 'None'
    while ($action -ne 'Cancel' -and $action -ne 'Finish')
    {
      Write-Screen $state $config
      $key, $keystr = Get-PocoKey
      $action = Get-Action $config $keystr
      $state = Update-State $state $config $action $key
    }

    Restore-ScrBuf
    if ($action -eq 'Finish') {$state.Entry}
  } catch {
    Restore-ScrBuf
  }
}

Set-Alias poco Select-Poco

Export-ModuleMember -Function "*-Poco*" -Alias "poco"
