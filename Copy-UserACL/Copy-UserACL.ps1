<#
    .SYNOPSIS
    Copy the ACL for file or folder from one user to other user

    .DESCRIPTION
    Takes a ACE file or folder  and copies its ACL to one or more other files.

    .PARAMETER FromPath
    Path of the File to get the ACL from.

    .PARAMETER SourceUser
    User account that is used as source ACE for files.

    .PARAMETER DestinationUser
    User account that is used as destination ACE for files.

    .PARAMETER Passthru
    Returns an object representing the security descriptor.  By default, this cmdlet does not generate any output.

    .INPUTS
    You can Pipeline any object with a Property named "PSPath", "FullName" or "Destination".

    .EXAMPLE
    PS> Copy-UserACE Referencefile.txt (dir c:\temp\*xml) -SourceUser domain\user1 -DestinationUser domain\user2

    .EXAMPLE
    PS> dir c:\files *.xml -recurse | Copy-Acl ReferenceFile.txt

    .LINK
    Get-Acl
    Set-Acl

.	NOTES
	Author:  Wojciech Sciesinski

	- 0.2.0 - 2016-08-06 - The repository moved from https://github.com/it-praktyk/Copy-UserACL to https://github.com/it-praktyk/PowerShell-Random-Works

    LICENSE  
    Copyright (c) 2016 Wojciech Sciesinski  
    This function is licensed under The MIT License (MIT)  
    Full license text: https://opensource.org/licenses/MIT  

#>
#requires -Version 2.0
[CmdletBinding(SupportsShouldProcess=$true)]
param(
[Parameter(position=0,Mandatory=$true)]
[String]$Path,

[Parameter(Position=1,Mandatory=$true,ValueFromPipelineByPropertyName=$false)]
[String]$SourceUser,

[Parameter(Position=2,Mandatory=$true,ValueFromPipelineByPropertyName=$false)]
[String]$DestinationUser,

[Parameter(Mandatory=$false)]
[Switch]$Recurse,

[Parameter(Mandatory=$false)]
[Switch]$PassThru
)
Begin
{
    if (! (Test-Path $Path))
    {
        $ErrorRecord = New-Object System.Management.Automation.ErrorRecord  (
            (New-Object Exception "FromPath ($Path) does not point to an existing object"),
            "Copy-UserACE.TestPath",
            "ObjectNotFound",
            $FromPath
         )

        $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        
    }
    
    $objSourceUser = New-Object System.Security.Principal.NTAccount($SourceUser)
    
    $objDestinationUser = New-Object System.Security.Principal.NTAccount($DestinationUser)
    
}
Process
{

    $Objects = Get-ChildItem -Path $Path -Recurse:$Recurse
    
    foreach ($Object in @($Objects))
    {
   #     if ($pscmdlet.ShouldProcess($Dest))
   #     {
   #         Set-Acl -Path $Dest -AclObject $acl -Passthru:$PassThru
   #     }
   
   $acl = Get-Acl -Path $object 
   
   $filteredacl=$acl.GetAccessRules($true,$true, [System.Security.Principal.NTAccount]) | where {$_.IdentityReference -eq $objSourceUser} 
   
   $filteredacl
    
    $userRights = $filteredacl.FileSystemRights.tostring()
    
    $userRights.gettype()
  
   $colRights = [System.Security.AccessControl.FileSystemRights]::$filteredacl.FileSystemRights 
   Write-Host $colRights

    $colRights | Get-Member
    
    
    $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::$filteredacl.IsInherited 
    $InheritanceFlag
    
    $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::$filteredacl.PropagationFlags 
    $PropagationFlag

    $objType =[System.Security.AccessControl.AccessControlType]::$filteredacl.AccessControlType
   $objType
   
   $newACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objDestinationUser, $userRights , $objType) 
   
   #$NewACL =$acl.AddAccessRule($newACE)
   
   #Set-Acl -Path $object -AclObject $NewACL
   
   #$exitACL = get-acl -Path $object
   
   #$exitACL.GetAccessRules($true,$true, [System.Security.Principal.NTAccount]) | where {$_.IdentityReference -eq $objSourceUser} 
    }
}