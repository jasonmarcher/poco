function Where-Query
{
  Param
  (
    $state,

    [Parameter(ValueFromPipeline=$True)]
    $obj
  )

  begin {$hash = Convert-QueryHash $state}

  process
  {
    if ($hash.Contains(''))
    {
      foreach ($value in $hash[''])
      {
        $test = Test-Matching $state.Screen.FilterType $obj $value
        if ($test -eq $false) {return}
      }
    }
    
    foreach ($property in $hash.Keys)
    {
      if ($property -eq '') {continue}
    
      if (-not (Get-Member $property -InputObject $obj)) {continue}
      
      foreach ($value in $hash[$property])
      {
        $test = Test-Matching $state.Screen.FilterType $obj.$property $value
        if ($test -eq $false) {return}
      }
    }
    
    ,$obj
  }
}

function Convert-QueryHash ($state)
{
  $property = ''
  $hash = @{$property = @()}

  $state.Query -split ' ' | ?{$_ -ne ''} | %{
    $token = $_
    
    if ($token.StartsWith(':'))
    {
      $property = $token.Remove(0, 1)
      if (-not $hash.Contains($property))
      {
        $hash[$property] = @()
      }
    }
    else
    {
      $hash[$property] += $token
    }
  }

  $hash
}

function Test-Matching
{
  Param
  (
    [string] $FilterType,
    [string] $p,    
    [string] $value
  )

  try
  {
    switch ($FilterType)
    {
      'match'     {$p -match $value}
      'like'      {$p -like  $value}
      'eq'        {$p -eq    $value}

      'notmatch'  {$p -notmatch $value}
      'notlike'   {$p -notlike  $value}
      'neq'       {$p -ne       $value}

      'cmatch'    {$p -cmatch $value}
      'clike'     {$p -clike  $value}
      'ceq'       {$p -ceq    $value}

      'cnotmatch' {$p -cnotmatch $value}
      'cnotlike'  {$p -cnotlike  $value}
      'cneq'      {$p -cne       $value}
    }
  }
  catch
  {
    $true
  }
}
