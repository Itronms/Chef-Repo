$server1 = "f:\xiserv\export" ## enter current source folder
$server2 = "G:\inetpub\ftproot\localuser\ENEL" ## enter your destination folder 
foreach ($server1 in gci $server1 -include *.ENEL -recurse)
 { 
 Move-Item -path $server1.FullName -destination  $server2 ## Move the files to the destination folder
 }