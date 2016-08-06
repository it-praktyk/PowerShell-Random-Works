Function Read-InputFile {
    
    <#
    .SYNOPSIS
    Function intended for validate input file path and returning values
    
    .DESCRIPTION
    Function is simple wrapper for Get-Content and Import-Csv with validation if file exist and can be read
  
    .PARAMETER InputFilePath
    File contains data - can be flat txt file or csv file - regardles of a file type Get-Content or Import-CSV commandlet will be used
    
    .PARAMETER InputFileType 
    Input  file type can be "text" or "csv" - regardles of a file type Get-Content or Import-CSV commandlet will be used
    
    .PARAMETER Delimiter
    Delimiter char used for import csv files
    
    .PARAMETER StopIfEmpty
    If read from file result will be empty than display error and stop script
        
    .EXAMPLE
    Read-ImputFile -InputFilePath .\RecipientsToGetAddresses.txt -InputFileType "csv" -StopIfEmpty $true
	
	.LINK
	https://github.com/it-praktyk/PowerShell-Random-Works
	
	.LINK
	https://www.linkedin.com/in/sciesinskiwojciech
	      
	.NOTES
	AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
	KEYWORDS: PowerShell
   
	VERSIONS HISTORY
	- 0.1.0 - 2015-05-24 - First version published on GitHub, mostly base on code from Get-EmailAddresses.ps1 v. 0.7.2
	- 0.2.0 - 2016-08-06 - Repository moved from https://github.com/it-praktyk/Read-InputFile to https://github.com/it-praktyk/PowerShell-Random-Works, license changed to MIT
	
    LICENSE  
    Copyright (c) 2016 Wojciech Sciesinski  
    This function is licensed under The MIT License (MIT)  
    Full license text: https://opensource.org/licenses/MIT  
   
#>
    
    [CmdletBinding()]
    
    param
    (
        
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$InputFilePath,
        
        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet("text", "csv")]
        [String]$InputFileType = "text",
        
        [Parameter(Mandatory = $false, ParameterSetName = "csv")]
        [String]$Delimiter = ";",
        
        [Parameter(Mandatory = $false)]
        [Bool]$StopIfEmpty = $true
        
    )
    
    Begin {
        
        Write-Verbose -Message "Provided input file $InputFilePath"
        
    }
    
    Process {
        
        If (Test-Path -Path $InputFilePath) {
            
            
            If ((Get-Item -Path $InputFilePath) -is [System.IO.fileinfo]) {
                
                try {
                    
                    if ($InputFileType = "text") {
                        
                        $ResultsFromFile = Get-Content -Path $InputFilePath -ErrorAction Stop | Where { ($_).ToString().Trim() -ne "" }
                        
                    }
                    Else {
                        
                        $ResultsFromFile = Import-Csv -Path $InputFilePath -Delimiter $Delimiter -Encoding "UTF8"
                        
                    }
                    
                    $ResultsFromFileCount = $($ResultsFromFile | Measure-Object).count
                    
                    If ($StopIfEmpty -and $ResultsFromFileCount -lt 1) {
                        
                        [String]$MessageText = "Any data was not read from file $InputFilePath"
                        
                        Throw $MessageText
                        
                    }
                    
                }
                catch {
                    
                    Throw "Read input file $InputFilePath error"
                    
                }
                >
            }
            
            Else {
                
                Throw "Provided value for InputFilePath is not a file"
                
            }
            
        }
        Else {
            
            [String]$MessageText = "Provided value $InputFilePath assigned for InputFilePath doesn't exist"
            
            Throw $MessageText
            
        }
        
    }
    
    End {
        
        Return $ResultsFromFile
        
    }
    
}