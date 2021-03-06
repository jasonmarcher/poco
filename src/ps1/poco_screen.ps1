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
    $pos = [System.Management.Automation.Host.Coordinates]::new($x, $y)
    $state.Screen.RawUI.CursorPosition = $pos
}
