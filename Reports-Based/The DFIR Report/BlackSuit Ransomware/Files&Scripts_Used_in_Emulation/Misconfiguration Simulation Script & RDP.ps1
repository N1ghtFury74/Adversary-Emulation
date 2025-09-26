# Simulating Misconfigurations for Educational Purposes
Write-Output "Applying misconfigurations for educational purposes..."

# 1. Reduce Password Complexity Requirements (Temporarily)
Write-Output "Reducing password complexity requirements..."
try {
    Set-ADDefaultDomainPasswordPolicy -Identity "DC=corp,DC=local" -ComplexityEnabled $false -MinPasswordLength 4 -ErrorAction Stop
    Write-Output "Password complexity requirements reduced successfully."
} catch {
    Write-Output "Failed to update password complexity policy: $_"
}

# 2. Remote Process Execution: Enable WinRM and Configure Trusted Hosts
Write-Output "Configuring WinRM for remote PowerShell execution..."
try {
    Enable-PSRemoting -Force
    $trustedHosts = (Get-Item -Path wsman:\localhost\Client\TrustedHosts).Value
    if ($trustedHosts -ne "*") {
        Set-Item -Path wsman:\localhost\Client\TrustedHosts -Value "*" -Force
        Write-Output "TrustedHosts updated to allow all hosts."
    } else {
        Write-Output "TrustedHosts already configured to allow all hosts."
    }
} catch {
    Write-Output "Failed to configure WinRM or TrustedHosts: $_"
}

# 3. Allow WMI Remote Access and Open TCP Port 135
Write-Output "Allowing WMI remote access and opening TCP port 135..."
if (-not (Get-NetFirewallRule -DisplayName "Allow WMI Access" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName "Allow WMI Access" -Direction Inbound -Protocol TCP -LocalPort 135 -Action Allow
    Write-Output "Firewall rule for WMI access added."
} else {
    Write-Output "Firewall rule for WMI access already exists."
}

# 4. Enable SMB (TCP 445) and Ensure Administrative Shares are Accessible
Write-Output "Enabling SMB and verifying administrative shares..."
Set-SmbServerConfiguration -EnableSMB2Protocol $true -Confirm:$false
if (-not (Get-NetFirewallRule -DisplayName "Allow SMB Access" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName "Allow SMB Access" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow
    Write-Output "Firewall rule for SMB access added."
} else {
    Write-Output "Firewall rule for SMB access already exists."
}

Write-Output "Verifying administrative shares (C$, ADMIN$, IPC$)..."
Get-SmbShare | Where-Object { $_.Name -in "ADMIN$", "C$", "IPC$" }

# 5. AS-REP Roasting: Disable Kerberos Preauthentication for a Single Target Account
Write-Output "Disabling Kerberos preauthentication for a single target account..."
Import-Module ActiveDirectory

$accountName = "svc-legacyapp"
$account = Get-ADUser -Filter "SamAccountName -eq '$accountName'" -Properties userAccountControl -ErrorAction SilentlyContinue
if (-not $account) {
    Write-Output "Account not found: $accountName. Creating the account..."
    New-ADUser -Name $accountName -SamAccountName $accountName `
        -UserPrincipalName "$accountName@corp.local" `
        -AccountPassword (ConvertTo-SecureString "12345!" -AsPlainText -Force) `
        -Enabled $true -Path "CN=Users,DC=corp,DC=local" -Description "Account for legacy application"
    Write-Output "Account created: $accountName"
    $account = Get-ADUser -Filter "SamAccountName -eq '$accountName'" -Properties userAccountControl
}

if ($account.userAccountControl -band 4194304) {
    Write-Output "Preauthentication already disabled for account: $($account.SamAccountName)"
} else {
    Write-Output "Disabling Kerberos preauthentication for account: $($account.SamAccountName)"
    $newUserAccountControl = $account.userAccountControl -bor 4194304
    Set-ADUser -Identity $account.SamAccountName -Replace @{userAccountControl=$newUserAccountControl}
}

# 6. Kerberoasting: Configure SPNs for Service Accounts
Write-Output "Registering SPNs for service accounts..."
$serviceAccountsForSPNs = @(
    @{Name="svc-fileshare"; SPN="CIFS/fs.corp.local"},
    @{Name="svc-backup"; SPN="BACKUP/backup.corp.local"}
)

foreach ($serviceAccount in $serviceAccountsForSPNs) {
    $account = Get-ADUser -Filter "SamAccountName -eq '$($serviceAccount.Name)'" -ErrorAction SilentlyContinue
    if (-not $account) {
        Write-Output "Account not found: $($serviceAccount.Name). Creating the account..."
        New-ADUser -Name $serviceAccount.Name -SamAccountName $serviceAccount.Name `
            -UserPrincipalName "$($serviceAccount.Name)@corp.local" `
            -AccountPassword (ConvertTo-SecureString "12345!" -AsPlainText -Force) `
            -Enabled $true -Path "CN=Users,DC=corp,DC=local" -Description "Service account for $serviceAccount.Name role"
        Write-Output "Account created: $($serviceAccount.Name)"
        $account = Get-ADUser -Filter "SamAccountName -eq '$($serviceAccount.Name)'"
    }

    if ($account) {
        Write-Output "Registering SPN $($serviceAccount.SPN) for account: $($serviceAccount.Name)"
        if (-not (Get-ADUser -Filter "ServicePrincipalName -eq '$($serviceAccount.SPN)'" -ErrorAction SilentlyContinue)) {
            setspn -A $serviceAccount.SPN $serviceAccount.Name
        } else {
            Write-Output "SPN $($serviceAccount.SPN) already registered."
        }

        # Add svc-fileshare to Domain Admins if applicable
        if ($serviceAccount.Name -eq "svc-fileshare") {
            try {
                Add-ADGroupMember -Identity "Domain Admins" -Members $serviceAccount.Name
                Write-Output "Account $($serviceAccount.Name) added to Domain Admins."
            } catch {
                Write-Output "Failed to add $($serviceAccount.Name) to Domain Admins: $_"
            }
        }
    } else {
        Write-Output "Failed to create or find the account: $($serviceAccount.Name). Skipping SPN registration."
    }
}

# 7. Update an Account from IT Department with a Weak Password
Write-Output "Updating password for an IT department account..."
$itAccountName = Read-Host "Enter the SamAccountName of the IT account to update"
$itAccount = Get-ADUser -Filter "SamAccountName -eq '$itAccountName'" -Properties SamAccountName, Department -ErrorAction SilentlyContinue

if ($itAccount) {
    Write-Output "Found IT account: $($itAccount.SamAccountName). Updating password..."
    try {
        Set-ADAccountPassword -Identity $itAccount.SamAccountName -NewPassword (ConvertTo-SecureString "12345!" -AsPlainText -Force) -Reset
        Write-Output "Password updated for IT account: $($itAccount.SamAccountName)"
    } catch {
        Write-Output "Failed to update password for IT account: $_"
    }
} else {
    Write-Output "IT account not found: $itAccountName"
}

# 9. Enable LDAP Query Logging
Write-Output "Enabling LDAP query logging..."
$auditStatus = auditpol /get /subcategory:"Directory Service Access"
if ($auditStatus -notmatch "Success and Failure") {
    Write-Output "LDAP query logging not enabled. Enabling now..."
    auditpol /set /subcategory:"Directory Service Access" /success:enable /failure:enable
} else {
    Write-Output "LDAP query logging already enabled."
}

Write-Output "All misconfigurations applied successfully."
