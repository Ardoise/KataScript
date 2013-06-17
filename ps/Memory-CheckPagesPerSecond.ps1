#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script:
#     Memory-CheckPagesPerSecond.ps1
# Description:
#     Check pages per second on the computer specified by strComputer
# Parameters:
#     1) strComputer As String - Hostname or IP address of the computer you want to check
#     2) nMaxPages As Number - Maximum pages per second allowed
#     3) strCredentials As String - Specify an empty string to use Network Monitor service credentials.
#         To use alternate credentials, enter a server that is defined in Server Credentials table.
#         (To define Server Credentials, choose Tools->Options->Server Credentials)
# Usage:
#     .\Memory-CheckPagesPerSecond.ps1 ''  ' | <>'
# Sample:
#     .\Memory-CheckPagesPerSecond.ps1 'localhost' 5 ''
#################################################################################

# Parameters
param
  (
    [string]$strComputer,
    [int]$nMaxPages,
    [string]$strAltCredentials
  )

cls

# Check paramters input
if ( ([string]$strComputer -eq "") -or ([int]$nMaxPages -eq 0) )
{
  $res = "UNCERTAIN: Invalid number of parameters - Usage: .\Memory-CheckPagesPerSecond.ps1 '' ' | <>' "
  echo $res
  exit
}

# Create object
if ( [string]$strAltCredentials -eq ""  )
{
  $objMem = Get-WmiObject -ComputerName $strComputer -Class Win32_PerfFormattedData_PerfOS_Memory
}
else
{
  $objNmCredentials = new-object -comobject ActiveXperts.NMServerCredentials
  $strLogin = $objNmCredentials.GetLogin( $strAltCredentials )
  $strPassword = $objNmCredentials.GetPassword( $strAltCredentials )
  
  if($strPassword -ne "") { $strPasswordSecure = ConvertTo-SecureString -string $strPassword -AsPlainText -Force }
  $objCredentials = new-object -typename System.Management.Automation.PSCredential $strLogin, $strPasswordSecure
  $objMem = Get-WmiObject -ComputerName $strComputer -Class Win32_PerfFormattedData_PerfOS_Memory -Credential $objCredentials 
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

$nPages = $objMem.PagesPerSec
$nDiffPages = $nMaxPages - $nPages

if ( $nDiffPages -gt 0 )
{
  $res = "SUCCESS: "
}
else
{
  $res = "ERROR: "
}

$res = $res + "Pages per second=[" + $nPages + "], maximum allowed=[" + $nMaxPages + "]"
echo $res
exit
