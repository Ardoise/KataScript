#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script:
#     MsSql.ps1
# Description: 
#     Checks if MS SharePoint Server is running; it checks the SharePoint services 
#     and SharePoint processes
# Parameters:
#     1) strComputer As String - Hostname or IP address of the server you want to check
#     2) strCredentials As String - Specify an empty string to use Network Monitor service credentials.
#         To use alternate credentials, enter a server that is defined in Server Credentials table.
#         (To define Server Credentials, choose Tools->Options->Server Credentials)
# Usage:
#     .\MsSql.ps1 '' ''
# Sample:
#     .\MsSql.ps1 'localhost' ''
#################################################################################

#parameters

param
  (
    [string]$strComputer,
    [string]$strCredentials
  )
  
  ##Start Functions##
  function CheckService($strServiceName)
  {
    foreach ( $objService in $objWmi )
    {    
     if ( $objService.Name.ToLower() -eq $strServiceName.Tolower() )
     {
       return 1
       break
     }
    }
    return 0    
  }
  
  function CheckProcess($strProcessName)
  { 
    foreach ( $objProcess in $objWmi )
    {
      if( $objProcess.Name -eq $strProcessName )
      {
        return 1
        break
      }      
    }  
    return 0
  }
  ##End Functions##
  
  if ( [string]$strComputer -eq "" )
  {
    $res = "UNCERTAIN:  Invalid number of parameters - Usage: .\MsSql.ps1 '' ''"
    echo $res
    exit
  }
  
# Create object
if( [string]$strCredentials -ne ""  )
{
  $objNmCredentials = new-object -comobject ActiveXperts.NMServerCredentials
  $strLogin = $objNmCredentials.GetLogin( $strCredentials )
  
  if ($strLogin -eq "")
  {
    $res = "ERROR: No alternate credentials defined for [" + $strCredentials + "]. In the Manager application, select 'Options' from the 'Tools' menu and select the 'Server Credentials' tab to enter alternate credentials"
    echo $res
    exit
  }
  
  $strPassword = $objNmCredentials.GetPassword( $strCredentials )
  
  if ( $strPassword -ne "" ) { $strPasswordSecure = ConvertTo-SecureString -string $strPassword -AsPlainText -Force }    
  $objCredentials = new-object -typename System.Management.Automation.PSCredential $strLogin, $strPasswordSecure
}

#############################Services#######################################
if ( [string]$strCredentials -eq "" )
{
  $objWmi = Get-WmiObject -ComputerName $strComputer -Class Win32_Service -filter "state = 'running'"
}
else
{
  $objWmi = Get-WmiObject -ComputerName $strComputer -Class Win32_Service -Credential $objCredentials -filter "state = 'running'"
}

if ( $objWmi -eq $null )
{
  $res = "UNCERTAIN: Win32_Service class does not exist on computer [" + $strComputer + "]"
  echo $res
  exit
}

$bResult = CheckService "MSSQLSERVER" 
if ( $bResult -eq 0 )
{
  $res = "ERROR: Service: MSSQLSERVER (SQL Server) is not running on server[" + $strComputer + "]"
  echo $res
  exit
}

$bResult = CheckService "SQLSERVERAGENT" 
if ( $bResult -eq 0 )
{
  $res = "ERROR: Service: SQLSERVERAGENT (SQL Server Agent) is not running on server[" + $strComputer + "]"
  echo $res
  exit
}


#############################Processes#######################################
 

if ( [string]$strCredentials -eq "" )
{
  $objWmi = Get-WmiObject -ComputerName $strComputer -Class Win32_Process
}
else
{
  $objWmi = Get-WmiObject -ComputerName $strComputer -Class Win32_Process -Credential $objCredentials
}

if ( $objWmi -eq $null )
{
  $res = "UNCERTAIN: Win32_Process class does not exist on computer [" + $strComputer + "]"
  echo $res
  exit
}

$bResult = CheckProcess("sqlservr.exe") 
if ( $bResult -eq 0 )
{
  $res = "ERROR: Process: sqlservr.exe is not running on server[" + $strComputer + "]"
  echo $res
  exit
} 

$bResult = CheckProcess("sqlagent.exe") 
if ( $bResult -eq 0 )
{
  $res = "ERROR: Process: sqlagent.exe is not running on server[" + $strComputer + "]"
  echo $res
  exit
} 

if ( $bResult -eq 1 )
{
  $res = "SUCCESS: All processes and services are running"
  echo $res
  exit
}
