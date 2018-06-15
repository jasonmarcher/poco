function New-Config ($Items, $Property, $Prompt, $Layout, $Keymaps)
{
  @{
    'Input' = $Items
    'Property' = $Property
    'Prompt' = $Prompt
    'Layout' = $Layout
    'Keymaps' = $Keymaps
  }
}

function New-State ($Query, $Filter, $CaseSensitive, $InvertFilter, $Config)
{
  $state = @{
    'Query' = $Query
    'Filter' = $Filter
    'CaseSensitive' = $CaseSensitive
    'InvertFilter' = $InvertFilter
    'Acrion' = 'Identity'
    'Entry' = @()
    'PrevLength' = 0
    'Screen' = @{
      'Prompt' = ''
      'FilterType' = ''
      'QueryX' = 0
      'X' = 0
      # 'Y' = 1 # 選択機能があれば...
    }
  }
  
  $state.Screen.Prompt = Get-Prompt $state $config
  $state.Screen.FilterType = Get-FilterType $state 
  $state.Screen.QueryX = $Query.Length
  $state.Screen.X = $state.Screen.Prompt.Length

  $state.Entry = Get-Entry $state $config
  
  $state  
}
