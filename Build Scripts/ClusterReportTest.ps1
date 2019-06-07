﻿# ------vCenter Targeting Varibles and Connection Commands Below------
# This section insures that the PowerCLI PowerShell Modules are currently active. The pipe to Out-Null can be removed if you desire additional
# Console output.
Get-Module -ListAvailable VMware* | Import-Module | Out-Null

$VC = Read-Host -Prompt "Which Data Center are you running?(TP or LL)"

if ($VC -eq 'TP'){$Connection = "esxtpll-vc01.itronms.local"}
elseif ($VC -eq 'LL'){$Connection = "itron-p-vm-vc.itronhosting.local"} 


# ------vSphere Targeting Variables tracked below------TE
$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName


# connect to vCenter
Connect-VIserver $Connection -Credential $creds

$a = "<style>" 
$a = $a + "BODY{background-color:white;}" 
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}" 
$a = $a + "TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:whitesmoke}" 
$a = $a + "TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:white}"
$a = $a + "</style>"


# $clusterName = "MyCluster"
$clusterName = "*"

foreach($cluster in Get-Cluster){
    $Time = Get-Date -DisplayHint Date
    $Title = "<H2>$cluster-$Time<H2>"
    $esx = $cluster | Get-VMHost
    $ds = Get-Datastore -VMHost $esx | where {$_.Type -eq "VMFS"}
    $cluster | Select @{N="VCname";E={$cluster.Uid.Split(':@')[1]}},
    @{N="DCname";E={(Get-Datacenter -Cluster $cluster).Name}},
    @{N="Clustername";E={$cluster.Name}},
    @{N="Total Physical Memory (GB)";E={($esx | Measure-Object -Property MemoryTotalGB -Sum).Sum}},
    @{N="Configured Memory GB";E={($esx | Measure-Object -Property MemoryUsageGB -Sum).Sum}},
    @{N="Available Memroy (GB)";E={($esx | Measure-Object -InputObject {$_.MemoryTotalGB - $_.MemoryUsageGB} -Sum).Sum}},
    @{N="Total CPU (Mhz)";E={($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum}},
    @{N="Configured CPU (Mhz)";E={($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum}},
    @{N="Available CPU (Mhz)";E={($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum}},
    @{N="Total Disk Space (GB)";E={($ds | where {$_.Type -eq "VMFS"} | Measure-Object -Property CapacityGB -Sum).Sum}},
    @{N="Configured Disk Space (GB)";E={($ds | Measure-Object -InputObject {$_.CapacityGB - $_.FreeSpaceGB} -Sum).Sum}},
    @{N="Available Disk Space (GB)";E={($ds | Measure-Object -Property FreeSpaceGB -Sum).Sum}},
    @{N="Number of VM's";E={($esx | Measure-Object -InputObject {$_.Extensiondata.Vm.Count} -Sum).Sum}}  | convertto-html -head $a -body $Title  | Sort-Object $cluster | Out-file C:\Temp\Clusterspec.htm -Append


}
Invoke-Expression C:\Temp\Clusterspec.htm