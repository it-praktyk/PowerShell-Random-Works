
<#

	.SYNOPSIS
	Script intended to start Hyper-V based lab machine in order

	.DESCRIPTION

	.EXAMPLE

	.PARAMETER LabName
	Will be filled after converting to function
	
	.FilePath
	Will be filled after converting to function

	.NOTES
  
	Code partially based on
	http://blogs.technet.com/b/heyscriptingguy/archive/2014/12/15/start-virtual-machines-in-order-and-wait-for-stabilization.aspx

	Modified by: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
		
	KEYWORDS: Hyper-V, PowerShell
   
	BASEREPOSITORY: https://github.com/it-praktyk/HyperV-lab-utils

	VERSION HISTORY
	0.1 - 2015-01-15 - first working draft
	0.2 - 2015-01-15 - help added, first version published to GitHub

   #>






Import-Module PSWorkflow

workflow Start-Lab-EX2013

{

    function Wait-VM

    {

        param($VMName,$HyperVHost)

        while((Get-VM -Name $VMName -ComputerName $HyperVHost ).HeartBeat -ne  'OkApplicationsHealthy')

        {

            Start-Sleep -Seconds 5

            Write-Verbose "$VMName not ready. Waiting"

        }

    }

	$VMS= Import-CSV ".\LAB.EX2013.VMS.csv"

    foreach($vm in $VMS)

    {
	
		if ( (Get-Vm -Name $vm.Name -ComputerName $vm.ComputerName).State -ne 'Running' ) {
		
			Start-VM -Name $vm.Name -ComputerName $vm.ComputerName

			Wait-VM -VMName $vm.Name -HyperVHost $vm.ComputerName

		}
    }

} 

Start-Lab-EX2013