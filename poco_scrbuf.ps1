# http://d.hatena.ne.jp/newpops/20080514
# スクリーンバッファのバックアップ
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
# スクリーンバッファのリストア
function Restore-ScrBuf {
    Clear-Host

    if (-not (Test-Path 'variable:screen')) {return}

    $rui = Get-RawUI
    $origin = New-Object System.Management.Automation.Host.Coordinates(0, 0)
    $rui.SetBufferContents($origin, $script:screen)
    $pos = New-Object System.Management.Automation.Host.Coordinates(0, $script:screen.GetUpperBound(0))
    $rui.CursorPosition = $pos
}