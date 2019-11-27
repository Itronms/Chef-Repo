$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName

Get-Module -ListAvailable VMware* | Import-Module | Out-Null

# connect to vCenter
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds
  
#Import vm name from csv file 
$rundate = get-date -format "M-d-yyyy-hh-mm"
Start-Transcript -Path C:\Deploy\"$($rundate)-$($env:UserName)-deployment.txt"
$deployfile = Get-FileName "C:\deploy" 
import-csv $deployfile  |  
foreach {  
    $strNewVMName = $_.name  
      
    #Update VMtools without reboot  
    Get-Cluster ItronMS-TP-LL-UCS-PROD | Get-VM $strNewVMName | Update-Tools –NoReboot  
  
   write-host "Updated $strNewVMName ------ "  
       
    $report += $strNewVMName  
}  
  
write-host "Sleeping ..."  
Sleep 120  
  
