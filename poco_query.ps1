function Where-Query {
    param(
        $state
        ,
        [Parameter(ValueFromPipeline=$True)]
        $obj
    )

    begin {
        $hash = Convert-QueryHash $state
    }

    process {
        if ($hash.Contains('')) {
        foreach ($value in $hash['']) {
            $test = Test-Matching $state.Screen.FilterType $obj $value
            if ($test -eq $false) {return}
        }
        }
        
        foreach ($property in $hash.Keys) {
        if ($property -eq '') {continue}
        
        if (-not (Get-Member $property -InputObject $obj)) {continue}
        
        foreach ($value in $hash[$property]) {
            $test = Test-Matching $state.Screen.FilterType $obj.$property $value
            if ($test -eq $false) {return}
        }
        }

        ,$obj
    }
}

function Convert-QueryHash ($state) {
    $property = ''
    $hash = @{$property = @()}

    $state.Query -split ' ' | Where-Object {$_ -ne ''} | ForEach-Object {
        $token = $_
        
        if ($token.StartsWith(':')) {
        $property = $token.Remove(0, 1)
        if (-not $hash.Contains($property)) {
            $hash[$property] = @()
        }
        } else {
        $hash[$property] += $token
        }
    }

    $hash
}

function Test-Matching {
    param(
        [string] $FilterType,
        [string] $p,    
        [string] $value
    )

    try {
        switch ($FilterType) {
        'match'     {$p -match $value; break}
        'like'      {$p -like  $value; break}
        'eq'        {$p -eq    $value; break}

        'notmatch'  {$p -notmatch $value; break}
        'notlike'   {$p -notlike  $value; break}
        'neq'       {$p -ne       $value; break}

        'cmatch'    {$p -cmatch $value; break}
        'clike'     {$p -clike  $value; break}
        'ceq'       {$p -ceq    $value; break}

        'cnotmatch' {$p -cnotmatch $value; break}
        'cnotlike'  {$p -cnotlike  $value; break}
        'cneq'      {$p -cne       $value; break}
        }
    } catch {
        $true
    }
}
