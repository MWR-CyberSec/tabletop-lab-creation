param(
    [string] $forestVariables
)

#This script promotes the Windows Server to a domain controller and will start the installation of a forest.

$forest = Get-Content -Raw -Path "C:\vagrant\provision\variables\${forestVariables}" | ConvertFrom-Json

echo 'Resetting the Administrator account password and settings...'
$localAdminPassword = ConvertTo-SecureString $forest.administratorPassword -AsPlainText -Force
Set-LocalUser `
    -Name Administrator `
    -AccountNeverExpires `
    -Password $localAdminPassword `
    -PasswordNeverExpires:$true `
    -UserMayChangePassword:$true

echo 'Installing the AD services and administration tools...'
Install-WindowsFeature AD-Domain-Services,RSAT-AD-AdminCenter,RSAT-ADDS-Tools

$safeModePassword = ConvertTo-SecureString $forest.safeModeAdministratorPassword -AsPlainText -Force

echo 'Installing the AD forest (be patient, this will take more than 30m to install)...'
Import-Module ADDSDeployment
# NB ForestMode and DomainMode are set to WinThreshold (Windows Server 2016).
#    see https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-functional-levels
Install-ADDSForest `
    -InstallDns `
    -CreateDnsDelegation:$false `
    -ForestMode 6 `
    -DomainMode 6 `
    -DomainName $forest.name `
    -DomainNetbiosName $forest.netbiosName `
    -SafeModeAdministratorPassword $safeModePassword `
    -NoRebootOnCompletion `
    -Force


