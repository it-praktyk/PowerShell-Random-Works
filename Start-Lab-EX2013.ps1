<#
TODO
Stop Hyper-V host after stopping machines
Clean code
Parse CSV input file structure
#>
Import-Module PSWorkflow

workflow Start-Lab {
    
    [CmdletBinding()]
    param (
        
        [parameter(Mandatory = $true)]
        [String]$LabFile = "C:\Users\Administrator.wojteks\Desktop\LAB.EX2013.VMS.csv",
        [parameter(Mandatory = $false)]
        [ValidateSet("Start", "Stop")]
        [String]$Operation = "Start",
        [parameter(Mandatory = $false)]
        [Int]$CheckStatusEverySeconds = 10
        
    )
    
    If ($Operation -eq "Start") {
        
        $VMS = Import-CSV -Path $LabFile | Sort-Object StartOrder
        
    }
    elseif ($Operation -eq "Stop") {
        
        $VMS = Import-CSV -Path $LabFile | Sort-Object StartOrder -Descending
    }
    
    # Code partially based on
    # http://blogs.technet.com/b/heyscriptingguy/archive/2014/12/15/start-virtual-machines-in-order-and-wait-for-stabilization.aspx {
    
    function Wait-VM {
        
        param ($VMName,
            $HyperVHost,
            $Operation,
            $CheckStatusEverySeconds)
        
        if ($Operation -eq "Start") {
            
            while ((((Get-VM -Name $VMName -ComputerName $HyperVHost).HeartBeat).ToString()).Substring(0, 2) -ne 'Ok') {
                
                Start-Sleep -Seconds 5
                
                Write-Verbose "$VMName not ready. Waiting"
                
            }
        }
        elseif ($Operation -eq "Stop") {
            
            while ((Get-VM -Name $VMName -ComputerName $HyperVHost).State -ne 'Off') {
                
                Start-Sleep -Seconds 5
                
                Write-Verbose "$VMName not stoped yet. Waiting."
                
            }
            
        }
        
    }
    

    
    
    
    foreach ($vm in $VMS) {
        
        If ($Operation -eq "Start") {
            
            If ($vm.Start -eq 1) {
                
                if ((Get-Vm -Name $vm.Name -ComputerName $vm.ComputerName).State -ne 'Running') {
                    
                    Start-VM -Name $vm.Name -ComputerName $vm.ComputerName
                    
                    Wait-VM -VMName $vm.Name -HyperVHost $vm.ComputerName -Operation "Start" -CheckStatusEverySeconds $CheckStatusEverySeconds
                    
                }
                Else {
                    
                    Write-Verbose "$vm.Name is started now"
                    
                }
                
            }
            
            Else {
                
                Write-Verbose "Virtual machine $vm.Name will not be started"
                
            }
        }
        
        elseif ($Operation -eq "Stop") {
            
            If ($vm.Start -eq 1) {
                
                if ((Get-Vm -Name $vm.Name -ComputerName $vm.ComputerName).State -ne 'Off') {
                    
                    Stop-VM -Name $vm.Name -ComputerName $vm.ComputerName
                    
                    Wait-VM -VMName $vm.Name -HyperVHost $vm.ComputerName -Operation "Stop" -CheckStatusEverySeconds $CheckStatusEverySeconds
                    
                }
                Else {
                    
                    Write-Verbose "$vm.Name is started now"
                    
                }
                
            }
            
            Else {
                
                Write-Verbose "Virtual machine $vm.Name will not be started"
                
            }
            
            
        }
        
    }
    
}

#Start-Lab-EX2013