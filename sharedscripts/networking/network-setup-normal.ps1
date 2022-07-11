#DNS Update Script version 1.5

$ip = (Get-NetAdapter | Get-NetIPAddress | ? addressfamily -eq 'IPv4').ipaddress
$firstOctet = $ip.split(".")[0]
$secondOctet = $ip.split(".")[1]
$thirdOctet = $ip.split(".")[2]

$dnsip = "$firstOctet.$secondOctet.$thirdOctet.101"
$index = Get-NetAdapter -Name 'Ethernet*' | Select-Object -ExpandProperty 'ifIndex'
Set-DnsClientServerAddress -InterfaceIndex $index -ServerAddresses $dnsip
