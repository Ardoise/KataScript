#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#     DirectorySize.ps1
# Description:
#     Checks the size of the specified folder
# Parameters:
#     1) strComputer (string)  - Hostname or IP address of the computer you want to monitor
#     2) strDirectory (string) - The directory we want to check
#     3) numLimitMB (number)   - Limit, in MB
# Usage:
#     .\DirectorySize.ps1 '' '' '' MBs
# Sample:
#     .\DirectorySize.ps1 'localhost' 'C:\TEMP' 50
#################################################################################

# Parameters
param
  (
    [string]$strComputer,
    [string]$strDirectory,
    [double]$numLimitMB
  )

cls

# Check paramters input
if ( ([string]$strComputer -eq "") -or 
     ([string]$strDirectory -eq "") -or 
     ($numLimitMB -eq "")
   )
{
  echo "UNCERTAIN: Invalid number of parameters - Usage: .\DirecotrySize.ps1   "
  exit
}
  
#Check Path 
if ( !(Test-Path $strDirectory) )
{
  echo "UNCERTAIN: Path not found"
  exit
}
   
#################################################################################
# THE SCRIPT ITSELF
#################################################################################

$colItems = (Get-ChildItem $strDirectory -recurse | Measure-Object -property length -sum)
$size = $colItems.sum / 1MB

if ( $size  -le $numLimitMB )
{
  $succ = "SUCCESS: Directory size = " + $size + " MB, maximum allowed = " + $numLimitMB + " MB DATA:" + $numLimitMB
  echo $succ
}
else
{
  $err = "ERROR: Directory size = " + $size  + " MB maximum allowed = " + $numLimitMB + " MB DATA:" + $numLimitMB
  echo $err
}
