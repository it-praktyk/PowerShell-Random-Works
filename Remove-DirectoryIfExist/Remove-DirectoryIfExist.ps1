Function Remove-DirectoryIfExist {
<#
    .SYNOPSIS
    Function used to remove folder with all content from remote computer if the directory exist on it
   
    .DESCRIPTION
    Function intended for removing unnecessary directories (with all content !) from remote computers - for cleaning purposes.
    Any additional confirmation for remove is NOT needed then please use carefully.

    .PARAMETER $ComputerName
    Computer name for remote computer

    .PARAMETER $BasePath
    Base path - e.g. disk drive letter or administrattive share 
    
    .PARAMETER $DirectoryName
    Directory name or names - function accept more then one directory which should be checked and removed   
    
    .EXAMPLE
    Remove-DirectoryIfExist -ComputerName RXNLXMS95XXX -BasePath D$\ -DirectoryName test1
    
    .EXAMPLE
    Remove-DirectoryIfExist -ComputerName RXNLCMS92XXX -BasePath C$ -DirectoryName "Test2","Change3"
    
    .EXAMPLE
    Get-Content .\GZ_XCxxxxxx_computers.txt | ForEach {  Remove-DirectoryIfExist -ComputerName $_ -BasePath d$\ -DirectoryName R710_changes_201409 -Verbose }

    .LINK
    https://github.com/it-praktyk/PowerShell-Random-Works
    
    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech
    
    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net  
    KEYWORDS: PowerShell, directory
    
    VERSION HISTORY
    0.4.2 - 2016-08-06 - The first version published on GitHub

    LICENSE  
    Copyright (c) 2016 Wojciech Sciesinski  
    This function is licensed under The MIT License (MIT)  
    Full license text: https://opensource.org/licenses/MIT  
    
#>

    
[cmdletbinding()]
    
PARAM (

    [Parameter(mandatory=$true,ValueFromPipeline=$true,Position=0)]
    [String]$ComputerName,
        
    [Parameter(mandatory=$true,ValueFromPipeline=$true,Position=1)]
    [String]$BasePath,
    
    [Parameter(mandatory=$true,ValueFromPipeline=$true,Position=2)]
    $DirectoryName

)

BEGIN {

    
    #Handle situation when one directory was passed to the $DirectoryName parameter
    If ( $DirectoryName.GetType().Name.ToString() -eq "String") {
    
        [Array[]]$DirectoryNameArray=@($DirectoryName)
    
    }
    #Handle situation when more directories was passed to the $DirectoryName parameter
    Else {
    
        [Array[]]$DirectoryNameArray = $DirectoryName
    
    }

    #Checking count of directories passed to the $DirectoryName parameter
    $DirectoryNameCount = $DirectoryNameArray.Length
    
    $i=0

}

PROCESS {

    While ($i -lt $DirectorynameCount) {
    
    
        [String]$FolderToDelete = $DirectoryNameArray[$i]
        
        Write-Verbose "Checking on the server $Computername if folder $BasePath\$FolderToDelete exists"
        
        $FullPathToDelete="\\"+("$Computername\$BasePath\$FolderToDelete").Replace("\\","\")
        
        if (Test-Path $FullPathToDelete -pathType container ) {
            
            
            Write-Verbose "Deleting folder $FullPathToDelete"
  
            Get-ChildItem -Path $FullPathToDelete | Remove-Item -Force -Recurse -Confirm:$false | Out-Null
 
            Remove-Item -Path $FullPathToDelete -Recurse -Force
        
        }
        Else {
            
            Write-Verbose "Folder $BasePath\$FolderToDelete doesn't exist on server $Computername"
        
        }
        
        $i+=1
    
    }

}

END {

    #Probably exit codes for remove commands should be added in this place

}
    
}