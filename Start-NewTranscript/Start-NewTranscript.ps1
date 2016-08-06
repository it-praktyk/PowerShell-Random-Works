Function Start-NewTranscript {
<#
    .SYNOPSIS
    PowerShell function intended for start new transcript based on provided parameters
   
    .DESCRIPTION
    This function extend PowerShell transcript creation start. A transcript is created in the folder other than default with the name which can be defined as parameter,
    previous transcript is stopped if needed, etc.
    
    .PARAMETER TranscriptFileDirectoryPath
    By default transcript files are stored in subfolder named "transcripts" in current path, if transcripts subfolder is missed will be created
    
    .PARAMETER TranscriptFileNamePrefix
    Prefix used for creating transcript files name. Default is "Transcript-"
    
    .PARAMETER StartTimeSuffix
    Suffix what will be added to transcript file name
  
    .EXAMPLE
    
    Start-NewTranscript -TranscriptFileDirectoryPath "C:\Transcripts\" -TranscriptFileNamePrefix "Change_No_111_transcript-"
     
    .LINK
    https://github.com/it-praktyk/PowerShell-Random-Works
    
    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech
          
    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell
   
    VERSIONS HISTORY
    - 0.1.0 - 2015-03-11 - Initial release
    - 0.2.0 - 2015-03-12 - additional parameter StartTimeSuffix added
    - 0.2.1 - 2015-03-12 - TODO updated
    - 0.3.0 - 2015-03-14 - License changed to GNU GPLv3
    - 0.4.0 - 2016-08-06 - License changed to MIT, repository moved from https://github.com/it-praktyk/Start-NewTranscript to https://github.com/it-praktyk/PowerShell-Random-Works
        
    LICENSE  
    Copyright (c) 2016 Wojciech Sciesinski  
    This function is licensed under The MIT License (MIT)  
    Full license text: https://opensource.org/licenses/MIT  

    TODO
    - Check format used by hours for other cultures or formating like this '{0}' -f [datetime]::UtcNow
    - Catch situation when the "\" in path are doubled or missed
    - Suppress "Start transcript ... " message
    - Add functionality to create falback transcript to $TEMP directory if declared folder can't be created
    
#>

[CmdletBinding()] 

param (

    [parameter(Mandatory=$false)]
    [String]$TranscriptFileDirectoryPath=".\transcripts\",

    [parameter(Mandatory=$false)]
    [String]$TranscriptFileNamePrefix="Transcript-",
    
    [parameter(Mandatory=$false)]
    [String]$StartTimeSuffix

)

BEGIN {

    #Uncomments if you need hunt any bug
    Set-StrictMode -version 2
    
    If ( $StartTimeSuffix ) {
    
        [String]$StartTime = $StartTimeSuffix
        
    }
    Else {

        [String]$StartTime = Get-Date -format yyyyMMdd-HHmm
        
    }

    #Check if transcript directory exist and try create if not
        If ( !$((Get-Item -Path $TranscriptFileDirectoryPath -ErrorAction SilentlyContinue) -is [system.io.directoryinfo]) ) {

                New-Item -Path $TranscriptFileDirectoryPath -type Directory -ErrorAction Stop | Out-Null
                
                Write-Verbose -Message "Folder $TranscriptFileDirectoryPath was created."
                
        }
        
        $FullTranscriptFilePath = $TranscriptFileDirectoryPath + '\' + $TranscriptFileNamePrefix + $StartTime + '.log'

        #Stop previous PowerShell transcript and catch error if not started previous

        try{

             stop-transcript  | Out-Null

        }

        catch [System.InvalidOperationException]{}
        
}

PROCESS {

        #Start new PowerShell transcript

        Start-Transcript -Path $FullTranscriptFilePath -ErrorAction Stop

        Write-Verbose "Transcript will be written to $FullTranscriptFilePath"
    
}

END {

}
 
}