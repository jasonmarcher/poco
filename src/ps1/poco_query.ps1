function Convert-QueryHash ($state) {
    $property = ''
    $hash = @{$property = @()}

    $state.Query -split ' ' | Where-Object {$_ -ne ''} | ForEach-Object {
        $token = $_

        if ($token.StartsWith(':')) {
            $property = Resolve-PropertyName $state $token.Remove(0, 1)
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

    ## This search always treats multiple conditions as boolean AND joined

    ## String representation search
    if ($HashQuery.Contains('')) {
        foreach ($Value in $HashQuery['']) {
            $MatchLine = "`$Object $MatchType '$Value'"
            $DelegateString.Append("if (($MatchLine) -eq `$false) {return `$false}; ") > $null
        }
    }

    ## Property value search
    foreach ($Property in $HashQuery.Keys) {
        if ($Property -eq '') {continue}

        foreach ($Value in $HashQuery[$Property]) {
            $MatchLine = "`$Object.$Property $MatchType '$Value'"
            $DelegateString.Append("if (($MatchLine) -eq `$false) {return `$false}; ") > $null
        }
    }

    ## Object passed all tests, so it passes the filter
    $DelegateString.Append('return $true') > $null

    [Scriptblock]::Create($DelegateString.ToString())
}

function Resolve-PropertyName {
    param (
        $State
        ,
        $Alias
    )
    
    ## TODO: This algorithm needs to be optimized

    $Properties = $State.Properties | Select-Object -ExpandProperty Name | Sort-Object
    foreach ($Property in $Properties) {
        if ($Property -like "${Alias}*") {
            return $Property
        }
    }

    return ""
}