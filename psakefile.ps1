Properties {
    $SrcDirectory = "$PSScriptRoot/src/ps1"
    $OutputDirectory = "$PSScriptRoot/build"
    $ReportDirectory = "$PSSCriptRoot/reports"
    $DeployDirectory = "$HOME/Documents/WindowsPowerShell/Modules/poco"
}

Task 'default' -Depends build

Task 'clean' {
    if (Test-Path $OutputDirectory) {
        Remove-Item $OutputDirectory -Recurse -Force
    }
}

Task 'build' -Depends clean {
    New-Item $OutputDirectory -ItemType Directory -ErrorAction SilentlyContinue > $null

    ## Copy manifest
    Copy-Item "$SrcDirectory/poco.psd1" -Destination $OutputDirectory -Force

    ## Build module
    $ModuleContent = Get-Content "$SrcDirectory/poco.psm1"
    foreach ($script in (Get-ChildItem $SrcDirectory -Include *.ps1 -Recurse)) {
        $ModuleContent += Get-Content $script.FullName
    }
    Set-Content "$OutputDirectory/poco.psm1" -Value $ModuleContent -Encoding UTF8 -Force
}

Task 'deploy' -Depends build {
    if (Test-Path $DeployDirectory) {
        Remove-Item $DeployDirectory -Recurse -Force
    }

    New-Item $DeployDirectory -ItemType Directory -ErrorAction SilentlyContinue > $null

    Copy-Item "$OutputDirectory/*" -Destination $DeployDirectory -Force
}

Task 'checkStyle' -Depends build {
    New-Item $ReportDirectory -ItemType Directory -ErrorAction SilentlyContinue > $null

    $FilesToCheck = Get-ChildItem $SrcDirectory -Include *.ps1 -Recurse
    $FilesToCheck += Get-ChildItem $OutputDirectory -Include *.psd1 -Recurse

    $Results = $FilesToCheck | ForEach-Object {Invoke-ScriptAnalyzer $_.FullName}
    $Results | Where-Object Severity -eq "Error" | Format-Table | Out-String | Write-Host -ForegroundColor Red
    $Results | Select-Object RuleName,Severity,Line,Column,ScriptName,Message | ConvertTo-Csv -NoTypeInformation | Set-Content "$ReportDirectory/checkstyle.csv" -Force
}