function Update-State ($state, $config, $action, $key)
{
  switch ($action)
  {
    'AddChar'             {Add-Char $state $config $key.KeyChar}
    'ForwardChar'         {Move-ForwardChar $state}
    'BackwardChar'        {Move-BackwardChar $state}
    'BeginningOfLine'     {Move-BeginningOfLine $state}
    'EndOfLine'           {Move-EndOfLine $state}
    'DeleteBackwardChar'  {Remove-BackwardChar $state}
    'DeleteForwardChar'   {Remove-ForwardChar $state}
    'KillBeginningOfLine' {Remove-HeadLine $state}
    'KillEndOfLine'       {Remove-TailLine $state}
    'RotateMatcher'       {Select-Matcher $state}
    'ToggleCaseSensitive' {Switch-CaseSensitive $state}
    'ToggleInvertFilter'  {Switch-InvertFilter $state}
    
    default {} # None, Cancel, Finish = identity
  }
  
  $state
}

function Add-Char ($state, $config, $char)
{
  $x = $state.Screen.QueryX
  $q = $state.Query

  $state.Query = $q.Insert($x, $char)
  $state.Screen.QueryX++
  $state.Screen.X++

  $state.Screen.Prompt = Get-Prompt $state $config
  $state.Entry = Get-Entry $state $config
}

function Move-BackwardChar ($state)
{
  $x = $state.Screen.QueryX
  if ($x - 1 -ge 0)
  {
    $state.Screen.QueryX--
    $state.Screen.X--
  }
}

function Move-ForwardChar ($state)
{
  $x = $state.Screen.X
  $l = $state.Screen.Prompt.length

  if ($x + 1 -le $l)
  {
    $state.Screen.QueryX++
    $state.Screen.X++
  }
}

function Move-BeginningOfLine ($state)
{
  $state.Screen.X -= $state.Screen.QueryX
  $state.Screen.QueryX = 0
}

function Move-EndOfLine ($state)
{
  $state.Screen.QueryX = $state.Query.length
  $state.Screen.X = $state.Screen.Prompt.length
}

function Remove-BackwardChar ($state)
{
  $x = $state.Screen.QueryX
  $q = $state.Query
  
  if ($x - 1 -ge 0) {
    $state.Query = $q.Remove($x - 1, 1)
    $state.Screen.QueryX--
    $state.Screen.X--

    $state.Screen.Prompt = Get-Prompt $state $config
    $state.Entry = Get-Entry $state $config
  }
}

function Remove-ForwardChar ($state)
{
  $x = $state.Screen.X
  $l = $state.Screen.Prompt.length

  $qx = $state.Screen.QueryX
  $q = $state.Query

  if ($x + 1 -le $l)
  {
    $state.Query = $q.Remove($qx, 1)
    $state.Screen.Prompt = Get-Prompt $state $config
    $state.Entry = Get-Entry $state $config
  }
}

function Remove-HeadLine ($state)
{
  while ($state.Screen.QueryX -gt 0)
  {
    Remove-BackwardChar ($state)
  }
}

function Remove-TailLine ($state)
{
  while ($state.Screen.QueryX -lt $state.Query.length)
  {
    Remove-ForwardChar ($state)
  }
}

function Select-Matcher ($state)
{
  $arr = @('match', 'like', 'eq')

  $n = $arr.length
  $i = $arr.IndexOf($state.Filter) + 1

  $state.Filter = $arr[$i % $n]

  $state.Screen.FilterType = Get-FilterType $state
  $state.Entry = Get-Entry $state $config
}

function Switch-CaseSensitive ($state)
{
  $state.CaseSensitive = -not $state.CaseSensitive
  $state.Screen.FilterType = Get-FilterType $state
  $state.Entry = Get-Entry $state $config
}

function Switch-InvertFilter ($state)
{
  $state.InvertFilter = -not $state.InvertFilter
  $state.Screen.FilterType = Get-FilterType $state
  $state.Entry = Get-Entry $state $config
}
