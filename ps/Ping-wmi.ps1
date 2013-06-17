#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#      Ping-wmi.ps1
# Description:
#      Ping a remote host.
# Parameters:
#      1) strComputer (string)  - Hostname or IP address of the computer you want to monitor
# Usage:
#      .\Ping-wmi.ps1 ''
# Sample:
#      .\Ping-wmi.ps1 'localhost'
#################################################################################

# Parameters
param
  (
    [string]$strHost
  )

cls

# Check parameters input
if ( $strHost -eq "" )
{
  $res = "UNCERTAIN: Invalid number of parameters - Usage: .\ping-wmi.ps1 "
  echo $res
  exit
}


#################################################################################
# THE SCRIPT ITSELF
#################################################################################

$objPing = Gwmi Win32_PingStatus -Filter "Address ='$strHost'" | Select-Object StatusCode 
if ( $objPing -eq $null )
{
  $res = "UNCERTAIN: Failed to execute Ping"
  echo $res
  exit
}

#Check if the ping was successfull or not
if ( $objPing.StatusCode -ne 0 )
{ 
  $res = "ERROR: Destination host (" + $strHost + ") unreachble" 
  echo $res
  exit
}

$res = "SUCCESS: Ping to (" + $strHost + ") was successfull" 
echo $res  
