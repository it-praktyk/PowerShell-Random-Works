# New-RandomPerson
## SYNOPSIS
The PowerShell function intended to generate string with name of a random person.

## SYNTAX
```powershell
New-RandomPerson [-UseNationalCharset] [[-Sex] <String>] [[-Culture] <String>] [<CommonParameters>]
```

## DESCRIPTION
The function generate a random name of females or males based on selected culture in the format <FirstName><Space><LastName>.
The first and last names are randomly selected from the files delivered with the function for the selected culture (default is: en-US).

Currently supported cultures (in the alphabetical order):
- en-US
- pl-PL

Information about the culture files you can find [here](.\NAMES_SOURCES.md).


## PARAMETERS
### -UseNationalCharset &lt;SwitchParameter&gt;
If you would like use national diacritics.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Sex &lt;String&gt;
The sex of random person. Available values: female, male, both.
```
Required?                    false
Position?                    1
Default value                both
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Culture &lt;String&gt;
The culture used for generate - default is en-US.
```
Required?                    false
Position?                    2
Default value                en-US
Accept pipeline input?       false
Accept wildcard characters?  false
```

## INPUTS


## NOTES
AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net

KEYWORDS: PowerShell

VERSIONS HISTORY
- 0.1.1 - 2016-01-16 - The first version published as a part of the Doug's Finke NameIT PowerShell module https://github.com/dfinke/NameIT and included in the NameIT PowerShell module published to PowerShell Gallery with a version number 1.04 http://www.powershellgallery.com/packages/NameIT/1.04
- 0.2.0 - 2016-01-16 - The function renamed from 'person' to New-RandomPerson, the names for pl-PL culture added, the structure for csv changed to support national charsets, the license changed to MIT
- 0.3.0 - 2016-01-16 - The structure cultures files changes for support female/male last name grammar forms in some languages
- 0.3.1 - 2016-01-16 - The help section updated
- 0.4.0 - 2016-01-16 - The function corrected, situation where provided culture is incorrect handled


TO DO
- return output as an object
- add support for culture data provided as variable

LICENSE  
Copyright (c) 2016 Wojciech Sciesinski  
This function is licensed under The MIT License (MIT)  
Full license text: http://opensource.org/licenses/MIT

DISCLAIMER
This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the script or documentation.

## EXAMPLES
### EXAMPLE 1
```powershell
[PS] >New-RandomPerson

Justin Carter

The one name returned with random sex.
```


### EXAMPLE 2
```powershell
[PS] >1..3 | ForEach-Object -Process { New-RandomPerson -Sex female -culture en-US }

Jacqueline Walker
Julie Richardson
Stacey Powell

Three names returned, only women, from en-US culture
```
