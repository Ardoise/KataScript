#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#     DNS.ps1
# Description: 
#     Query a DNS server, and validate the response
#     This function uses the ActiveXperts Network Component, an ActiveXperts product.
#     ActiveXperts Network Component is automatically licensed when ActiveXperts 
#     Network Monitor is purchased
#     For more information about ActiveXperts Network Component, see: 
#       www.activexperts.com/network-component
# Parameters:
#     1) strDnsServer - Host name or IP address of the (remote) DNS server
#     2) strHost - Hostname or domain to query
#     3) strExpectedValue - expected value 
# Usage:
#     .\DNS.ps1 '' 'host' ''
# Sample:
#     .\DNS.ps1 'ns1.ascio.net' 'smpp.activexperts-labs.com' '84.53.114.73'
#################################################################################

# Parameters
param
  (
    [string]$strDnsServer,
    [string]$strHost,
    [string]$strExpectedValue
  )

cls

# Check paramters input
if ( ([string]$strDnsServer -eq "") -or 
     ([string]$strHost -eq "") -or 
     ([string]$strExpectedValue -eq "") 
   )
{
  echo "UNCERTAIN: Invalid number of parameters - Usage: .\DNS.ps1   "
  exit
}

# Create object
$objDnsServer = new-object -comobject ActiveXperts.DnsServer
$objConstants = new-object -comobject ActiveXperts.ASConstants


#################################################################################
# THE SCRIPT ITSELF
#################################################################################
  
$SYSDATA = ""
$bMatched = $false

# Lookup
$objDnsServer.Server = $strDnsServer
$objDnsServer.Lookup( $strHost, $objConstants.asDNS_TYPE_A )

if ( $objDnsServer.LastError -ne 0 )
{
  return "UNCERTAIN: Unable to connect to query [" + $strDnsServer + "]"
  exit
}  

$objDnsRecord = $objDnsServer.GetFirstRecord()

while ( $objDnsServer.LastError -eq 0 )
{
  if( $objDnsRecord.Name -eq $strHost ) 
  {
    if ( $SYSDATA -ne "" )
    {
      $SYSDATA = $SYSDATA + "; " 
    }  
    $SYSDATA = $SYSDATA + $objDnsRecord.Address
    if ( $objDnsRecord.Address -eq $strExpectedValue )
    {
      $bMatched = $true
    }
  }
  $objDnsRecord = $objDnsServer.GetNextRecord()
}
  
if ( $bMatched -eq $true )
{
  $res = "SUCCESS: Response matched; DATA = " + $SYSDATA
  echo $res
  exit
}  
else
{
  $res = "ERROR: Response did not match; DATA = " + $SYSDATA
  echo $res
  exit
}  
