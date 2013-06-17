#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script:
#     Memory-CheckCommittedMemory.ps1
# Description: 
#     Check free memory (MB) on the computer specified by strComputer
# Parameters:
#     1) strComputer As String - Hostname or IP address of the computer you want to check
#     2) nMaxCommittedMB  As Number - Maximum allowed committed memory (in MB)
#     3) strCredentials As String - Specify an empty string to use Network Monitor service credentials.
#         To use alternate credentials, enter a server that is defined in Server Credentials table.
#         (To define Server Credentials, choose Tools->Options->Server Credentials)
# Usage:
#     .\Memory-CheckCommittedMemory.ps1 ''  ' | <>'
# Sample:
#     .\Memory-CheckCommittedMemory.ps1 'localhost' 800 ''
#################################################################################

# Parameters
param
  (
    [string]$strComputer,
    [int]$nMaxMB,
    [string]$strAltCredentials
  )

cls

# Check paramters input
if ( ([string]$strComputer -eq "") -or ([int]$nMaxMB -eq 0) )
{
  echo "UNCERTAIN: Invalid number of parameters - Usage: .\Memory-CheckCommittedMemory.ps1 ''  ' | <>'"
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

$nCommittedMB = [math]::round(($objMem.CommittedBytes / (1024 * 1024)),0)

$nDiffMB = $nMaxMB - $nCommittedMB

if ( $nDiffMB -gt 0 )
{
  $res = "SUCCESS: "
}
else
{
  $res = "ERROR: "
}

$res = $res + "Committed memory=[" + $nCommittedMB + " MB], maximum allowed=[" + $nMaxMB + " MB]"
echo $res
exit
