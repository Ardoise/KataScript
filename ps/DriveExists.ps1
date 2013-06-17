#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#     DriveExists.ps1
# Description:
#     Checks for the existence of the specified drive letter
# Parameters:
#     1) strDrive (string)  - Hostname or IP address of the computer you want to monitor
# Usage:
#     .\DriveExists.ps1 ''
# Sample:
#     .\DriveExists.ps1 'c:'
#################################################################################

# Parameters
param
  (
    [string]$strDrive
  )

cls

# Check paramters input
if( [string]$strDrive -eq "" )
{
  echo "UNCERTAIN: Invalid number of parameters - Usage: .\DriveExists.ps1 "
  exit
}
  
#################################################################################
# Functions
#################################################################################
  
function Exists-Drive 
{
  param($driveletter) 
  (New-Object System.IO.DriveInfo($driveletter)).DriveType -ne 'NoRootDirectory'   
} 

  
#################################################################################
# THE SCRIPT ITSELF
#################################################################################

if( Exists-Drive $strDrive )
{
  $succ = "SUCCESS: Drive " + $strDrive + " does exist DATA: 1"
  echo $succ
}
else
{
  $err = "ERROR: Drive " + $strDrive + " does exist DATA: 0"
  echo $err
}   
