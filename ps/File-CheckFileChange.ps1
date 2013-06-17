#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#     File-CheckFileChange.ps1
# Description:
#     Checks if the specified file exists
# Parameters:
#     1) strPath - UNC formatted file path
#     2) strCredentials As String - Specify an empty string to use Metwork Monitor service credentials.
#         To use alternate credentials, enter a server that is defined in Server Credentials table.
#         (To define Server Credentials, choose Tools->Options->Server Credentials)' Usage:
# Usage:
#      .\File-CheckFileChange.ps1 '<\\Server\Share\Path>' '[altCredentials]'
# Sample:
#      .\File-CheckFileChange.ps1 '\\localhost\c$\windows\windowsupdate.log'
#################################################################################

# Parameters
param
  (
    [string]$strFileName,
    [string]$strAltCredentials
  )

cls


# Check paramters input
if ( [string]$strFileName -eq "" )
{
  echo "UNCERTAIN: Invalid number of parameters - Usage: .\File-CheckFileChange.ps1 '<\\Server\Share\Path>' '[strAltCredentials]'"
  exit
}

# Create object
if ( [string]$strAltCredentials -eq ""  )
{
  $exists = Test-Path $strFileName
}
else
{
  $objCredentials = new-object -comobject ActiveXperts.NMServerCredentials
  $objRemoteServer = new-object -comobject ActiveXperts.RemoteServer
  
  $strUsername = $objCredentials.GetLogin($strAltCredentials)
  $strPassword = $objCredentials.GetPassword($strAltCredentials)
  
  if ( $strUsername -eq "" )
  {
    $res = "UNCERTAIN: No alternate credentials defined for [" + $strAltCredentials + "]. In the Manager application, select 'Options' from the 'Tools' menu and select the 'Server Credentials' tab to enter alternate credentials"
    echo $res
    exit
  }
  
  $objRemoteServer.Connect($strAltCredentials,$strUsername,$strPassword)
  
  if ( $objRemoteServer.LastError -ne 0 )
  {
    $res = "UNCERTAIN: Login failed"
    echo $res
    exit
  }        

  $exists = Test-Path $strFileName
}


#################################################################################
# THE SCRIPT ITSELF
#################################################################################


# Checks for the file existance
if ( !($exists) )
{
  $res = "ERROR: File " + $strFileName + " does not exist."
  echo $res
  exit
}  

#Get file name  
$strPlainFile = $strFileName.Split("\")
$strPlainFile = $StrplainFile[$strPlainFile.Count -1]

#set Wscript.Shell object
$objWshShell = new-object -comobject WScript.Shell

#Get new moddate from file
$strModDate = Get-Item $strFileName | select LastWriteTime
$strModDate = $strModDate.LastWriteTime.ToString("MM/dd/yyyy h:mm:ss tt" )

try
{
  #Get cached moddate from registery
  $strPrevModDate = $objWshShell.RegRead("HKLM\Software\ActiveXperts\Network Monitor\Server\VBScript_Cache\" + $strPlainFile)
  $objWshShell.RegWrite("HKLM\Software\ActiveXperts\Network Monitor\Server\VBScript_Cache\" + $strPlainFile, $strModDate, "REG_SZ")
}
catch
{
  $res = "UNCERTAIN: File was not monitored before"
  $objWshShell.RegWrite("HKLM\Software\ActiveXperts\Network Monitor\Server\VBScript_Cache\" + $strPlainFile, $strModDate, "REG_SZ")
  echo $res
  exit
}

if ( $strModDate -ne $strPrevModDate )
{
  $res = "ERROR: File has changed since last check"
  echo $res
  exit
}
else
{
  $res = "SUCCESS: File has not changed since last check"
  echo $res
  exit
}

