Function Invoke-CommandAndWait {

<#
    .SYNOPSIS
    Function used to execute external commands in the sequence

    .DESCRIPTION
    Function used to execute external command (e.g. updates exe files) and wait for completion.

    .PARAMETER ExecutionFileName
    Command what need to be run - e.g. notepad.exe

    .PARAMETER ExecutionParameters
    Parameters that will added to runned application.

    .PARAMETER ExecutionFilePath
    Path to the folder in which file to run is stored - full or relative to the currect folder. If ommited the current folder is used.

    .PARAMETER ExecuteCommandAfterCompletion
    Command to executed after main task is completed

    .PARAMETER Quiet
    When the parameter Quiet is used a progress indicator will not be displayed. A progress indicator is displayed by default.

    .PARAMETER ExpectedDurationTime
    Expected time to run a command - used only for progress bar.

    .PARAMETER UpdateProgressBarIntervalSeconds
    How often progress bar will be updated

    .EXAMPLE
    Invoke-CommandAndWait -ExecutionFileName notepad.exe -ExecutionFilePath c:\windows\system32 -ExpectedDurationTimeMinutes 2 `
    -UpdateProgressBarIntervalSeconds 5 -ExecuteCommandAfterCompletion "calc.exe"

    Run notepad.exe file, check every 5 seconds if still is running. After closing notepad.exe run calc.exe

    .EXAMPLE
    Import-CSV -Path .\commands.txt | ForEach { Invoke-CommandAndWait -ExecutionFileName $_.FileName -ExecutionFilePath $_.CheckedProcessName `
    -ExpectedDurationTimeMinutes 2 -UpdateProgressBarIntervalSeconds 10 }

    Import command from the csv file, run them sequentially with updateing progress every 10 seconds

    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell

    VERSION HISTORY
    - 0.4.0 - 2016-08-23 - The first version published to GitHub specially for Giancarlo P.
    - 0.4.1 - 2018-03-03 - Formats updated
    - 0.5.0 - 2018-03-04 - Added the quiet parameter, updated errors handling, help updated
                            The parameter CheckedProcessName removed

    TODO
    - use scriptblock except strings to provide commands to execute
    - replace Invoke-WmiMethod (?)

    LICENSE
    Copyright (c) 2016 Wojciech Sciesinski
    This function is licensed under The MIT License (MIT)
    Full license text: https://opensource.org/licenses/MIT

#>

    [cmdletbinding(DefaultParameterSetName='WriteProgressParamSet')]

    Param (

        [Parameter(mandatory=$true)]
        [String]$ExecutionFileName,

        [Parameter(mandatory=$false)]
        [String]$ExecutionParameters,

        [Parameter(mandatory=$false)]
        [String]$ExecutionFilePath=".\",

        [Parameter(mandatory=$false)]
        [String]$ExecuteCommandAfterCompletion,

        [Parameter(mandatory=$false,ParameterSetName='QuietParamSet')]
        [Switch]$Quiet,

        [Parameter(mandatory=$false,ParameterSetName='WriteProgressParamSet')]
        [int]$ExpectedDurationTimeMinutes=5,

        [Parameter(mandatory=$false,ParameterSetName='WriteProgressParamSet')]
        [int]$UpdateProgressBarIntervalSeconds=10

    )

    BEGIN {

        $Wait = $true

        if ([String]::IsNullOrEmpty($ExecutionParameters)) {

            [String]$CommandToRun = "{0}\{1}" -f $ExecutionFilePath, $ExecutionFileName

        }
        else {

            [String]$CommandToRun = "{0}\{1} {2}" -f $ExecutionFilePath, $ExecutionFileName, $ExecutionParameters

        }

        [System.String]$MessageString = "Command to run: {0}" -f $CommandToRun

        Write-Verbose  -Message $MessageString

        [int]$i=$UpdateProgressBarIntervalSeconds

    }

    PROCESS {

        $process = Invoke-WmiMethod -Class win32_process -Name create -ArgumentList $CommandToRun

        if ( $process.ProcessId -eq $null ) {

            [String]$MessageString = "Under of executing the command {0} an error occured." -f $CommandToRun

            Write-Error -Message $MessageString

        }
        else {

            While ($Wait) {

                if (Get-Process -Id $process.ProcessId -ErrorAction SilentlyContinue) {

                    if ( $PSCmdlet.ParameterSetName -ne 'QuietParamSet' ) {

                        Write-Progress -Activity "Executed file $ExecutionFileName" -PercentComplet (($i / ($ExpectedDurationTimeMinutes * 60)) * 100) -Status " is still running"

                        Start-Sleep -Seconds $UpdateProgressBarIntervalSeconds

                        if (($i += $UpdateProgressBarIntervalSeconds) -ge ($ExpectedDurationTimeMinutes * 60)) {

                            $i = $UpdateProgressBarIntervalSeconds

                        }
                        else {

                            $i += $UpdateProgressBarIntervalSeconds

                        }

                    }
                    else {

                        Start-Sleep -Seconds 5

                    }

                }
                else {

                    $Wait = $false

                }

            }

        }

    }

    END {

        if ($ExecuteCommandAfterCompletion) {

            $afterprocess = Invoke-WmiMethod -Class win32_process -Name create -ArgumentList $ExecuteCommandAfterCompletion

            if ( $null -eq $afterprocess.ProcessId ) {

                [String]$MessageString = "Under of executing the command {0} an error occured." -f $ExecuteCommandAfterCompletion

                Write-Error -Message $MessageString

            }

        }

    }

}