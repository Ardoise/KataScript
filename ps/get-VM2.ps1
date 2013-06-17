$crlf=([char]13 + [char]10)
$finalOutput = echo "Begin output of VM information" 
$finalOutput += $crlf
$finalOutput += echo "----------------------------------------------------------------------------"
$finalOutput += $crlf
$reg=[regex]'`n'
$totalCPUs=0
$totalMemory=0
$totalAllocated=0
$totalFreeSpace=0


get-vm|sort-object -property name |%  {$output = echo "Name: "$_.Name""
  					$output=$reg.Replace($output,"",-1)
						$finalOutput += $output
						$finalOutput += "`r`n"
						$totalCPUs+=$_.NumCPU
						$output = echo  "CPUs: "$_.NumCPU""
						$output=$reg.Replace($output,"",-1)
						$finalOutput += $output 
						$finalOutput += "`r`n"
						$totalMemory+=($_.MemoryMB/1024)
						$output = echo "Memory in GB: "($_.MemoryMB/1024)""
						$output=$reg.Replace($output,"",-1)	
						$finalOutput += $output 
						$finalOutput += "`r`n"
						$output = echo "Disks and size in GB"
						$output += "`r`n"
						#$_.HardDisks |% {$output += (echo $_.name,($_.CapacityKB/1024/1024))
						#		$output += "`r`n"
						#		}	
						((get-view $_.ID).Guest.disk)|% { $capacity=([int]($_.Capacity/1024/1024/1024))
														  $totalAllocated+=$capacity
														  $freeSpace=([int]($_.FreeSpace/1024/1024/1024))
														  $totalFreeSpace+=$freeSpace														  
														  $output=($_.DiskPath,"Total="+$capacity,"Free="+$freeSpace)
														  $output=$reg.Replace($output,"",-1)
														  $output += "`r`n"
														  $finalOutput += $output
														}
						#$output=$reg.Replace($output,"",-1)
						#$finalOutput += $output
						$finalOutput += "`r`n"
						$output = echo "----------------------------------------------------------------------------"
						$finalOutput += $output
						$finalOutput += "`r`n"
						}
						
$finalOutput += "============================================================================================"
$finalOutput += "`r`n"
$finalOutput += "`r`n"
$output = "Total CPUs Allocated = "+$totalCPUs
$finalOutput += $output
$finalOutput += "`r`n"
$output = "Total Memory Allocated in GB = "+$totalMemory
$finalOutput += $output
$finalOutput += "`r`n"
$output = "Total DiskSpace Allocated in GB = "+$totalAllocated
$finalOutput += $output
$finalOutput += "`r`n"
$output = "Total DiskSpace Free in GB = "+$totalFreeSpace
$finalOutput += $output
$finalOutput += "`r`n"
$finalOutput += "`r`n"
$finalOutput += "============================================================================================"

if ($args[0]) 
{
	$finalOutput >$args[0]
} else
{
	$finalOutput
}
