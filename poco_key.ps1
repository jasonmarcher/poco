function New-PocoKeymaps
{
  @{
     'Escape' = 'Cancel'
     'Control+C' = 'Cancel'
     'Enter' = 'Finish'
     'Alt+B' = 'BackwardChar'
     'Alt+F' = 'ForwardChar'
     'Alt+A' = 'BeginningOfLine'
     'Alt+E' = 'EndOfLine'
     'Alt+D8' = 'DeleteBackwardChar'
     'Backspace' = 'DeleteBackwardChar'
     'Alt+D' = 'DeleteForwardChar'
     'Delete' = 'DeleteForwardChar'
     'Alt+U' = 'KillBeginningOfLine'
     'Alt+K' = 'KillEndOfLine'
     'Alt+R' = 'RotateMatcher'
     'Alt+C' = 'ToggleCaseSensitive'
     'Alt+I' = 'ToggleInvertFilter'

     'Alt+W' = 'DeleteBackwardWord'
     'Alt+N' = 'SelectUp'
     'Alt+P' = 'SelectDown'
     'Control+Spacebar' = 'ToggleSelectionAndSelectNext'
     'UpArrow' = 'SelectUp'
     'DownArrow' = 'SelectDown'
     'RightArrow' = 'ScrollPageUp'
     'LeftArrow' = 'ScrollPageDown'
     'Tab' = 'TabExpansion'
  }
}

function Get-PocoKey
{
  $flag = [console]::TreatControlCAsInput
  [console]::TreatControlCAsInput = $true

  $Key = [console]::ReadKey($true)

  [console]::TreatControlCAsInput = $flag

  $KeyString = $Key.Key.ToString()
  if ($Key.Modifiers -ne 0)
  {
    $m = $Key.Modifiers.ToString() -replace ', ', '+'
    $KeyString = "${m}+${KeyString}"
  }

  return $Key, $KeyString
}

function Get-Action ($config, $keystr)
{
  if ($config.Keymaps.Contains($keystr))
  {
    return $config.Keymaps[$keystr]
  }

  if ($keystr -notmatch 'Alt|Control')
  {
    'AddChar'
  }
}
