$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver itron-p-vm-vc.itronhosting.local -Credential $creds

$allvms = @()
$allhosts = @()
$hosts = Get-VMHost
$vms = Get-VM | Where {$_.Name -like "DTE-*"}


foreach($vm in $vms){
  $vmstat = "" | Select VmName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin
  $vmstat.VmName = $vm.name
  
  $statcpu = Get-Stat -Entity ($vm)-start (get-date).AddDays(-30) -Finish (Get-Date)-MaxSamples 10000 -stat cpu.usage.average
  $statmem = Get-Stat -Entity ($vm)-start (get-date).AddDays(-30) -Finish (Get-Date)-MaxSamples 10000 -stat mem.usage.average

  $cpu = $statcpu | Measure-Object -Property value -Average -Maximum -Minimum
  $mem = $statmem | Measure-Object -Property value -Average -Maximum -Minimum
  
  $vmstat.CPUMax = $cpu.Maximum
  $vmstat.CPUAvg = $cpu.Average
  $vmstat.CPUMin = $cpu.Minimum
  $vmstat.MemMax = $mem.Maximum
  $vmstat.MemAvg = $mem.Average
  $vmstat.MemMin = $mem.Minimum
  $allvms += $vmstat
}
$allvms | Select VmName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin | Export-Csv "c:\Temp\Report21342.csv" -noTypeInformation