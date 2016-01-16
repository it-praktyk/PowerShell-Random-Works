function New-RandomPerson {
    <#
    
    .SYNOPSIS
    The function intended to generate string with name of a random person 
    
    .DESCRIPTION
    The function generate a random name of females or mailes based on provided culture like <FirstName><Space><LastName>.
    The first and last names are randomly selected from the file delivered with for the culture like en-US 
    
    .PARAMETER UseNationalCharset
    If you would like use national diacritics.
    
    .PARAMETER Sex
    The sex of random person.
    
    .PARAMETER Culture
    The culture used for generate - default is en-US.    
    
    .LINK
    https://github.com/it-praktyk/New-RandomPerson
    
    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech
    
    .EXAMPLE
    [PS] > New-RandomPerson 
    Justin Carter
    
    The one name returned with random sex.
    
    .EXAMPLE
    [PS] > 1..3 | ForEach-Object -Process { New-RandoPerson -Sex female -culture en-US }
    Jacqueline Walker
    Julie Richardson
    Stacey Powell
    
    Three names returned, only women, from en-US culture
    
    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell
   
    VERSIONS HISTORY
    - 0.1.1 - 2016-01-16 - The first version published as a part of NameIT powershell module https://github.com/dfinke/NameIT
                           and included in the NameIT PowerShell module published to PowerShell Gallery with a version number  
                           1.04 http://www.powershellgallery.com/packages/NameIT/1.04
    - 0.2.0 - 2016-01-16 - The function renamed from 'person' to New-RandomPerson, the names for pl-PL culture added, 
                           the structure for csv changed to support national charsets, the licence changed to MIT
    
    TO DO
    - extend csv file to support correct grammar forms of female last name in some countries (like in Poland)
    - return output as an object
    
    LICENSE
	Copyright (c) 2016 Wojciech Sciesinski
    This function is licensed under The MIT License (MIT)
    Full license text: http://opensource.org/licenses/MIT
        
    DISCLAIMER
    This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 
    
#>    
    param (
        [parameter(Mandatory = $false)]
        [switch]$UseNationalCharset,
        [parameter(Mandatory = $false)]
        [ValidateSet("both", "female", "male")]
        [String]$Sex = "both",
        [String]$Culture = "en-US"
    )
    
    $ModulePath = Split-Path $script:MyInvocation.MyCommand.Path
    
    [String]$CultureFileName = "{0}\cultures\{1}.csv" -f $ModulePath, $Culture
    
    $AllNames = Import-Csv -Path $CultureFileName -Delimiter ","
    
    $AllNamesCount = ($AllNames | Measure-Object).Count
    
    if ($UseNationalCharset.IsPresent) {
        
        $LastName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].LastNameNationalChars
        
        If ($Sex -eq "both") {
            
            $RandomSex = (Get-Random @('Female', 'Male'))
            
            $FirstNameFieldName = "{0}FirstNameNationalChars" -f $RandomSex
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].$FirstNameFieldName
            
        }
        elseif ($Sex -eq "female") {
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].FemaleFirstNameNationalChars
            
        }
        else {
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].MaleFirstNameNationalChars
            
        }
        
    }
    Else {
        
        $LastName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].LastName
        
        If ($Sex = "both") {
            
            $RandomSex = (Get-Random @('Female', 'Male'))
            
            $FirstNameFieldName = "{0}FirstName" -f $RandomSex
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].$FirstNameFieldName
            
            
        }
        elseif ($FirstName -eq "female") {
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].FemaleFirstName
            
        }
        else {
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].MaleFirstName
            
        }
    }
    
    Return $([String]"{0} {1}" -f $FirstName, $LastName)
    
    
}