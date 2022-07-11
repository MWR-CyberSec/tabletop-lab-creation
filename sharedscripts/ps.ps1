param(
    [Parameter(Mandatory=$true)]
    [string]$script,

    [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)]
    [string[]]$scriptArguments
)
#This is a basic vagrant script that can be used to execute other scripts. It will add the vagrant directory to the execution path, allowing other scripts to be loaded.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
trap {
    Write-Output "ERROR: $_"
    Write-Output (($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1')
    Write-Output (($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1')
    Exit 1
}

Set-Location C:\vagrant

$script = Resolve-Path $script

Set-Location (Split-Path -Parent $script)

Write-Host "Running $script..."

. ".\$(Split-Path -Leaf $script)" @scriptArguments
