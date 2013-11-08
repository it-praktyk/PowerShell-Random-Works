# Remake of Christian Edwards script to make it more flexible
# http://blogs.technet.com/b/cedward/archive/2013/05/31/validating-hyper-v-2012-and-failover-clustering-hotfixes-with-powershell-part-2.aspx
#
# Niklas Akerlund 2013-06-28

param
(
    [parameter(ValueFromPipeline=$true,  
                   Position=0)]
    [string]$Hostname,
    [parameter(ValueFromPipeline=$true, 
                   Position=1)]
    $ClusterName,
    [switch]$Download,
    [string]$DownloadPath
)

#Getting current execution path
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
$listofHotfixes = @()

#Loading list of updates from XML files

[xml]$SourceFileHyperV = Get-Content $dir\UpdatesListHyperV.xml
[xml]$SourceFileCluster = Get-Content $dir\UpdatesListCluster.xml

$HyperVHotfixes = $SourceFileHyperV.Updates.Update
$ClusterHotfixes = $SourceFileCluster.Updates.update

#Getting installed Hotfixes from all nodes of the Cluster
if ($ClusterName){
    $Nodes = Get-Cluster $ClusterName | Get-ClusterNode | Select -ExpandProperty Name
}else
{
    $Nodes = $Hostname
}
foreach($Node in $Nodes)
{
$Hotfixes = Get-HotFix -ComputerName $Node |select HotfixID,description

foreach($RecomendedHotfix in $HyperVHotfixes)
{
        $witness = 0
        foreach($hotfix in $Hotfixes)
        {
                If($RecomendedHotfix.id -eq $hotfix.HotfixID)
                {
                    $obj = [PSCustomObject]@{
                        HyperVNode = $Node
                        HotfixType = "Hyper-V"
                        RecomendedHotfix = $RecomendedHotfix.Id
                        Status = "Installed"
                        Description = $RecomendedHotfix.Description
                        DownloadURL =  $RecomendedHotfix.DownloadURL
                    } 
                   
                   $listOfHotfixes += $obj
                    $witness = 1
                 }
        }  
        if($witness -eq 0)
        {
            
            $obj = [PSCustomObject]@{
                    HyperVNode = $Node
                    HotfixType = "Hyper-V"
                    RecomendedHotfix = $RecomendedHotfix.Id
                    Status = "Not Installed"
                    Description = $RecomendedHotfix.Description
                    DownloadURL =  $RecomendedHotfix.DownloadURL
            } 
                   
            $listofHotfixes += $obj
 
        }

}

foreach($RecomendedClusterHotfix in $ClusterHotfixes)
{
        $witness = 0
        foreach($hotfix in $Hotfixes)
        {
                If($RecomendedClusterHotfix.id -eq $hotfix.HotfixID)
                {
                    $obj = [PSCustomObject]@{
                        HyperVNode = $Node
                        HotfixType = "Cluster"
                        RecomendedHotfix = $RecomendedClusterHotfix.Id
                        Status = "Installed"
                        Description = $RecomendedClusterHotfix.Description
                        DownloadURL =  $RecomendedClusterHotfix.DownloadURL
                    } 
                   
                   $listOfHotfixes += $obj
   
                   $witness = 1
                 }
        }  
        if($witness -eq 0)
        {
            $obj = [PSCustomObject]@{
                HyperVNode = $Node
                HotfixType = "Cluster"
                RecomendedHotfix = $RecomendedClusterHotfix.Id
                Status = "Not Installed"
                Description = $RecomendedClusterHotfix.Description
                DownloadURL =  $RecomendedClusterHotfix.DownloadURL
            } 
                   
            $listOfHotfixes += $obj
          
        }
}
}
if ($Download){
    foreach($RecomendedHotfix in $HyperVHotfixes){
        if ($RecomendedHotfix.DownloadURL -ne ""){
            Start-BitsTransfer -Source $RecomendedHotfix.DownloadURL -Destination $DownloadPath 
        }
    }
    foreach($RecomendedClusterHotfix in $ClusterHotfixes){
        if ($RecomendedClusterHotfix.DownloadURL -ne ""){
            Start-BitsTransfer -Source $RecomendedClusterHotfix.DownloadURL -Destination $DownloadPath 
        }
    }
}

$listofHotfixes