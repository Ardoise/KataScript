#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#     Disk-DiskDrives.ps1
# Description:
#     This function checks all disks on a computer specified by strComputer.
# Parameters:
#     1) strComputer As String  - Hostname or IP address of the computer you want to monitor
#     2) strCredentials As String - Specify an empty string to use Network Monitor service credentials.
#         To use alternate credentials, enter a server that is defined in Server Credentials table.
#         (To define Server Credentials, choose Tools->Options->Server Credentials)
# Usage:
#     .\Disk-DiskDrives.ps1 '' ''
# Sample:
#     .\Disk-DiskDrives.ps1 'localhost'
#################################################################################

#paremeters
param
(
  [string]$strComputer,
  [string]$strCredentials
)

if ( [string]$strComputer -eq "" )
{
  $res = "UNCERTAIN: Invalid number of parameters - Usage: .\Disk-DiskDrives.ps1 '' '[strCredentials]'"
  echo $res
  exit
}

$objWMIService = $null
    
if ( $strCredentials -eq "" )
{
  $objWMIService = Get-WmiObject -ComputerName $strComputer -Class Win32_DiskDrive
}
else
{
  $objNmCredentials = new-object -comobject ActiveXperts.NMServerCredentials
  $strUsername = $objNmCredentials.GetLogin($strCredentials)
  $strPassword = $objNmCredentials.GetPassword($strCredentials)

  if ( $strUsername -eq "" )
  {
    $res = "ERROR: No alternate credentials defined for [" + $strCredentials + "]. In the Manager application, select 'Options' from the 'Tools' menu and select the 'Server Credentials' tab to enter alternate credentials"
    echo $res
    exit
  }
    if($strPassword -ne "") { $strPasswordSecure = ConvertTo-SecureString -string $strPassword -AsPlainText -Force }
    $objCredentials = new-object -typename System.Management.Automation.PSCredential $strUsername, $strPasswordSecure
    $objWMIService = Get-WmiObject -ComputerName $strComputer -Class Win32_DiskDrive -Credential $objCredentials 
  }

if ($objWMIService -eq $null)
{
  $res = "ERROR: Unable to access '" + $strComputer + "'. Possible reasons: no WMI installed on the remote server, no rights to access remote WMI service, or remote server down"
  echo $res
  exit
}  

if ( $objWMIService.Count -le 0 )
{
  $res = "ERROR: No disks on computer [" + $strComputer + "]"
  echo $res
  exit
}

Foreach ($x in $objWMIService)
{
  if ( $x.Status -eq "OK" )
  {
    $goodDisks = $goodDisks + $x.Caption + ","
  }
  else
  {
    $badDisks = $badDisks + "Status of Disk[" + $x.Caption + "] is: [" + $x.Status + "], "
  } 
}

if ( $badDisks -eq $null )
{
  $res = "SUCCESS: All the disks are OK; disks checked=" + $goodDisks
  echo $res
  exit
}
elseif ($goodDisks -eq $null)
{
  $res = "ERROR: All the disks are not working; disks checked=" + $badDisks
  echo $res
  exit
}
else
{
  $res = "ERROR: Some disks are not working; BAD DISKS=[" + $badDisks + "]; GOOD DISKS=[" + $goodDisks + "]"
  echo $res
  exit
}
