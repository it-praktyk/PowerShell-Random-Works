Function Import-LinuxVariable {

<#

    .SYNOPSIS
    The function intended to import to PowerShell variables from the files prepared to source on Linux

    .DESCRIPTION
    The function read, parse the file containing variables prepared to be source (the source command) on Linux.

    Comments, empty lines are ommitted. Only lines which start from the export keyword are processed to be
    exported/declared as variables in PowerShell

    .EXAMPLE

    PS> Get-Content -Path .\variables.sh

    #Some comments - will be skipped

        export $COMPUTER="SV-027"
    export $DOMAIN="LOCAL.TEST"

    In the variables.sh files some lines are intentionally indented

    PS> Import-LinuxVariable -Path .\variables.sh

    PS> Get-Variable -Name Domain

    <<<<>>>>>

    .LINK
    https://github.com/it-praktyk/PowerShell-Random-Works

    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech

    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell, Linux, source, variables

    VERSIONS HISTORY
    0.1.0 -  2018-02-19 - The initial version

    TODO

    LICENSE
    Copyright (c) 2018 Wojciech Sciesinski
    This function is licensed under The MIT License (MIT)
    Full license text: https://opensource.org/licenses/MIT

#>

    [Cmdletbinding()]

    Param(
        [Parameter(Mandatory=$true)]
        [String[]]$Path,
        [Parameter(Mandatory=$false)]
        [String]$Scope=1
    )


    [String[]]$Variables = $(Get-Content -Path .\variables.sh | Select-String -Pattern "export\ ")

    ForEach ( $Variable in $Variables) {

        $TrimedLine = $Variable.Replace('export $','').Trim()

        Try {

            $VariableName = ($TrimedLine.Split('=',[System.StringSplitOptions]::RemoveEmptyEntries))[0]

            $VariableValue = ($TrimedLine.Split('=',[System.StringSplitOptions]::RemoveEmptyEntries))[1]

            New-Variable -Name $VariableName -Value $VariableValue -Scope $Scope

        }

        Catch {

            [String]$MessageText = "The line $Variable can't be exported as variable"

            Write-Error -Message $MessageText

        }

    }

}