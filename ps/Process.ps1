#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script:
#     Process.ps1
# Description:
#     Checks if a process, specified by strProcess, is running on the machine specified by strComputer. 
# Parameters:
#     1) strProcess As String - Name of the process
# Usage:
#     .\Process.ps1 ''
# Sample:
#     .\Process.ps1 'winlogon'
#################################################################################

# Parameters
param
  (
    [string]$strProcess
  )

cls

$succ = "SUCCESS: The process (" + $strProcess + ") was found  DATA: 1"
$err = "ERROR: The process (" + $strProcess + ") was not found  DATA: 0"

# Check parameters input
if ( [string]$strProcess -eq "")
{
  echo "UNCERTAIN: Invalid number of parameters - Usage: .\Process.ps1 "
  exit
}

#################################################################################
# THE SCRIPT ITSELF
#################################################################################
 
$found = 0;

Get-Process | ForEach-Object {  if ( $_.ProcessName -eq $strProcess ) 
                                { 
                                  $found = $found + 1
                                } 
                                else 
                                { 
                                  $found = $found
                                } 
                              }

if ( $found -gt 0 )
{
  $succ
  exit
}
else
{
  $err
  exit
}
