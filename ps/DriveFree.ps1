#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#     DriveFree.ps1
# Description:
#     Checks for the existence of the specified drive letter
# Parameters:
#     1) strDrive (string)  - Hostname or IP address of the computer you want to monitor
# Usage:
#     .\DriveFree.ps1 '' ''
# Sample:
#     .\DriveFree.ps1 'c:' 10
#################################################################################

# Parameters
param
  (
    [string]$strDrive,
    [int]$value
  )

cls


# Check paramters input
if ( ([string]$strDrive -eq "") -or ($value -eq "") )
{
  echo "UNCERTAIN: Invalid number of parameters - Usage: .\DriveFree.ps1  "
  exit
}
  
#################################################################################
# Functions
#################################################################################
  
function Exists-Drive 
{
  param($strDriveletter) 
  (New-Object System.IO.DriveInfo($strDriveletter)).DriveType -ne 'NoRootDirectory'   
} 
  
#################################################################################
# THE SCRIPT ITSELF
#################################################################################

if ( Exists-Drive $strDrive )
{
  # Checks for the available space on a drive
  $DiskDrive = GWMI -CL Win32_LogicalDisk | Where {$_.DeviceId -Eq $strDrive}
  $strDriveSpace = ( $DiskDrive.FreeSpace / 1GB ) 

  if( $strDriveSpace -gt $value )
  {
    $succ = "SUCCESS: Available drive space is " + $strDriveSpace + " GB, minimum allowed= " + $value + " GB DATA: " + $strDriveSpace
    echo $succ
  }
  else
  {
    $err = "ERROR: Available drive space is " + $strDriveSpace + " GB, minimum allowed= " + $value + " GB DATA: " + $strDriveSpace
    echo $err
  }
}
else
{
  $err = "UNCERTAIN: Drive " + $strDrive + " does not exist DATA: 0"
  echo $err
}   

