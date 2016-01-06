Function Export-ADPhoto {
<#
    .SYNOPSIS
    Export the photos stored in an Active Directory and used by Outlook or Lync as users pictures.
        
    .DESCRIPTION
    Reads the ThumbnailPhoto attribute of the specified user's Active
    Directory account, and export the returned photo to jpg file.
    
    .PARAMETER UserName
    The User logon name of the Active Directory user to query.
    
    .OUTPUTS
    System.Object[]
    
    .EXAMPLE
    PS > Export-ADPhoto user1
    
    Export the photo stored in the Active Directory for user account to jpg file".

	.LINK
    https://github.com/it-praktyk/<BASE_REPOSITORY_URL>
    
    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech
          
    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell
   
    VERSIONS HISTORY
    0.1.0 -  2016-01-06 - The first version

    TODO
	Import the Active Directory module on startup
	Test parameters from pipeline
        
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
        [String[]]$UserName,
        [Parameter(Mandatory = $false)]
        [String]$FolderName = ".\"
    )
    
    begin {
        
        $Results = @()
        
    }
    
    process {
        
        $UserName | ForEach-Object -Process {
            
            $CurrentUserName = $_
            
            Try {
                
                $user = Get-ADUser $CurrentUserName -Properties thumbnailPhoto
                
            }
            Catch {
                
                [String]$MessageText = "Active Directory account for the user {0}" -f $CurrentUserName
                
                Write-Warning -Message $MessageText
                
                Continue
                
            }
            
            $Result = New-Object PSObject
            
            $Result | Add-Member -type NoteProperty -name UserSAMAccountName -value $user.SAMAccountName
            
            Try {
                
                [String]$UserPhotoFullFileName = "{0}\{1}.jpg" -f $FolderName, $CurrentUserName
                
                if ($user.thumbnailPhoto) {
                    
                    #   $user.thumbnailPhoto | Get-Member
                    
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
