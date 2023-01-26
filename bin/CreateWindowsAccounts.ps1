#  CreateWindowsAccounts.ps1

#  Script that uses JSON data to create local user accounts on Windows.

#  To run this script, permissions need to be setup.
#  Set-ExecutionPolicy Bypass -Scope Process
Write-Host "Start"
#  Create the JSON data for the accounts.
$accounts_json = '
[
    {
        "description":  "Sysadmin for UCI",
        "userName":     "SysAdmin",
        "user":         "sysadmin",
        "pwd":          "cybersecurity"
    },
    {
        "description":  "Instructor Account for UCI",
        "userName":     "Instructor",
        "user":         "instructor",
        "pwd":          "instructor"
    }
]
'
Write-Host $accounts_json
#  Parse the JSON data into objects for processing.
$accounts = $accounts_json | ConvertFrom-Json

#  Create the accounts based on the objects from the JSON data.
Write-Host "Adding Local Users"
foreach ($account in $accounts) {

    Try {
        Write-Host "Searching for $($account.user) in LocalUser DataBase"
        $ObjLocalUser = Get-LocalUser $account.user
        Write-Host "$($account.user) does exist"
    }

    Catch [Microsoft.PowerShell.Commands.UserNotFoundException]
    {
        Write-Host "Adding Local User $account.user"
        New-LocalUser $account.user -Password (ConvertTo-SecureString $account.pwd -AsPlainText -Force) -FullName $account.userName -Description $account.description
    }

    Catch {
        "An unknown error occured" | Write-Error
        Exit
    }
}

Try {
    $ObjLocalGroupMember = Get-LocalGroupMember -Group Administrators -Member sysadmin
    Write-Host "sysadmin is not a group member of Administrators"
}

Catch [Microsoft.PowerShell.Commands.PrincipalNotFoundException]
{
    Write-Host "Adding sysadmin to Administrators group"
    Add-LocalGroupMember -Group Administrators -Member sysadmin
}

Catch {
    Write-Error "Another error occured"
    # Add-LocalGroupMember -Group Administrators -Member sysadmin
}

# References
#
#  https://stackoverflow.com/questions/49595003/checking-if-a-local-user-account-group-exists-or-not-with-powershell