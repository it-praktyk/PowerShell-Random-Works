# @(1..10) | foreach { copy-item -Path source.log -Destination "$_.log" -Force }

 @(1..10) | foreach { copy-item -Path source.txt -Destination "$_.txt" -Force }


Function Set-FileTimeStamps

{

 Param (

    [Parameter(mandatory=$true)]

    [string[]]$path,

    [datetime]$date,
    [int]$difference)

    $datetemp = $date.AddMinutes($difference)

    Get-ChildItem -Path $path |

    ForEach-Object {

     $_.CreationTime = $datetemp

     $_.LastAccessTime = $datetemp

     $_.LastWriteTime = $datetemp }

	} #end function Set-FileTimeStamps


$logs=Get-ChildItem -Filter '*.txt'


$i=-10

ForEach ( $log in $logs ) {


   Set-FileTimeStamps -path $log.fullname -date $(get-date) -difference $i

   $i = $($i - 10)

}

#Get-ChildItem | where { $_.name -ne 'source.log' } | remove-item

