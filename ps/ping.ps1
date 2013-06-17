#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#      Ping.ps1
# Description:
#     Ping a remote host. Ping is based on ActiveXperts Network Component
# Parameters:
#     1) strHost  - Hostname or IP address of the computer you want to ping
#     2) nMaxTimeOut - Timeout in milliseconds
# Usage:
#     Ping.ps1 '' Timeout_MSecs
# Sample:
#     Ping.ps1 'www.activexperts.com' 160
#################################################################################

# Parameters
param
  (
    [string]$strHost,
    [int]$numMaxTimeOut
  )

cls

# Check paramters input
if ( $strHost -eq "" -or $numMaxTimeOut -eq "" )
{
  $res = "UNCERTAIN: Invalid number of parameters - Usage: .\ping.ps1  Timeout_MSecs"
  echo $res
  exit
}

# Create ICMP object
$objIcmp = new-object -comobject ActiveXperts.Icmp
if( $objIcmp -eq $null )
{
  $res = "UNCERTAIN: Failed to load ActiveXperts.Icmp"
  echo $res
  exit
}

# Ping
$objIcmp.Ping( $strHost, 3000 )   # Maximum. timeout: 3000 ms
if( $objIcmp.LastError -ne 0 )
{
  $res = "UNCERTAIN: " + $objIcmp.GetErrorDescription( $objIcmp.LastError )
  echo $res
  exit
}

# Check duration
if( $objIcmp.LastDuration -gt $numMaxTimeOut ) 
{
  $res = "ERROR: Request from [" + $strHost + "] timed out, time=[" + $objIcmp.LastDuration + "ms] (>" + $numMaxTimeOut + "ms) DATA:" + $objIcmp.LastDuration
  echo $res
  exit
}

$res  = "SUCCESS: Reply from " + $strHost + ", time=[" + $objIcmp.LastDuration + "ms], TTL=[" + $objIcmp.LastTTL + "] DATA:" + $objIcmp.LastDuration
echo $res
exit

sleep 1000
