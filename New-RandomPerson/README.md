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

The goal for this function is preparing the list of users to fulfill Active Directory in lab environments.

## Information about the culture files and information for the culture files Contributors you can find [here](\NAMES_SOURCES.md).


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

## NOTES
AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net

KEYWORDS: PowerShell

VERSIONS HISTORY
- 0.1.1 - 2016-01-16 - The first version published as a part of the Doug's Finke NameIT PowerShell module https://github.com/dfinke/NameIT and included in the NameIT PowerShell module published to PowerShell Gallery with a version number 1.04 http://www.powershellgallery.com/packages/NameIT/1.04
- 0.2.0 - 2016-01-16 - The function renamed from 'person' to New-RandomPerson, the names for pl-PL culture added, the structure for csv changed to support national charsets, the license changed to MIT
- 0.3.0 - 2016-01-16 - The structure cultures files changes for support female/male last name grammar forms in some languages
- 0.3.1 - 2016-01-16 - The help section updated
- 0.4.0 - 2016-01-16 - The function corrected, situation where provided culture is incorrect handled
- 0.4.1 - 2016-01-17 - UTF-8 encoding declared for the cultures files import added
- 0.4.2 - 2016-01-18 - Incorrect usage the cmdlet Get-Random corrected
- 0.5.0 - 2016-01-19 - The function output returned as an object, help updated


TO DO
- return output as an object
- add support for culture data provided as variable
- add the list of cities for countries/cultures - in a separate files
- add support for forms like 'Mr.' https://en.wikipedia.org/wiki/Mr. (?)

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
[PS] > New-RandomPerson

FirstName LastName DisplayName  Sex
--------- -------- -----------  ---
Jamie     Torres   Jamie Torres Female

The one name returned with random sex.
```


### EXAMPLE 2
```powershell
[PS] > 1..3 | ForEach-Object -Process { New-RandomPerson -Sex both -culture en-US }

FirstName LastName  DisplayName       Sex
--------- --------  -----------       ---
Carrie    Ross      Carrie Ross       Female
Vincent   Gutierrez Vincent Gutierrez Male
Jared     Ramirez   Jared Ramirez     Male

Three names returned, from en-US culture.
```


### EXAMPLE 3
```powershell
[PS] > 1..3 | ForEach-Object -Process { New-RandomPerson -Sex Male -culture pl-PL -UseNationalCharset }

FirstName LastName  DisplayName     Sex
--------- --------  -----------     ---
Jacek     Kozłowski Jacek Kozłowski Male
Szymon    Michalak  Szymon Michalak Male
Eryk      Rutkowski Eryk Rutkowski  Male

Three names returned, only mens, from pl-PL culture with Polish diacritics.
```