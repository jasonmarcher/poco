# Requirements
if ($Host.Name -eq "Windows PowerShell ISE Host") {
    throw "poco is not compatible with Windows PowerShell ISE."

    ## TODO: Add a more specific test for the ability to modify the console output buffer which is the real compatibility issue
}

# .ExternalHelp poco-help.xml
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
        while ($action -ne 'Cancel' -and $action -ne 'Finish') {
            Write-Screen $state $config

            $OldQuery = $State.Query -replace '(:\w+\s*)$|(\s+)$'

            do {
                $key, $keystr = Get-PocoKey
                $action = Get-Action $config $keystr
                $state = Update-State $state $config $action $key
            } while ([console]::KeyAvailable)

            if ($OldQuery -ne ($State.Query -replace '(:\w+\s*)$|(\s+)$')) {
                $state.Entry = Get-Entry $state $config
            }
        }

        Restore-ScrBuf
        if ($action -eq 'Finish') {$state.Entry}
    } catch {
        Restore-ScrBuf
    }
}

Set-Alias poco Select-Poco

Export-ModuleMember -Function "Select-Poco" -Alias "poco"
function New-Config ($Items, $Property, $Prompt, $Layout, $Keymaps) {
    @{
        'Input' = $Items
        'Property' = $Property
        'Prompt' = $Prompt
        'Layout' = $Layout
        'Keymaps' = $Keymaps
    }
}

function New-State ($Query, $Filter, $CaseSensitive, $InvertFilter, $Config) {
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
        'RawUI' = Get-RawUI
        # 'Y' = 1 # é¸æŠžæ©Ÿèƒ½ãŒã‚ã‚Œã°...
        }
    }
  
    $state.Screen.Prompt = Get-Prompt $state $config
    $state.Screen.FilterType = Get-FilterType $state
    $state.Screen.QueryX = $Query.Length
    $state.Screen.X = $state.Screen.Prompt.Length

    $state.Entry = Get-Entry $state $config

    $state
}
function New-PocoKeymaps {
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

function Get-PocoKey {
    $flag = [console]::TreatControlCAsInput
    [console]::TreatControlCAsInput = $true

    $Key = [console]::ReadKey($true)

    [console]::TreatControlCAsInput = $flag

    $KeyString = $Key.Key.ToString()
    if ($Key.Modifiers -ne 0) {
        $m = $Key.Modifiers.ToString() -replace ', ','+'
        $KeyString = "${m}+${KeyString}"
    }

    return $Key, $KeyString
}

function Get-Action ($config, $keystr) {
    if ($config.Keymaps.Contains($keystr)) {
        return $config.Keymaps[$keystr]
    }

    if ($keystr -notmatch 'Alt|Control') {
        'AddChar'
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
# http://d.hatena.ne.jp/newpops/20080514
# ã‚¹ã‚¯ãƒªãƒ¼ãƒ³ãƒãƒƒãƒ•ã‚¡ã®ãƒãƒƒã‚¯ã‚¢ãƒƒãƒ—
function Backup-ScrBuf {
    $rui = Get-RawUI

    $rect = New-Object System.Management.Automation.Host.Rectangle
    $rect.Left   = 0
    $rect.Top    = 0
    $rect.Right  = $rui.WindowSize.Width
    $rect.Bottom = $rui.CursorPosition.Y
    $script:screen = $rui.GetBufferContents($rect)
}

# http://d.hatena.ne.jp/newpops/20080515
# ã‚¹ã‚¯ãƒªãƒ¼ãƒ³ãƒãƒƒãƒ•ã‚¡ã®ãƒªã‚¹ãƒˆã‚¢
function Restore-ScrBuf {
    Clear-Host

    if (-not (Test-Path 'variable:screen')) {return}

    $rui = Get-RawUI
    $origin = New-Object System.Management.Automation.Host.Coordinates(0, 0)
    $rui.SetBufferContents($origin, $script:screen)
    $pos = New-Object System.Management.Automation.Host.Coordinates(0, $script:screen.GetUpperBound(0))
    $rui.CursorPosition = $pos
}
function Write-Screen ($state, $config) {
    switch ($config.Layout) {
        'TopDown'  {Write-TopDown  $state $config}
        'BottomUp' {Write-BottomUp $state $config}
    }
}

function Write-TopDown ($state, $config) {
    Write-ScreenLine $state 0 $state.Screen.Prompt
    Write-RightInfo 0 $state
    
    if ($state.Entry.length -ne $state.PrevLength) {
        $h = $state.Screen.RawUI.WindowSize.Height
        $entries = $state.Entry | Format-Table | Out-String -Stream | Select-Object -First ($h - 1)
        if ($entries -is [string]) {$entries = ,@($entries)}
        foreach ($i in 0..($h - 2)) {
            $line = if ($i -lt $entries.length) {$entries[$i]} else {''}
            Write-ScreenLine $state ($i + 1) $line
        }

        $state.PrevLength = $state.Entry.length
    }

    $x = Convert-CursorPositionX $state
    Set-CursorPosition $state $x 0
}

function Write-BottomUp ($state, $config, $entries) {
    if ($state.Entry.length -ne $state.PrevLength) {
        $h = $state.Screen.RawUI.WindowSize.Height
        $entries = $state.Entry | Format-Table | Out-String -Stream | Select-Object -First ($h - 1)
        if ($entries -is [string]) {$entries = ,@($entries)}
        foreach ($i in 0..($h - 2)) {
            $line = if ($i -lt $entries.length) {$entries[$i]} else {''}
            Write-ScreenLine $state $i $line
        }
        
        $state.PrevLength = $state.Entry.length
    }

    Write-ScreenLine $state ($h - 1) $state.Screen.Prompt
    Write-RightInfo ($h - 1) $state

    $x = Convert-CursorPositionX $state
    $y = $state.Screen.RawUI.CursorPosition.Y
    Set-CursorPosition $state $x $y
}

function Write-ScreenLine ($state, $i, $line) {
    $w = $state.Screen.RawUI.BufferSize.Width
    Set-CursorPosition $state 0 $i
    Write-Host ([string]$line).PadRight($w) -NoNewline  ## TODO: replace
}

function Write-RightInfo ($i, $state) {
    $f = $state.Screen.FilterType
    $n = $state.Entry.Length
    $w = $state.Screen.RawUI.WindowSize.Width
    # $h = $state.Screen.RawUI.WindowSize.Height
    
    $info = "${f} [${n}]"
    Set-CursorPosition $state ($w - $info.length) $i
    Write-Host $info -NoNewline  ## TODO: replace
}

function Convert-CursorPositionX ($state) {
    $str = $state.Screen.Prompt.Substring(0, $state.Screen.X)
    $state.Screen.RawUI.LengthInBufferCells($str)
}

function Set-CursorPosition ($state, $x, $y) {
    $pos = New-Object System.Management.Automation.Host.Coordinates($x, $y)
    $state.Screen.RawUI.CursorPosition = $pos
}
function Update-State ($state, $config, $action, $key) {
    switch ($action) {
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

function Add-Char ($state, $config, $char) {
    $x = $state.Screen.QueryX
    $q = $state.Query

    $state.Query = $q.Insert($x, $char)
    $state.Screen.QueryX++
    $state.Screen.X++

    $state.Screen.Prompt = Get-Prompt $state $config
}

function Move-BackwardChar ($state) {
    $x = $state.Screen.QueryX
    if ($x - 1 -ge 0) {
        $state.Screen.QueryX--
        $state.Screen.X--
    }
}

function Move-ForwardChar ($state) {
    $x = $state.Screen.X
    $l = $state.Screen.Prompt.length

    if ($x + 1 -le $l) {
        $state.Screen.QueryX++
        $state.Screen.X++
    }
}

function Move-BeginningOfLine ($state) {
    $state.Screen.X -= $state.Screen.QueryX
    $state.Screen.QueryX = 0
}

function Move-EndOfLine ($state) {
    $state.Screen.QueryX = $state.Query.length
    $state.Screen.X = $state.Screen.Prompt.length
}

function Remove-BackwardChar ($state) {
    $x = $state.Screen.QueryX
    $q = $state.Query
    
    if ($x - 1 -ge 0) {
        $state.Query = $q.Remove($x - 1, 1)
        $state.Screen.QueryX--
        $state.Screen.X--

        $state.Screen.Prompt = Get-Prompt $state $config
    }
}

function Remove-ForwardChar ($state) {
    $x = $state.Screen.X
    $l = $state.Screen.Prompt.length

    $qx = $state.Screen.QueryX
    $q = $state.Query

    if ($x + 1 -le $l) {
        $state.Query = $q.Remove($qx, 1)
        $state.Screen.Prompt = Get-Prompt $state $config
    }
}

function Remove-HeadLine ($state) {
    while ($state.Screen.QueryX -gt 0) {
        Remove-BackwardChar ($state)
    }
}

function Remove-TailLine ($state) {
    while ($state.Screen.QueryX -lt $state.Query.length) {
        Remove-ForwardChar ($state)
    }
}

function Select-Matcher ($state) {
    $arr = @('match', 'like', 'eq')

    $n = $arr.length
    $i = $arr.IndexOf($state.Filter) + 1

    $state.Filter = $arr[$i % $n]

    $state.Screen.FilterType = Get-FilterType $state
}

function Switch-CaseSensitive ($state) {
    $state.CaseSensitive = -not $state.CaseSensitive
    $state.Screen.FilterType = Get-FilterType $state
}

function Switch-InvertFilter ($state) {
    $state.InvertFilter = -not $state.InvertFilter
    $state.Screen.FilterType = Get-FilterType $state
}
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
    Select-ByQuery $State $Config.Input
}
