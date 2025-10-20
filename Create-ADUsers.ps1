<#
.SYNOPSIS
    Bulk Active Directory User Creation Script
.DESCRIPTION
    Reads a CSV file and creates AD users with default settings.
    Assigns groups, sets initial password, and logs results.
.AUTHOR
    Atif Khan
#>

# Import Active Directory module
Import-Module ActiveDirectory

# CSV format: FirstName,LastName,Username,OU,Group
$users = Import-Csv -Path ".\users.csv"

# Default password
$DefaultPassword = ConvertTo-SecureString "Welcome@123" -AsPlainText -Force

foreach ($user in $users) {
    $Name = "$($user.FirstName) $($user.LastName)"
    $Sam = $user.Username
    $OU = $user.OU
    $Group = $user.Group

    try {
        # Create AD user
        New-ADUser -Name $Name `
                   -SamAccountName $Sam `
                   -UserPrincipalName "$Sam@domain.com" `
                   -Path $OU `
                   -AccountPassword $DefaultPassword `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true

        # Add to group
        Add-ADGroupMember -Identity $Group -Members $Sam

        # Log success
        Add-Content -Path "ADUserCreation.log" -Value "$(Get-Date): Created $Name in $OU and added to $Group"
        Write-Host "✅ Created $Name and added to $Group"
    }
    catch {
        # Log failure
        Add-Content -Path "ADUserCreation.log" -Value "$(Get-Date): Failed to create $Name - $($_.Exception.Message)"
        Write-Host "❌ Failed to create $Name"
    }
}