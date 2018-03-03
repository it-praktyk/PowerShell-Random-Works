Function Invoke-CommandAndWait {

<#
    .SYNOPSIS
    Function used to execute external commands in the sequence

    .DESCRIPTION
    Function used to execute external command (e.g. updates exe files) and wait for completion.

    .EXAMPLE
    Invoke-CommandAndWait -ExecutionFileName notepad.exe -CheckedProcessName notepad -ExecutionFilePath c:\windows\system32 -ExpectedDurationTimeMinutes 2 `
    -UpdateProgressBarIntervalSeconds 5 -ExecuteCommandAfterCompletion "calc.exe"

    Run notepad.exe file, check every 5 seconds if still is running. After closing notepad.exe run calc.exe

    .EXAMPLE
    Import-CSV -Path .\commands.txt | ForEach { Invoke-CommandAndWait -ExecutionFileName $_.FileName -CheckedProcessName $_.CheckedProcessName -ExecutionFilePath $_.CheckedProcessName `
    -ExpectedDurationTimeMinutes 2 -UpdateProgressBarIntervalSeconds 10 }

    Import command from the csv file, run them sequentially with updateing progress every 10 seconds

    .PARAMETER ExecutionFileName
    Command what need to be run - e.g. notepad.exe

    .PARAMETER CheckedProcessName
    Process name to check - for exe file file name without extension generally is used.

    .PARAMETER ExecutionParameters
    Parameters that will added to runned application.

    .PARAMETER ExecutionFilePath
    Path to the folder in which file to run is stored - full or relative to the currect folder. If ommited the current folder is used.

    .PARAMETER ExecuteCommandAfterCompletion
    Command to executed after main task is completed

    .PARAMETER ExpectedDurationTime
    Expected time to run a command - used only for progress bar.

    .PARAMETER $UpdateProgressBarIntervalSeconds
    How often progress bar will be updated

    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell,

    VERSION HISTORY
    - 0.4.0 - 2016-08-23 - The first version published to GitHub specially for Giancarlo P.
    - 0.4.1 - 2018-03-03 - Formats updated

    TODO
    - use scriptblock except strings to provide commands to execute
    - replace Invoke-WmiMethod

    LICENSE
    Copyright (c) 2016 Wojciech Sciesinski
    This function is licensed under The MIT License (MIT)
    Full license text: https://opensource.org/licenses/MIT

    #>

    [cmdletbinding()]

    Param (

    [Parameter(mandatory=$true,ValueFromPipeline=$false,Position=0)]
    [String]$ExecutionFileName,

    [Parameter(mandatory=$true,ValueFromPipeline=$false,Position=1)]
    [String]$CheckedProcessName,

    [Parameter(mandatory=$false,ValueFromPipeline=$false,Position=2)]
    [String]$ExecutionParameters,

    [Parameter(mandatory=$false,ValueFromPipeline=$false)]
    [String]$ExecutionFilePath=".\",

    [Parameter(mandatory=$false,ValueFromPipeline=$false)]
    [String]$ExecuteCommandAfterCompletion,

    [Parameter(mandatory=$false,Position=3)]
    [int]$ExpectedDurationTimeMinutes=5,

    [Parameter(mandatory=$false)]
    [int]$UpdateProgressBarIntervalSeconds=10

    )

BEGIN {

    $Wait = $true

    If (-not ([String]::IsNullOrEmpty($ExecutionParameters))) {

        [String]$CommandToRun = "$ExecutionFilePath\$ExecutionFileName"

    }
    Else {

        [String]$CommandToRun = "$ExecutionFilePath\$ExecutionFileName $ExecutionParameters"
    }

    [System.String]$MessageString = "Command to run: {0}" -f $CommandToRun

    Write-Verbose  -Message $MessageString

    [int]$i=$UpdateProgressBarIntervalSeconds

}

PROCESS {

        $process = Invoke-WmiMethod -Class win32_process -Name create -ArgumentList $CommandToRun


        While ($Wait) {

            if (Get-Process -Id $process.ProcessId -ErrorAction SilentlyContinue) {

                Write-Progress -Activity "Executed file $ExecutionFileName" -PercentComplet (($i / ($ExpectedDurationTimeMinutes * 60)) * 100) -Status " is still running"

                Start-Sleep -s $UpdateProgressBarIntervalSeconds

                if (($i += $UpdateProgressBarIntervalSeconds) -ge ($ExpectedDurationTimeMinutes * 60)) {

                    $i = $UpdateProgressBarIntervalSeconds
                }
                Else {

                    $i += $UpdateProgressBarIntervalSeconds

                }

            }
            Else {

                $Wait = $false

            }

        }

    }

    END {

        If ($ExecuteCommandAfterCompletion) {

            $process = Invoke-WmiMethod -Class win32_process -Name create -ArgumentList $ExecuteCommandAfterCompletion

        }

}

}