# Author: Wojciech Sciesinski, wojciech@sciesinski.net
# Version: 0.1 - 20131120
# This script needs testing!

$iDRACModulePatch = "$home\Documents\Scripts\RACLibrary\RACLibrary.ps1"

# Input file contains columns
# "Account","Login Name","Password","Web Site","Comments"
$InputfilePath = "$home\Desktop\IDRAC\EX_ILO_v_004.csv"

$servers = Import-Csv $InputfilePath -Delimiter ","

$OutputFilePath = "$home\Desktop\IDRAC\EX_ILO_v_004_output.csv"

$CSVHeader = 'Account,"Login Name",Password,"Web Site",Comments,"Ping Status","Password correct"' | Out-file -FilePath test.txt -Encoding utf8

function Check-LoadedModule{

    [CmdletBinding()]

    Param(
    [parameter(Mandatory = $true)]
    [string]$ModuleName,
    
    [parameter]
    [string]$ModuleFilePath
    )

    if ( (Get-Module -name $ModuleName -ErrorAction SilentlyContinue) -eq $null )
    {
        Import-Module -Name $ModuleName
    }

}



ForEach ($server in $servers) {

    if (($server.Comments).Length -eq 0 ) {

        write-host $server.'Web Site'

        if (($server.'web site').Length -eq 0) {

            $serveraddress = $server.Account

        }
        else {
            
            $serveraddress = $server.'Web Site'

        }

        if(!(Test-Connection -ComputerName $serveraddress -BufferSize 16 -Count 1 -ea 0 -quiet)) {

            $line = "$server.Account,$server.'Login Name',$server.Password,$server.'Web Site',$server.Comments,$false,$false"

            $line | Out-File -FilePath $OutputFilePath -Encoding utf8 -Append $true

        }

        else{

            Check-LoadedModule -Module RACLibrary -ModuleFilePath $iDRACModulePatch -ErrorAction Stop

            get-RACConfig -$hostname $serveraddress -username $server.'Login Name' -pass $server.Password
            
        }


    } 

}