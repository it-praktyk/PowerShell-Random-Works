
Function Invoke-NTFSFilesCompression {

  <#
    .SYNOPSIS
    Compress files with given extention older than given amount of time
   
    .DESCRIPTION
    The function is intended for compressing (using the NTFS compression) all files with particular extensions older than given time unit
  
    .PARAMETER Path
    The folder path that contain files. Folder path can be pipelined.
  
    .PARAMETER $OlderThan
    The count of units that are base to comparison file age.
  
    .PARAMETER TimeUnit
    The unit of time that are used to count. The default time unit are minutes.
  
    .PARAMETER Extension
    The extention of files that will be processed. The default file extenstion is "log".

    .EXAMPLE
    Compress files with extension log in folder c:\test that are older than 20 minutes
    Invoke-NTFSFilesCompression -Path C:\test -OlderThan 20
  
    .EXAMPLE
    Compress files with extension txt in folder c:\test that are older than 1 hour
    Invoke-NTFSFilesCompression -Path C:\test -OlderThan 1 -TimeUnit hours -Extension "txt"

    .EXAMPLE
    Recursively compress fiels in all subfolders (one level only of nesting)

    PS> Get-ChildItem -Path C:\inetpub\logs\LogFiles\ -Directory | foreach { Invoke-NTFSFilesCompression -Path $_.fullname -OlderThan 30 -TimeUnit days -Extension log -Verbose }
    
    .LINK
    https://github.com/it-praktyk/PowerShell-Random-Works
    
    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech
    
    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: NTFS, compression, PowerShell
    
    VERSION HISTORY
    - 1.0.0 - 2013-10-04 - Initial edition
    - 1.0.1 - 2013-10-08 - Function renamed from Start-NTFSFilesCompression to Invoke-NTFSFilesCompression
    - 1.0.2 - 2013-10-08 - Information about licensing added, keywords extended 
    - 1.1.0 - 2016-08-06 - Moved from repository https://github.com/it-praktyk/Invoke-NTFSFilesCompression to https://github.com/it-praktyk/PowerShell-Random-Works
                           Old repository data in git-old.7z file, license changed to MIT
    - 1.1.1 - 2017-03-26 - Example added. TODO added
                           
    LICENSE  
    Copyright (c) 2016 Wojciech Sciesinski  
    This function is licensed under The MIT License (MIT)  
    Full license text: https://opensource.org/licenses/MIT  
    
    TODO
    - add suport for recurse by folder structure (?)

  #>

  [CmdletBinding(SupportsShouldProcess=$true)]

 Param (

    [Parameter(mandatory=$true,ValueFromPipeline=$true)]
    [string[]]$Path,
    
    [Parameter(mandatory=$true)]
    [int]$OlderThan,

    [Parameter()]
    [string[]]
    [ValidateSet("minutes","hours","days","weeks")]
    $TimeUnit="minutes",

    [Parameter()]
    [string[]]$Extension="log"
       
)

    BEGIN {

        $excludedfiles = "temp.log","temp2.log","source.log"

        # translate action to numeric value required by the method
        switch ($TimeUnit) {
            "minutes" {
                $multiplier = 1
                break
            }
            "hours" {
                $multiplier = 60
                break
            }
            "days" {
                $multiplier = 1440
                break
            }
            "weeks" {
                $multiplier = 10080
                break
            }
        }

        $OlderThanMinutes = $($OlderThan * $multiplier)
                               
        $compressolder = $(get-date).AddMinutes(-$OlderThanMinutes)

        $filterstring = "*."+$Extension

        $files=Get-ChildItem -Path $path -Filter $filterstring
    
    } #END BEGIN

    PROCESS {

        ForEach ( $i in $files ) {

            if ( $i.Name -notin $excludedfiles ) {

                $filepathforquery = $($i.FullName).Replace("\" , "\\")

                $file = Get-WmiObject -Query "SELECT * FROM CIM_DataFile WHERE Name='$filepathforquery'"

                if ($file.compressed -eq $false -and $i.LastWriteTime -lt  $compressolder) {

                    Write-Verbose "Start compressing file $i.name"

                    #Invoke compression
                    $file.Compress() | out-null

                } #End if


            } #End if
   

        } #End loop

    } #End PROCESS


} #End Invoke-LogFilesCompression function