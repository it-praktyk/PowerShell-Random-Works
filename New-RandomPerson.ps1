function New-RandomPerson {
    <#
    
    .SYNOPSIS
    The function intended to generate string with name of a random person.
    
    .DESCRIPTION
    The function generate a random name of females or males based on selected culture in the format <FirstName><Space><LastName>.
    The first and last names are randomly selected from the files delivered with the function for the selected culture (default is: en-US).

    Currently supported cultures (in the alphabetical order):
    - en-US
    - pl-PL
    
    .PARAMETER UseNationalCharset
    If you would like use national diacritics.
    
    .PARAMETER Sex
    The sex of random person. Available values: female, male, both.
    
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
    [PS] > 1..3 | ForEach-Object -Process { New-RandomPerson -Sex female -culture en-US }
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
                           the structure for csv changed to support national charsets, the license changed to MIT
    - 0.3.0 - 2016-01-16 - The structure cultures files changes for support female/male last name grammar forms in some languages
    - 0.3.1 - 2016-01-16 - The help section updated
    - 0.4.0 - 2016-01-16 - The function corrected, situation where provided culture is incorrect handled
    - 0.4.1 - 2016-01-17 - UTF-8 encoding declared for the cultures files import added
    
    TO DO
    - add verbose output
    - return output as an object
    - add support for culture data provided as variable
    
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
    [cmdletbinding()]
    
    param (
        [parameter(Mandatory = $false)]
        [switch]$UseNationalCharset,
        [parameter(Mandatory = $false)]
        [ValidateSet("both", "female", "male")]
        [String]$Sex = "both",
        [String]$Culture = "en-US"
    )
    
    Try {
        
        $ModulePath = ([System.IO.FileInfo](get-module New-RandomPerson).Path | select directory).Directory.ToString()
        
    }
    Catch {
        
        $ModulePath = Split-Path $script:MyInvocation.MyCommand.Path
        
    }
    
    Try {
        
        [String]$CultureFileName = "{0}\cultures\{1}.csv" -f $ModulePath, $Culture
        
        $AllNames = Import-Csv -Path $CultureFileName -Delimiter "," -Encoding UTF8
        
    }
    Catch {
        
        [String]$MessageText = "The file {0}.csv can't not be find in the directory '{1}\cultures\' or the base folder for the function New-RandomPerson can't be recognized." -f $Culture, $ModulePath  

        Throw $MessageText
        
    }
        
    $AllNamesCount = ($AllNames | Measure-Object).Count
    
    if ($UseNationalCharset.IsPresent -and $UseNationalCharset -ne $false ) {
        
        If ($Sex -eq "both") {
            
            $RandomSex = (Get-Random @('Female', 'Male'))
            
            $FirstNameFieldName = "{0}FirstNameNationalChars" -f $RandomSex
            
            $LastNameFieldName = "{0}LastNameNationalChars" -f $RandomSex
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].$FirstNameFieldName
            
            $LastName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].$LastNameFieldName
            
        }
        elseif ($Sex -eq "female") {
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].FemaleFirstNameNationalChars
            
            $LastName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].FemaleLastNameNationalChars
            
        }
        else {
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].MaleFirstNameNationalChars
            
            $LastName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].MaleLastNameNationalChars
            
        }
        
    }
    Else {
        
        If ($Sex -eq "both") {
            
            $RandomSex = (Get-Random @('Female', 'Male'))
            
            $FirstNameFieldName = "{0}FirstName" -f $RandomSex
            
            $LastNameFieldName = "{0}LastName" -f $RandomSex
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].$FirstNameFieldName
            
            $LastName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].$LastNameFieldName
            
        }
        elseif ($Sex -eq "female") {
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].FemaleFirstName
            
            $LastName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].FemaleLastName
            
        }
        else {
            
            $FirstName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].MaleFirstName
            
            $LastName = $AllNames[(Get-Random -Minimum 0 -Maximum ($AllNamesCount - 1))].MaleLastName
            
        }
    }
    
    Return $([String]"{0} {1}" -f $FirstName, $LastName)
    
    
}