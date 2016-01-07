Function Export-ADUserPhoto {
<#
    .SYNOPSIS
    Export the photos stored in an Active Directory and used by Outlook or Lync as users pictures.
        
    .DESCRIPTION
    Reads the ThumbnailPhoto attribute of the specified user's Active
    Directory account, and export the returned photo to jpg file named as the user SAMAccountName
    
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
    
    .OUTPUTS
    System.Object[]
    
    .EXAMPLE
    PS > Export-ADUserPhoto user1
	
    
    Export the photo stored in the Active Directory for user account to jpg file".

	.LINK
    https://github.com/it-praktyk/Export-ADUserPhoto
    
    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech
          
    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell
   
    VERSIONS HISTORY
    - 0.1.0 - 2016-01-06 - The first version
	- 0.2.0 - 2016-01-07 - The function renamed to Export-ADUserPhoto, the parameter UserName renamed to Identity

    TODO
	- Test parameter Identity from pipeline
	- Verify declared type of parameter Identity
	- Update examples
	        
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
        [String[]]$Identity,
        [Parameter(Mandatory = $false)]
        [System.IO.DirectoryInfo]$FolderName
    )
    
    Begin {
	
		If (!(Get-Module -name 'ActiveDirectory' -ErrorAction SilentlyContinue) ) {
            
            Import-Module -Name 'ActiveDirectory' -ErrorAction Stop | Out-Null
            
        }
		
		if (!$FolderName) {
		
			$FolderName = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath((Get-Location).Path)
			
		}
        
        $Results = @()
        
    }
    
    Process {
        
        $Identity | ForEach-Object -Process {
            
            $CurrentUser = $_
            
            Try {
                
                $user = Get-ADUser $CurrentUser -Properties thumbnailPhoto
                
            }
            Catch {
                
                [String]$MessageText = "Active Directory account for the user {0}" -f $CurrentUser
                
                Write-Warning -Message $MessageText
                
                Continue
                
            }
            
            $Result = New-Object PSObject
            
            $Result | Add-Member -type NoteProperty -name UserSAMAccountName -value $user.SAMAccountName
            
            Try {
                
                [String]$UserPhotoFullFileName = "{0}\{1}.jpg" -f $FolderName, $CurrentUserName
                
                if ($user.thumbnailPhoto) {
                    
                    $user.thumbnailPhoto | Set-Content $UserPhotoFullFileName -Encoding byte
                    
                    $Result | Add-Member -Type NoteProperty -Name PhotoINActiveDirectoryExists -Value $true
                }
                Else {
                    
                    $Result | Add-Member -Type NoteProperty -Name PhotoINActiveDirectoryExists -Value $false
                    
                }
                
            }
            
            Catch {
                
                $Result | Add-Member -Type NoteProperty -Name PhotoINActiveDirectoryExists -Value $false
                
            }
            
            Finally {
                
                $Results += $Result
                
            }
            
        }
        
    }
    
    end {
        
        Return $Results
        
    }
    
}
