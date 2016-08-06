
<#

	.SYNOPSIS
	Script intended to create vhdx files in series

	.DESCRIPTION

	.EXAMPLE

	.PARAMETER LabName
	Will be filled after converting to function
	
	.FilePath
	Will be filled after converting to function

	.NOTES
  
	AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
		
	KEYWORDS: Hyper-V, PowerShell, VHDX
   
	BASEREPOSITORY: https://github.com/it-praktyk/HyperV-lab-utils

	VERSION HISTORY
	0.1 - 2015-01-15 - first working draft
	0.2 - 2015-01-15 - help added, first version published to GitHub

   #>


 $i=1
 $max=5
 $DisksPath=".\"
 $DisksSize=5GB
 $DiskBaseName="Data-"
 
 do  { 
 
	[String]$DiskFullPath = "{0}{1}{2}.vhdx" -f $DisksPath,$DiskBaseName,$i
 
	Write-output "Creating $DiskFullPath"
 
	new-vhd -Path $DiskFullPath -SizeBytes $DisksSize -Dynamic 
	
	$i++
 
 }
 while ($i -le $max)
 