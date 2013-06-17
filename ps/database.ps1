#################################################################################
# ActiveXperts Network Monitor PowerShell script, � ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at http://www.activexperts.com
#################################################################################
# Script
#     Database.ps1
# Description:
#     Check a database by counting the number of records. When this count is less than expected, it is 
#     considered as error
# Parameters:
#     1) strConnectionString As String - An OLE/DB connection string
#     2) strTable As String - Table that will be checked
#     3) nMinimumCount As Number - Minimum number of records required in the database table
# Usage:
#     .\Database.ps1 <ConnectionString> <Table> [nMinimumCount]
# Sample:
#     .\Database.ps1 'DRIVER=Microsoft Access Driver (*.mdb);DBQ=C:\Program Files\ActiveXperts\Network Monitor\Samples\Northwind.mdb' 'Customers' 1
#################################################################################

#parameters

param
(
  [string]$strConnectionString,
  [string]$strTable,
  [int]$nMinimumCount
)

if(
  ([string]$strConnectionString -eq "") -or
  ([string]$strTable -eq "")  
)
{
  $res = "UNCERTAIN: Invalid number of parameters - Usage: .\Database.ps1  <Table> "
  echo $res
  exit 
}

$objConn = new-object -comobject ADODB.Connection
$objRecords = new-object -comobject ADODB.Recordset


try
{
  $objConn.Open($strConnectionString)
}
catch
{
  $res = "ERROR: Invalid connection string"
  echo $res
  exit
}    


$strQuery = "SELECT COUNT(*) AS count FROM " + $strTable

try
{  
  $objRecords.Open($strQuery,$objConn)    
}
catch
{
 $res = "ERROR: Table[" + $strTable + "] does not exists."
 echo $res   
 $objConn.Close()
 exit
}

if ($objRecords.EOF -eq $true)
{
  $res = "ERROR: No record returned from query[" + $strquery + "]"
  echo $res
  $objConn.Close()
  exit
}  

$objRecords.MoveFirst()
$iRecordCount = $objRecords.Fields.Item("count").Value

$objConn.Close()

if ($nMinimumCount -le $iRecordCount)
{
  $res = "SUCCESS: Criteria matched Record count[" + $iRecordCount + "] Minimum record count[" + $nMinimumCount + "]" 
  echo $res
  exit
}
else
{
  $res = "ERROR: Criteria not matched Record count[" + $iRecordCount + "] Minimum record count[" + $nMinimumCount + "]" 
  echo $res
  exit
}
  
echo $result
