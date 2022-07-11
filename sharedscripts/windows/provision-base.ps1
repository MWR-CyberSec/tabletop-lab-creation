param(
    [string] $zone = "en-GB"
)

if (!$zone) {
    $zone = "en-GB"
}

#This script is used to setup the base image. We essentially perform the following:
# 1. Set keyboard layout and timezone (Default is UK)
# 2. Configure the VM with the windows activation trail license, which will be valid for 30 days.
# 3. Create a scheduled task to set the DNS of the system
# 4. Disable password reset dates, which would have caused the VM to break after 3 months.

# set keyboard layout.
# NB you can get the name from the list:
#      [Globalization.CultureInfo]::GetCultures('InstalledWin32Cultures') | Out-GridView
Set-WinUserLanguageList $zone -Force

# set the date format, number format, etc.
Set-Culture $zone

# set the welcome screen culture and keyboard layout.
# NB the .DEFAULT key is for the local SYSTEM account (S-1-5-18).
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-Null
'Control Panel\International','Keyboard Layout' | ForEach-Object {
    Remove-Item -Path "HKU:.DEFAULT\$_" -Recurse -Force
    Copy-Item -Path "HKCU:$_" -Destination "HKU:.DEFAULT\$_" -Recurse -Force
}

# set the timezone.
# tzutil /l lists all available timezone ids
& $env:windir\system32\tzutil /s "GMT Standard Time"

# We need to enable the Windows License Manager Service for the next step to work (licensing keys will fail otherwise)
if (Get-Service LicenseManager -ErrorAction SilentlyContinue) {
    Set-Service -Name LicenseManager -StartupType Automatic
    Stop-Service LicenseManager
    Start-Service LicenseManager
}

# In order to make licensing and auto-activation work on Hyper-V, we set the edition to ServerStandard
# and then we pick the right key from: 
# https://docs.microsoft.com/en-us/windows-server/get-started-19/vm-activation-19
#
# Taken from: https://cm.ahnat.pl/windows-2012-r2-activation-0xc004f069/:#
# - Get current edition: dism /online /Get-CurrentEdition
# - Get available editions: dism /online /Get-TargetEditions
If ((Get-WmiObject -class Win32_OperatingSystem).Caption.Contains('2012')) {
    dism /NoRestart /online /Set-Edition:ServerStandard /AcceptEULA /ProductKey:DBGBW-NPF86-BJVTX-K3WKJ-MTB6V
} ElseIf ((Get-WmiObject -class Win32_OperatingSystem).Caption.Contains('2016')) {
    dism /NoRestart /online /Set-Edition:ServerStandard /AcceptEULA /ProductKey:C3RCX-M6NRP-6CXC9-TW2F2-4RHYD
} ElseIf ((Get-WmiObject -class Win32_OperatingSystem).Caption.Contains('2019')) {
    # for some reason on windows 2019 we have to do the edition upgrade using the KMS key and then set the real AVMA key later
    dism /NoRestart /online /Set-Edition:ServerStandard /AcceptEULA /ProductKey:N69G4-B89J2-4G8F4-WWYCC-J464C
}

# Disable password expiry
net accounts /maxpwage:unlimited

# This is ESSENTIAL to prevent domains from breaking after 3 months!!!
# !!!!!!!!!!!!!!!!!!!! DO NOT REMOVE !!!!!!!!!!!!!!!!!!!!!!!!!
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name DisablePasswordChange -Value 1
