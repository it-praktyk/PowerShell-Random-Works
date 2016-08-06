Function New-HttpsWinRMListener {   
    <#
     
    .SYNOPSIS
     Function intended to create https listener used by PowerShell remoting - WinRM service
    
    .NOTES
	
	Partially based on code found at http://poshcode.org/2207 , author Lee Holmes

	#http://support.microsoft.com/kb/2019527
	
    VERSION HISTORY
    0.1.0 - 2015-03-07 - first early draft, first version published on GitHub
	0.1.1 - 2015-03-07 - disclaimer updated
	0.2.0 - 2016-08-06 - Repository moved from https://github.com/it-praktyk/New-HttpsWinRMListener to https://github.com/it-praktyk/PowerShell-Random-Works, the license changed to MIT
	
	.LINK
    https://github.com/it-praktyk/PowerShell-Random-Works
    
    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech
    
    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell, WinRM
    
	LICENSE  
    Copyright (c) 2016 Wojciech Sciesinski  
    This function is licensed under The MIT License (MIT)  
    Full license text: https://opensource.org/licenses/MIT  
        
  #>
  
    param(
	
		[Paremeter(Mandatory = $false)]
		$ComputerName=[System.Net.Dns]::GetHostByName($ComputerName).HostName,
		
        [Parameter(Mandatory = $false)]
        $EkuName="Server Authentication"

		)
     
#    Set-StrictMode -Off
     
	 $FQDName=$ComputerName
    
    foreach($cert in Get-ChildItem cert:\LocalMachine\My | Where { $_.Subject -eq "CN=$FQDName"  )
    {

        foreach($extension in $cert.Extensions)
        {
            ## For each extension, go through its Enhanced Key Usages
            foreach($certEku in $extension.EnhancedKeyUsages)
            {
                ## If the friendly name matches, output that certificate
                if($certEku.FriendlyName -eq $ekuName)
                {
                    $cert | Sort-Object -Property NotAfter |
                                Select-Object -Last 1 -ExpandProperty Thumbprint
                }
            }
        }
    }

}


#Source: http://serverfault.com/questions/589607/automatically-reconfigure-winrm-https-listener-with-new-certificate

$yourCred = Get-Credential domain\account
$FQDName=[System.Net.Dns]::GetHostByName($ComputerName).HostName

$LatestThumb = Invoke-Command -ComputerName $yourServer `
                            -Credential $yourCred `
                            -ScriptBlock {
                                Get-ChildItem -Path Cert:\LocalMachine\My |
                                Sort-Object -Property NotAfter |
                                Select-Object -Last 1 -ExpandProperty Thumbprint
								
								
                            }

Set-WSManInstance -ResourceURI winrm/config/Listener `
                  -SelectorSet @{Address="*";Transport="HTTPS"} `
                  -ComputerName $FQDName `
                  -Credential $yourCred `
                  -ValueSet @{CertificateThumbprint=$LatestThumb}

Invoke-Command -ComputerName $yourServer `
               -Credential $yourCred `
               -ScriptBlock { Restart-Service -Force -Name WinRM }