param(
    [string]
    [Parameter(Mandatory = $true, Position=0)]
    $domainVariables,

    [string[]]
    [Parameter(Position=1, ValueFromRemainingArguments)]
    $files
)
#This script will take JSON input for new AD objects and will create them. Support for the following objects is currently available:
# * OUs
# * Groups
# * AD Users
# ** Name
# ** Department
# ** Title
# ** SPN Bit
# * Group Members

# Required for Win2016 which takes ages to load
Sleep 300

$domain = Get-Content -Raw -Path "C:\vagrant\provision\variables\${domainVariables}" | ConvertFrom-Json

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    throw "Module ActiveDirectory not Installed"
}

foreach ($file in $files) {
    $objects = Get-Content -Raw -Path "C:\vagrant\provision\variables\${file}" | ConvertFrom-Json
    foreach ($object in $objects.objects) {
        $path = $object.path + $domain.dn

        if ($object.type -eq "ou") {
            $name = $object.name
            $ou = Get-ADOrganizationalUnit -Filter { name -eq $name }
            if ($ou -and $ou.distinguishedname.EndsWith($name + "," + $path)) {
                echo "${name} already exists."
                continue
            }

            New-ADOrganizationalUnit -Name $object.name -Path $path
        } elseif ($object.type -eq "group") {
            $name = $object.name
            if ([bool] (Get-ADGroup -Filter { samAccountName -eq $name })) {
                echo "${name} already exists."
                continue
            }

            New-ADGroup `
                -Name $object.name `
                -SamAccountName $object.name `
                -DisplayName $object.name `
                -Path $path `
                -GroupScope Global
        } elseif ($object.type -eq "user") {
            $username = $object.username
            if ([bool] (Get-ADUser -Filter { samAccountName -eq $username })) {
                echo "${username} already exists."
                continue
            }

            $optional = @{}
            if ($object | Get-Member first) {
                $optional['GivenName'] = $object.first
                $optional['Surname'] = $object.last
                $optional['DisplayName'] = $object.first + " " + $object.last
            }

            if ($object | Get-Member department) {
                $optional['Department'] = $object.department
            }

            if ($object | Get-Member title) {
                $optional['Title'] = $object.title
            }            

            if ($object | Get-Member spn) {
                $spnFQDN = $object.spn + "." + $domain.fqdn
                $optional['ServicePrincipalNames'] = @($object.spn, $spnFQDN)
            }

            $password = ConvertTo-SecureString $object.password -AsPlaintext -Force
		    echo $object
		    echo $object.username

            New-ADUser `
                -Name $object.username `
                -SamAccountName $object.username `
                -Path $path `
                -Enabled $true `
                -AccountPassword $password `
                @optional

            if ($object | Get-Member groups) {
                foreach ($group in $object.groups) {
                    Add-ADGroupMember -Identity $group -Members $object.username
                }
            }
        } else {
            echo "Unknown object type."
        }
    }
}
