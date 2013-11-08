Get-WindowsHotfixes

Powershell script intended for checking Windows Server hosts for hotfixes and updates published for Hyper-V and Failover Cluster rule in Windows Server 2012

First version of the script was published at 24 May 2013 by Cristian Edwards on his blogs
http://blogs.technet.com/b/cedward/archive/2013/05/24/validating-hyper-v-2012-and-failover-clustering-2012-hotfixes-and-updates-with-powershell.aspx

next some improvements was added by [someone] and published at 26-06-2013 on this site
http://www.hyper-v.nu/archives/hvredevoort/2013/06/updated-windows-server-2012-hyper-v-and-cluster-hotfixes-and-updates/

next Niklas Akerlund at 28-06-2013 on his webpage published improved version
http://vniklas.djungeln.se/2013/06/28/hotfix-and-updates-check-of-hyper-v-and-cluster-with-powershell/

Please update if some contribution on this list are missed.

Sources for updates and hotfixes

Update List for Windows Server 2012 for Hyper-V are published here
http://social.technet.microsoft.com/wiki/contents/articles/15576.hyper-v-update-list-for-windows-server-2012.aspx
Recommended hotfixes and updates for Windows Server 2012-based Failover Clusters are published here
http://support.microsoft.com/kb/2784261

Script use xml that are stored in folder with scripts

Initial release of this script is based on download at 2013-11-08 from Niklas Akerlund site 

IDEAS 
- download only needed hotfixes
- add decompress option for downloaded hotfixes
- output report to file / with diffrent format support
