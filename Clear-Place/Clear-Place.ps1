Clear-Place {
<#
.SYNOPSIS
 Permanently delete items from given places in the room
.DESCRIPTION
 Function intended for permanently delete items from given places in the room in the process of place cleaning.

.PARAM Room
 The area where there are places to clean.
.PARAM Place
 Places to be cleaned.
.PARAM StartDate
 Date of start of the process.
.PARAM Exclusion
 Items in this list will not be removed.
.PARAM Inclusion
 Items in this list will be removed permanently.
 
.EXAMPLE
 Delete all items from the fridge and cabinets in the kitchen at November 22, 2013
 
 Clear-Place -Romm kitchen -Place "fridge","cabinet" -StartDate 2013/11/22
 
.EXAMPLE
 Delete all items that belongs to groups milk, fishes, fruits from the fridge in the kitchen at November 22, 2013
 
 Clear-Place -Romm kitchen -Place "fridge" -StartDate 2013/11/22 -Exclusion "tableware","cutlery","equipment" `
 -Inclusion "milk","fish","fruit"

.NOTES
 License Info: This work is licensed under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007. `
 To view a copy of this license, visit http://www.gnu.org/licenses/gpl-3.0.txt.

 Version history
 1.0 – initial release, 2013/11/14
 
.LINK
 Sources https://github.com/it-praktyk/Clear-Place
#>

  [CmdletBinding()]

    param (
		[parameter(Mandatory=$true,ValueFromPipeline=$false)]
		[string]$Room="kitchen",		
		
        [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [array]$Places,
		
		[parameter(Mandatory=$true,ValueFromPipeline=$false)]
		[DateTime]$StartDate=(Get-Date).Date.AddDays(7),
				
		[parameter]
		[array]$Exclusion=("tableware","cutlery","equipment"),
		
		[parameter]
		[array]$Inclusion=("food","box","pot")
		
	)

	While (Get-Date -lt $StartDate) {
	
		Start-Sleep -Seconds 3600
		
	}
	
	$PlacesToClean=Get-Childitem -Path $Room | Where-Object { $_.Name -in $Place } 
	
	$PlacesToClean | ForEach-Object {
	
		$ItemsToRemove = Get-ChildItem -Path $_.Name | Select-Object { $_.GroupName -notcontains $Exclusion -or $_.GroupName -contains $Inclusion } |`
		Remove-Item -Recurse $true -Force $true -ErrorAction $SilentlyContinue 
	}
	
}