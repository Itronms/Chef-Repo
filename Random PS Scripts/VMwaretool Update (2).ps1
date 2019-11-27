$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName

Get-Module -ListAvailable VMware* | Import-Module | Out-Null

# connect to vCenter
Connect-VIserver 192.168.17.254 -Credential $creds
  
#Import vm name from csv file 
$csv = Import-Csv C:\Temp\ExportList.csv
$csv | ForEach-Object  {  
    $strNewVMName = $_.name  
      
    #Update VMtools without reboot  
    Get-VM $strNewVMName | Update-Tools 
  
   write-host "Updated $strNewVMName ------ "  
       
    $report += $strNewVMName  
}  
  
write-host "Sleeping ..."  
Sleep 120  
  
