Function Get-VMNetworkConfiguration {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$True,
                   ParametersetName='VMName',
                   Position=0)]
        [ValidateScript({
            Get-VM -Name $_
        }
        )]
        [String]$VMName   
    )

    $vmObject = Get-WmiObject -Namespace 'root\virtualization\v2' -Class 'Msvm_ComputerSystem' | Where-Object { $_.ElementName -eq $vmName }

    if ($vmObject.EnabledState -ne 2) {
        Write-Error "${vmName} is not in running state; The network configuration data won't be available"
    } else {
        $vmSetting = $vmObject.GetRelated('Msvm_VirtualSystemSettingData') | Where-Object { $_.VirtualSystemType -eq 'Microsoft:Hyper-V:System:Realized' } 
        $netAdapter = $vmSetting.GetRelated('Msvm_SyntheticEthernetPortSettingData')
        foreach($Adapter in $netAdapter) { 
            $Adapter.GetRelated("Msvm_GuestNetworkAdapterConfiguration") | Select IPAddresses, Subnets, DefaultGateways, DNSServers, DHCPEnabled, @{Name="AdapterName";Expression={$Adapter.ElementName}}
        }
    }
}