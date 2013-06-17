#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#     Rsh.ps1
# Description:
#     Run a command on a remote UNIX/LINUX machine. Success or Failure is determined by
#     the standard output of the RSH command.
#     This function uses the ActiveXperts Network Component, an ActiveXperts product.
#     ActiveXperts Network Component is automatically licensed when ActiveXperts 
#     Network Monitor is purchased
#     For more information about ActiveXperts Network Component, see: 
#       www.activexperts.com/network-component
# Parameters:
#     1) strHost - Specifies the remote host on which to run the command
#     2) strUser - Specifies ther user name to use on the remote host.If omitted, the user name
#         if the Network Monitor service is used.
#     3) strCommand - Specifies the command to run
#     4) numTimeOut - Specifies how long (in milliseconds) to wait for the completion of the command
#     5) strPattern - Text pattern to search for in the standard output.
# Usage:
#      .\Rsh.ps1 '' '' ''  ''
# Sample:
#      .\Rsh.ps1 'unix03', 'admin', 'ls -l /dev', 10000, 'floppy' 
#################################################################################

#parameters
param
(
  [string]$strHost,  
  [string]$strUser,
  [string]$strCommand,
  [int]$nTimeOut,
  [string]$strPattern
)

if ( ([string]$strHost -eq "") -or
     ([string]$strUser -eq "") -or
     ([string]$strCommand -eq "") -or
     ([int]$nTimeOut -eq "") -or
     ([string]$strPattern -eq "")
   )
{
  $res = "UNCERTAIN: Invalid number of parameters - Usage: .\Rsh.ps1 '' '' ''  ''"
  echo $res
  exit
}

$objRsh = new-object -comobject ActiveXperts.Rsh

$objRsh.Clear()
$objRsh.Host = $strHost
$objRsh.UserName = $strUser
$objRsh.Command = $strCommand
$objRsh.ScriptTimeOut = $nTimeOut

$objRsh.Run()

if ( $objRsh.LastError -ne 0 )
{
  $res = "UNCERTAIN: #" + $objRsh.LastError + " : " + $objRsh.GetErrorDescription( $objRsh.LastError )
  echo $res
  exit
}

if ( $objRsh.StdErr -ne "" -and $objRsh.StdOut -eq "" )
{
  if ( $objRsh.stdErr.Length > 200 )
  {
    $res = "UNCERTAIN: Standard Error: " + $objRsh.StdErr.substring(0,200)
    echo $res
  }
  else
  {
    $res = "UNCERTAIN: Standard Error: " + $objRsh.StdErr
    echo $res
  }
  exit
}

if ( $objRsh.StdOut.contains($strPattern) -eq 1 )
{
  $res = "SUCCESS: Pattern[" + $strPattern + "] matched in RSH Standard Output"
  echo $res
  exit
}
else
{
  $res = "ERROR: Pattern[" + $strPattern + "] not matched in RSH Standard Output"
  echo $res
  exit
}
