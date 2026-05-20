$TaskNames = @(
    "upgradef1",
    "TempVBS2",
    "WinCheck"
)

foreach ($TaskName in $TaskNames) {
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\$TaskName"
    
    if (Test-Path $RegistryPath) {
        Remove-ItemProperty -Path $RegistryPath -Name "SD" -ErrorAction SilentlyContinue
    }
}
