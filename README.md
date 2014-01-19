Get-WindowsHotfixes

Powershell script intended for checking Windows Server hosts for hotfixes and updates published for Hyper-V and Failover Cluster rule in Windows Server 2012

First version of the script was published at 24 May 2013 by Cristian Edwards on his blogs
http://blogs.technet.com/b/cedward/archive/2013/05/24/validating-hyper-v-2012-and-failover-clustering-2012-hotfixes-and-updates-with-powershell.aspx

next some improvements was added by [someone] and published at 26-06-2013 on this site
http://www.hyper-v.nu/archives/hvredevoort/2013/06/updated-windows-server-2012-hyper-v-and-cluster-hotfixes-and-updates/

next Niklas Akerlund at 28-06-2013 on his webpage published improved version
http://vniklas.djungeln.se/2013/06/28/hotfix-and-updates-check-of-hyper-v-and-cluster-with-powershell/

Please update if some contributions on this list are missed.

Sources for updates and hotfixes

Update List for Windows Server 2012 for Hyper-V are published here
http://social.technet.microsoft.com/wiki/contents/articles/15576.hyper-v-update-list-for-windows-server-2012.aspx

Recommended hotfixes and updates for Windows Server 2012-based Failover Clusters are published here
http://support.microsoft.com/kb/2784261

Script use xml files UpdatesListCluster.xml and UpdatesListHyperV.xml that are stored in folder with script. 
Initial release of this script and xml files is based on download at 2013-11-08 from Niklas Akerlund site.

Updates to UpdatesListCluster.xml
2013-11-17 - added KB2894464 - by Wojciech Sciesinski
2013-12-12 - added KB2894032,KB2903938,KB2908415,KB2779069,KB2905249 - by Wojciech Sciesinski based directly on KB Microsoft base
2014-01-11 - added KB2878635, removed KB2870270,KB2869923,KB2908415 - by Wojciech Sciesinski based directly on KB Microsoft base
2014-01-19 - added KB2911101 - by Wojciech Sciesinski based directly on KB Microsoft base

Updates to UpdatesListHyperV.xml
2013-11-17 - added KB2894032 - by Wojciech Sciesinski
2013-12-12 - added KB2894032,KB2902014,KB2894485 - by Wojciech Sciesinski based directly on KB Microsoft base
2014-01-11 - added KB2902821 - by Wojciech Sciesinski based directly on KB Microsoft base
2014-01-19 - added KB2916993,KB2913695,KB2913461,KB2901237 - by Wojciech Sciesinski based directly on KB Microsoft base


IDEAS 
- checking github website for updated xlm files and downloading it locally
- checking local folder or remote share for previously downloaded hotfixes and download only missed (MD5/SHA1 sum needed ?)
- add decompress option for downloaded hotfixes
- output report to file / with diferent format support
- add support for another systems and roles e.g. file services
- add test based on operating system version 

Some ideas implementent in Unstable branch