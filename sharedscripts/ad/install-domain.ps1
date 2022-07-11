param(
    [string]$domainVariables,
    [string]$parentDomainVariables
)

$domain = Get-Content -Raw -Path "C:\vagrant\provision\variables\${domainVariables}" | ConvertFrom-Json
$parent = Get-Content -Raw -Path "C:\vagrant\provision\variables\${parentDomainVariables}" | ConvertFrom-Json

# Configure DNS to point to parent DC
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration
if ($adapters) {
    $adapters | ForEach-Object {$_.SetDNSServerSearchOrder($parent.dcIPAddress)}
}

echo 'Resetting the Administrator account password and settings...'
$localAdminPassword = ConvertTo-SecureString $domain.administratorPassword -AsPlainText -Force
Set-LocalUser `
    -Name Administrator `
    -AccountNeverExpires `
    -Password $localAdminPassword `
    -PasswordNeverExpires:$true `
    -UserMayChangePassword:$true

echo 'Installing the AD services and administration tools...'
Install-WindowsFeature AD-Domain-Services,RSAT-AD-AdminCenter,RSAT-ADDS-Tools

$parentPassword = ConvertTo-SecureString $parent.administratorPassword -AsPlainText -Force
$parentDA =  $parent.name + "\Administrator" 
$parentCredentials = New-Object System.Management.Automation.PSCredential($parentDA, $parentPassword)

$safeModePassword = ConvertTo-SecureString $domain.safeModeAdministratorPassword -AsPlainText -Force

echo 'Installing the AD domain (be patient, this will take more than 30m to install)...'
Import-Module ADDSDeployment
# NB ForestMode and DomainMode are set to WinThreshold (Windows Server 2016).
#    see https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-functional-levels
Install-ADDSDomain `
    -Credential $parentCredentials `
    -NewDomainName $domain.name `
    -SafeModeAdministratorPassword $safeModePassword `
    -CreateDnsDelegation:$true `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "6" `
    -NewDomainNetbiosName $domain.netbiosName `
    -InstallDns:$true `
    -NoRebootOnCompletion:$true `
    -Force:$true `
    -ParentDomainName $parent.fqdn
