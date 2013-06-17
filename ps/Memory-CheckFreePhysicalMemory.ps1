#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script:
#     Memory-CheckFreePhysicalMemory.ps1
# Description:
#     Checks memory usage on a (remote) computer
# Parameters:
#     1) strComputer (string)  - Hostname or IP address of the computer you want to monitor
#     2) strFlagFree (string)  - Either 'free' or 'used'
#     3) numLimitMB (number)   - Limit, in MB
#     4) strAltCredentials (string, optional) - Alternate credentials
# Usage:
#     .\Memory-CheckFreePhysicalMemory.ps1 '' ' | used>' MBs ' | <>'
# Sample:
#     .\Memory-CheckFreePhysicalMemory.ps1 'localhost' 'free' 50
#################################################################################

# Parameters
param
  (
    [string]$strComputer,
    [string]$strFlagFree,
    [int]$numLimitMB,
    [string]$strAltCredentials
  )

cls

# Check paramters input
if ( ([string]$strComputer -eq "") -or ([string]$strFlagFree -eq "") -or ($numLimitMB -eq "") )
{
  echo "UNCERTAIN: Invalid number of parameters - Usage: .\memory.ps1  |  [alt-credentials]"
  exit
}

# Create object
if ( [string]$strAltCredentials -eq ""  )
{
  $objMem = Get-WmiObject -ComputerName $strComputer -Class Win32_OperatingSystem
}
else
{
  $objNmCredentials = new-object -comobject ActiveXperts.NMServerCredentials
  $strLogin = $objNmCredentials.GetLogin( $strAltCredentials )
  $strPassword = $objNmCredentials.GetPassword( $strAltCredentials )
  
  if($strPassword -ne "") { $strPasswordSecure = ConvertTo-SecureString -string $strPassword -AsPlainText -Force }
  $objCredentials = new-object -typename System.Management.Automation.PSCredential $strLogin, $strPasswordSecure
  $objMem = Get-WmiObject -ComputerName $strComputer -Class Win32_OperatingSystem -Credential $objCredentials 
}

#################################################################################
# The script itself
#################################################################################

if ( $objMem -eq $null )
{
  $res = "UNCERTAIN: Unable to connect. Please make sure that PowerShell and WMI are both installed on the monitered system. Also check your credentials"
  echo $res
  exit
}

$freeMB = [math]::round( ( $objMem.FreePhysicalMemory / 1024 ), 0 )
$totalMB = [math]::round( ( $objMem.TotalVisibleMemorySize / 1024 ), 0 )
$usedMB = $totalMB - $freeMB

## echo "freeMB: " $freeMB
## echo "totalMB: " $totalMB
## echo "used: " $usedMB

# Free memory
if( $strFlagFree -eq "free" )
{
  if ( $freeMB -gt $numLimitMB )
  {
    $res = "SUCCESS: Free physical memory=[" + $freeMB + " MB], minimum required=[" + $numLimitMB + " MB] DATA:" + $freeMB
  }
  else
  {
    $res = "ERROR: Free physical memory=[" + $freeMB + " MB], minimum required=[" + $numLimitMB + " MB] DATA:" + $freeMB
  }
  echo $res
  exit
}

# Used memory
if( $strFlagFree -eq "used" )
{
  if ( $usedMB -lt $numLimitMB )
  {
    $res = "SUCCESS: Used physical memory=[" + $usedMB + " MB], maximum allowed=[" + $numLimitMB + " MB] DATA: " + $usedMB 
  }
  else
  {
    $res = "ERROR: Used physical memory=[" + $usedMB + " MB], maximum allowed=[" + $numLimitMB + " MB] DATA: " + $usedMB 
  }
  echo $res
  exit
}
