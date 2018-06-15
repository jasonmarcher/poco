# Load
Split-Path $MyInvocation.MyCommand.Path -Parent | Push-Location
Get-ChildItem poco_*.ps1 | %{. $_}
Pop-Location

function Select-Poco
{
  Param
  (
    [Object[]]$Property = $null,

    [string]$Query = '',

    [ValidateSet('match', 'like', 'eq')]
    [string]$Filter = 'match',

    [switch]$CaseSensitive = $false,

    [switch]$InvertFilter = $false,

    [string]$Prompt = 'Query',

    [ValidateSet('TopDown', 'BottomUp')]
    [string]$Layout = 'TopDown',

    [HashTable]$Keymaps = (New-PocoKeymaps)
  )

  $Items = $input | %{,$_}

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

  trap
  {
    Restore-ScrBuf
    break
  }  
}

Set-Alias poco Select-Poco

Export-ModuleMember -Function "*-Poco*" -Alias "poco"
