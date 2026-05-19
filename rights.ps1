$filePaths = @(
    Join-Path $env:TEMP "bsd.txt",
    Join-Path $env:APPDATA "Local\Temp\another_file.txt"
)

foreach ($filePath in $filePaths) {
    if (-not (Test-Path $filePath)) {
        continue
    }

    $aclSettings = Get-Acl -Path $filePath
    $systemAccount = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")
    $aclSettings.SetOwner($systemAccount)
    Set-Acl -Path $filePath -AclObject $aclSettings

    [System.IO.File]::SetAttributes($filePath, [System.IO.FileAttributes]::Normal)

    $aclSettings = Get-Acl -Path $filePath
    $aclSettings.SetAccessRuleProtection($true, $false)

    $systemAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM", "FullControl", "Allow")
    $aclSettings.AddAccessRule($systemAccessRule)

    $adminGroup = New-Object System.Security.Principal.NTAccount("BUILTIN\Administrators")
    $readRights = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute -bor 
                  [System.Security.AccessControl.FileSystemRights]::Read -bor
                  [System.Security.AccessControl.FileSystemRights]::Synchronize
    $adminReadRule = New-Object System.Security.AccessControl.FileSystemAccessRule($adminGroup, $readRights, "Allow")
    $aclSettings.AddAccessRule($adminReadRule)

    [System.IO.File]::SetAttributes($filePath, [System.IO.FileAttributes]::ReadOnly -bor [System.IO.FileAttributes]::System)

    $denyRights = [System.Security.AccessControl.FileSystemRights]::Delete -bor 
                  [System.Security.AccessControl.FileSystemRights]::Write -bor 
                  [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles -bor
                  [System.Security.AccessControl.FileSystemRights]::WriteAttributes -bor
                  [System.Security.AccessControl.FileSystemRights]::WriteExtendedAttributes -bor
                  [System.Security.AccessControl.FileSystemRights]::ChangePermissions -bor
                  [System.Security.AccessControl.FileSystemRights]::TakeOwnership

    $adminDenyRule = New-Object System.Security.AccessControl.FileSystemAccessRule($adminGroup, $denyRights, "Deny")
    $aclSettings.AddAccessRule($adminDenyRule)

    Set-Acl -Path $filePath -AclObject $aclSettings
}