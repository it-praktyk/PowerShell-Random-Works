Function Export-ADUserPhoto {
<#
    .SYNOPSIS
    Export the photos stored in an Active Directory and used by Outlook as users pictures/avatars and store them in jpg files.
        
    .DESCRIPTION
    Reads the ThumbnailPhoto attribute of the specified user's Active Directory account, 
    and export the returned photo to jpg file named as the user SAMAccountName.
    
    .PARAMETER Identity
    Specifies an Active Directory user object by providing one of the following property values. The identifier in
    parentheses is the LDAP display name for the attribute. The acceptable values for this parameter are:

    -- A Distinguished Name
    -- A GUID (objectGUID)
    -- A Security Identifier (objectSid)
    -- A SAM Account Name (sAMAccountName)

    The cmdlet searches the default naming context or partition to find the object. If two or more objects are
    found, the cmdlet returns a non-terminating error.

    This parameter can also get this object through the pipeline or you can set this parameter to an object
    instance.
    
    .PARAMETER Path
    Specifies the path to the location of the new item. Wildcards are not permitted.
    
    .PARAMETER Force
    Allows the function to overwrite existing files. If not set prompt for overwrite will be displayed.
    Even using the Force parameter, the cmdlet cannot override security restrictions.
    
    
    .OUTPUTS
    System.Object[]
    
    .EXAMPLE
    PS > Export-ADUserPhoto -Identity user1
    
    UserSAMAccountName    PhotoINActiveDirectoryExists    PhotoExported
    ------------------    ----------------------------    -------------
    user1                                         True             True
    
    PS > Get-ChildItem -Path .\
    
    Directory: C:\Users\Administrator\Desktop

    Mode                LastWriteTime     Length Name
    ----                -------------     ------ ----
    -a---          1/9/2016   2:40 PM        910 user1.jpg

    The identity of user from command line, the result file named <SAMAccountName>.jpg saved in the current directory
    
    .EXAMPLE
    
    PS > "user1","yyyy","xxxx" | Export-ADUserPhoto

    Overwrite File
    The file C:\Users\Administrator\Desktop\user1.jpg exist. Overwrite?
    [Y] Yes  [A] All  [N] No  [O] No for All  [C] Cancel  [?] Help (default is "Y"): y

    UserSAMAccountName    PhotoINActiveDirectoryExists    PhotoExported
    ------------------    ----------------------------    -------------
    user1                                         True             True
    YYYY                                          True             True
	XXXX                                         False            False
    
    PS > Get-ChildItem -Path .\
    
    Directory: C:\Users\Administrator\Desktop

    Mode                LastWriteTime     Length Name
    ----                -------------     ------ ----
    -a---          1/9/2016   2:43 PM        910 user1.jpg
    -a---          1/9/2016   2:43 PM       1930 yyyy.jpg
    
    The identities of users from pipeline as an array of strings, the result files named <SAMAccountName>.jpg saved in the current directory, with the prompt for overwrite.
    
    .EXAMPLE
    
    PS C:\Users\Administrator\Desktop> Get-ADUser -filter * | Export-ADUserPhoto -Force

    UserSAMAccountName    PhotoINActiveDirectoryExists    PhotoExported
    ------------------    ----------------------------    -------------
    Guest                                         True             True
    krbtgt                                       False            False
    Administrator                                False            False
    user1                                         True             True
    XXXX                                         False            False
    YYYY                                          True             True

    PS > Get-ChildItem -Path .\
    
    Directory: C:\Users\Administrator\Desktop

    Mode                LastWriteTime     Length Name
    ----                -------------     ------ ----
    -a---          1/9/2016   2:46 PM        910 user1.jpg
    -a---          1/9/2016   2:46 PM       1930 yyyy.jpg
    -a---          1/9/2016   2:46 PM       4720 guest.jpg

    The identities of users from pipeline as Active Directory users objects, the result files named <SAMAccountName>.jpg saved in the current directory, without the prompt for overwrite.
    
    .LINK
    https://github.com/it-praktyk/Export-ADUserPhoto
    
    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech
          
    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: Windows, PowerShell, Exchange, email, thumbnailPhoto
   
    VERSIONS HISTORY
    - 0.1.0 - 2016-01-06 - The first version
    - 0.2.0 - 2016-01-07 - The function renamed to Export-ADUserPhoto, the parameter UserName renamed to Identity
    - 0.3.0 - 2016-01-09 - The function extended, help updated
    - 0.3.1 - 2016-01-10 - The type for parameter Identity corrected
    - 0.3.2 - 2016-01-10 - Keywords updated, help corrected
	- 0.3.3 - 2016-01-10 - Description, help updated, examples reformatted

    TODO
    - the situation of write to disk error should be handled
	- return results objects only if PassThru parameter provided (?)
            
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
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    Param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [alias("UserName")]
        $Identity,
        [Parameter(Mandatory = $false)]
        [System.IO.DirectoryInfo]$Path,
        [alias("FolderName")]
        [Parameter(Mandatory = $false)]
        [Switch]$Force
    )
    
    Begin {
                
        If (!(Get-Module -name 'ActiveDirectory' -ErrorAction SilentlyContinue)) {
            
            Import-Module -Name 'ActiveDirectory' -ErrorAction Stop | Out-Null
            
        }
        
        if (!$FolderName) {
            
            $FolderName = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath((Get-Location).Path)
            
        }
        
        If (!(Test-Path -Path $FolderName -Type Container)) {
            
            [String]$ExceptionText = "The folder {0} doesn't exist." -f $FolderName
            
            Throw $ExceptionText
            
        }
        
        $Results = @()
        
    }
    
    Process {
        
        $Identity | ForEach-Object -Process {
            
            $WasError = $false
            
            $CurrentUser = $_
            
            $CurrentDomainDN = (Get-ADDomain).DistinguishedName
            
            $Result = New-Object PSObject
            
            Try {
                
                $ADUser = Get-ADUser $CurrentUser -Properties thumbnailPhoto
                
                $Result | Add-Member -type NoteProperty -name UserSAMAccountName -value $ADUser.SAMAccountName
                
            }
            Catch {
                
                [String]$MessageText = "Cannot find an object with identity: {0} under: '{1}'." -f $CurrentUser, $CurrentDomainDN
                
                Write-Warning -Message $MessageText
                
                $WasError = $true
                
            }
            
            #Perform only if user was found in Active Directory
            If (!$WasError) {
                
                Try {
                    
                    [System.IO.FileInfo]$ADUserPhotoDestinationFile = "{0}\{1}.jpg" -f $FolderName, $ADUser.SAMAccountName
                    
                    #Block if thumbnailPhoto is not empty
                    if ($ADUser.thumbnailPhoto) {
                        
                        #Block if the file <SAMAccountName>.jpg for current AD user already exist
                        if (Test-Path -Path $ADUserPhotoDestinationFile -Type Leaf) {
                            
                            If ($Force.IsPresent -or $OverwriteAll) {
                                
                                $ADUser.thumbnailPhoto | Set-Content -Path $ADUserPhotoDestinationFile.FullName -Encoding byte
                                
                                $Result | Add-Member -type NoteProperty -name PhotoExported -value $true
                                
                            }
                            elseif ($PreserveAll) {
                                
                                [String]$MessageText = "The photo for the user {0} will not be exported because the file {1} exists." -f $ADUser.SAMAccountName, $ADUserPhotoDestinationFile.FullName
                                
                                Write-Warning $MessageText
                                                                
                            }
                            Else {
                                
                                #Dialog for decision if Force was not set or Overwrite All not selected previously
                                [String]$Title = "Overwrite File"
                                [String]$MessageText = "The file {0} exist. Overwrite?" -f $ADUserPhotoDestinationFile.FullName
                                
                                $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                                                    "Overwrite the existing file."
                                
                                $yesall = New-Object System.Management.Automation.Host.ChoiceDescription "&All", `
                                                     "Overwrite the all existing files."
                                
                                $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                                                     "Retain the existing file."
                                
                                $noall = New-Object System.Management.Automation.Host.ChoiceDescription "N&o for All", `
                                                    "Retain the all existing files."
                                
                                $cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", `
                                                     "Cancel."
                                
                                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $yesall, $no, $noall, $cancel)
                                
                                $Answer = $host.ui.PromptForChoice($Title, $MessageText, $Options, 0)
                                
                                switch ($Answer) {
                                    
                                    #Write the file to disk
                                    0 {
                                        
                                        $ADUser.thumbnailPhoto | Set-Content -Path $ADUserPhotoDestinationFile.FullName -Encoding byte
                                        
                                        $Result | Add-Member -type NoteProperty -name PhotoExported -value $true
                                        
                                    }
                                    
                                    #Write the file to disk and overwrite any next file if exist
                                    1 {
                                        
                                        [Bool]$OverWriteAll = $true
                                        
                                        $ADUser.thumbnailPhoto | Set-Content -Path $ADUserPhotoDestinationFile.FullName -Encoding byte
                                        
                                        $Result | Add-Member -type NoteProperty -name PhotoExported -value $true
                                        
                                    }
                                    
                                    #No write the current file to disk becaluse "No" was selected
                                    2 {
                                        
                                        [String]$MessageText = "The photo for the user {0} will not be exported because the file {1} exists." -f $ADUser.SAMAccountName, $ADUserPhotoDestinationFile.FullName
                                        
                                        Write-Warning $MessageText
                                        
                                        $Result | Add-Member -type NoteProperty -name PhotoExported -value $false
                                        
                                        Continue
                                        
                                    }
                                    
                                    #No write file to disk because "No for All" was selected
                                    3 {
                                        
                                        [Bool]$PreserveAll = $true
                                        
                                        [String]$MessageText = "The photo for the user {0} will not be exported because the file {1} exists." -f $ADUser.SAMAccountName, $ADUserPhotoDestinationFile.FullName
                                        
                                        Write-Warning $MessageText
                                        
                                        $Result | Add-Member -type NoteProperty -name PhotoExported -value $false
                                        
                                        Continue
                                        
                                    }
                                    #Stop because Cancel was selected
                                    4 {
                                        
                                        Break
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        #Block if the file <SAMAccountName>.jpg for current AD user doesn't exist
                        Else {
                            
                            $ADUser.thumbnailPhoto | Set-Content -Path $ADUserPhotoDestinationFile.FullName -Encoding byte
                            
                            $Result | Add-Member -type NoteProperty -name PhotoExported -value $true
                            
                        }
                        
                        $Result | Add-Member -Type NoteProperty -Name PhotoINActiveDirectoryExists -Value $true
                    }
                    
                    #region Block if thumbnailPhoto is empty
                    Else {
                        
                        $Result | Add-Member -Type NoteProperty -Name PhotoINActiveDirectoryExists -Value $false
                        
                        $Result | Add-Member -type NoteProperty -name PhotoExported -value $false
                        
                    }
                    
                }
                
                #In case of an error for AD reading e.g. - see TO DO
                Catch {
                    
                    $Result | Add-Member -Type NoteProperty -Name PhotoINActiveDirectoryExists -Value $false
                    
                    $Result | Add-Member -type NoteProperty -name PhotoExported -value $false
                    
                }
                
                #Add the current object to the collection
                Finally {
                    
                    $Results += $Result
                    
                }
                
            }
        }
        
    }
    
    end {
        
        Return $Results
        
    }
    
}
