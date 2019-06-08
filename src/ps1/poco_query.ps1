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

function Select-ByQuery {
    param(
        $State
        ,
        [object[]] $Objects
    )

    begin {
        [Func[Object,bool]]$Delegate = New-QueryDelegate $State
    }

    end {
        [Linq.Enumerable]::Where($Objects, $Delegate)
    }
}

function New-QueryDelegate {
    param(
        $State
    )

    $DelegateString = New-Object System.Text.StringBuilder

    $DelegateString.Append('param($Object); ') > $null

    $MatchType = switch ($State.Screen.FilterType) {
        'match'     {"-match"; break}
        'like'      {"-like"; break}
        'eq'        {"-eq"; break}

        'notmatch'  {"-notmatch"; break}
        'notlike'   {"-notlike"; break}
        'neq'       {"-ne"; break}

        'cmatch'    {"-cmatch"; break}
        'clike'     {"-clike"; break}
        'ceq'       {"-ceq"; break}

        'cnotmatch' {"-cnotmatch"; break}
        'cnotlike'  {"-cnotlike"; break}
        'cneq'      {"-cne"; break}
    }

    $HashQuery = Convert-QueryHash $State
    if ($HashQuery.Contains('')) {
        foreach ($Value in $HashQuery['']) {
            $MatchLine = "`$Object $MatchType '$Value'"
            $DelegateString.Append("if (($MatchLine) -eq `$false) {return `$false}; ") > $null
        }
    }

    foreach ($Property in $HashQuery.Keys) {
        if ($Property -eq '') {continue}

        foreach ($Value in $HashQuery[$Property]) {
            $MatchLine = "`$Object.$Property $MatchType '$Value'"
            $DelegateString.Append("if (($MatchLine) -eq `$false) {return `$false}; ") > $null
        }
    }
    $DelegateString.Append('return $true') > $null

    [Scriptblock]::Create($DelegateString.ToString())
}