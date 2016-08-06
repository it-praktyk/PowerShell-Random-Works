This script is intended for for compression files with given extension that are older than given time. NTFS builtin compression are used.

Examples of use

Compress files with extension log in folder c:\test that are older than 20 minutes
Start-NTFSFilesCompression -Path C:\test -OlderThan 20

Compress files with extension txt in folder c:\test that are older than 1 hour
Start-NTFSFilesCompression -Path C:\test -OlderThan 1 -TimeUnit hours -Extension "txt"

Script is published also in Technet Script Gallery
http://gallery.technet.microsoft.com/Compress-files-by-46f5b406
