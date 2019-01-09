# Export-ADUserPhoto
## SYNOPSIS
Export the photos stored in an Active Directory and used by Outlook as users pictures/avatars and store them in jpg files.

## SYNTAX
```powershell
Export-ADUserPhoto [-Identity] <Object> [[-Path] <DirectoryInfo>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
The PowerShell Export-ADUserPhot function is intended for export the photos stored in an Active Directory (in the thumbnailPhoto property field) and used by Outlook, Lync, etc. as users pictures/avatars.

The function accept identity for Active Directory user provided from a command line or pipline (as a strings or Active Directory objects).

Exported files are stored on the disk with names <SAMAccountName>.jpg.

## PARAMETERS
### -Identity &lt;Object&gt;
Specifies an Active Directory user object by providing one of the following property values. The identifier in
parentheses is the LDAP display name for the attribute. The acceptable values for this parameter are:

 - A Distinguished Name
 - A GUID (objectGUID)
 - A Security Identifier (objectSid)
 - A SAM Account Name (sAMAccountName)

The cmdlet searches the default naming context or partition to find the object. If two or more objects are
found, the cmdlet returns a non-terminating error.

This parameter can also get this object through the pipeline or you can set this parameter to an object
instance.
```
Required?                    true
Position?                    1
Default value
Accept pipeline input?       true (ByValue)
Accept wildcard characters?  false
```

### -Path &lt;DirectoryInfo&gt;
Specifies the path to the location of the new item. Wildcards are not permitted.
```
Required?                    false
Position?                    2
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Force &lt;SwitchParameter&gt;
Allows the function to overwrite existing files. If not set prompt for overwrite will be displayed.
Even using the Force parameter, the cmdlet cannot override security restrictions.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```

## NOTES
###AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
###KEYWORDS: PowerShell, Active Directory, Exchange, thumbnailPhoto

###VERSIONS HISTORY
 - 0.1.0 - 2016-01-06 - The first version
 - 0.2.0 - 2016-01-07 - The function renamed to Export-ADUserPhoto, the parameter UserName renamed to Identity
 - 0.3.0 - 2016-01-09 - The function extended, help updated
 - 0.3.1 - 2016-01-10 - The type for parameter Identity corrected
 - 0.3.2 - 2016-01-10 - Keywords section updated
 - 0.3.3 - 2016-01-10 - Description, help updated, examples reformatted

###TODO
- the situation of write to disk error should be handled
- return results objects only if PassThru parameter provided (?)

###LICENSE
Copyright (c) 2016 Wojciech Sciesinski
This function is licensed under The MIT License (MIT)
Full license text: http://opensource.org/licenses/MIT

###DISCLAIMER
This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the script or documentation.

## EXAMPLES
### EXAMPLE 1

The identity of user from command line, the result file named <SAMAccountName>.jpg saved in the current directory

```powershell
    PS > Export-ADUserPhoto -Identity user1
    
    UserSAMAccountName    PhotoINActiveDirectoryExists    PhotoExported
    ------------------    ----------------------------    -------------
    user1                                         True             True
    
    PS > Get-ChildItem -Path .\
    
    Directory: C:\Users\Administrator\Desktop

    Mode                LastWriteTime     Length Name
    ----                -------------     ------ ----
    -a---          1/9/2016   2:40 PM        910 user1.jpg
```



### EXAMPLE 2

The identities of users from pipeline as an array of strings, the result files named <SAMAccountName>.jpg saved in the current directory, with the prompt for overwrite.
```powershell
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
```


### EXAMPLE 3

The identities of users from pipeline as Active Directory users objects, the result files named <SAMAccountName>.jpg saved in the current directory, without the prompt for overwrite.
```powershell
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
```
