#DNS updates for DC

$ip = (Get-NetAdapter | Get-NetIPAddress | ? addressfamily -eq 'IPv4').ipaddress
$firstOctet = $ip.split(".")[0]
$secondOctet = $ip.split(".")[1]
$thirdOctet = $ip.split(".")[2]
$fourthOctet = $ip.split(".")[3]

#Import our file with DNS entries for the DC
Import-CSV -Path C:\dns_entries.csv | ForEach-Object {
    Remove-DnsServerResourceRecord -ZoneName "za.example.loc" -RRType "A" -Name $_.Hostname -force
    $hostfullIP = "$firstOctet.$secondOctet.$thirdOctet." + $_.IPEnd
    Add-DnsServerResourceRecordA -Name $_.Hostname -ZoneName "za.example.loc" -IPv4Address $hostfullIP
}

#All done, now we can set the DNS of our actual DC as well
$dnsip = "$firstOctet.$secondOctet.$thirdOctet.$fourthOctet"

#Update our DNS server
Remove-DnsServerResourceRecord -ZoneName "za.example.loc" -RRType "A" -Name "za.example.loc" -force
Add-DNSServerResourceRecordA -Name "za.example.loc" -ZoneName "za.example.loc" -IPv4Address $dnsip

$index = Get-NetAdapter -Name 'Ethernet*' | Select-Object -ExpandProperty 'ifIndex'
Set-DnsClientServerAddress -InterfaceIndex $index -ServerAddresses $dnsip
