# AUTHOR
# Dennis Laube - dennis@nutanix.com - https://www.virtualdennis.com
#
# NAME
# gather-vm-perf-stats.ps1
#
# SYNOPSIS
#   Gathers ESXi Host CPU and RAM performance summaries and datastore summaries
#
# SYNTAX
#   C:\scriptlocation\gather-vm-perf-stats.ps1
# 
# DESCRIPTION
#   Will collect the CPU and RAM performance summaries listed by ESXi host along with a summary for all datastores. Output will be saved to 3 CSV files.
#   CSV files collected:
#   "gather-host-perf-stats.csv" = Overview of each host with CPU and RAM usage info
#   "gather-host-perf-stats-datastores.csv" = Overview of all datastores including usage info
#   "gather-host-perf-stats-hosthw.csv" = Overview of the hardware in each host, namely CPU type / Mhz / RAM installed
#
# REMARKS
#   If you don't have VMware Powershell Cmdlets installed, follow this article to install:
#   https://www.virtualdennis.com/installing-vmware-powercli-cmdlets-from-the-powershell-gallery/
#
#   vCenter needs to have "Statistics Level 2" enabled in order for the below to work
#   This can be enabled via the vSphere Client -> Administration -> vCenter Server Settings -> Statistics, and make
#   sure "Level 2" is under "Statistics Level" column
#
#   Adapted from Original CPU-RAM script: https://community.spiceworks.com/scripts/show/2632-powercli-get-host-info
#   Adapted Original Datastore Script provided by http://vniklas.djungeln.se/2012/05/08/powercli-report-on-datastores-overprovision-and-number-of-powered-on-vm%C2%B4s/
#   Thanks to LucD for a wealth of helpful blog posts at http://www.lucd.info/
#
# Main Variables (Edit As Needed)
#
# Enter the IP Address of your vCenter Server
$vcenter = "https://itron-p-vm-vc.itronhosting.local"
# Enter the Domain Login information for your vCenter Server
$vcuser = "melliott"
# Enter the password for the user above
$vcpwd = "Sassaroo1254"
# The final CSV file will be placed in this location (Default is directory called "Scripts" under C:)
$scriptlocation = "C:\Temp\LLDC"


#####################################
## No need to edit beyond this point
#####################################

# Connect to VC
Connect-VIServer $vcenter -User $vcuser -Password $vcpwd -ea silentlycontinue -WarningAction 0

# Add PowerCLI Snapin - not needed unless scheduling this script
#Add-PSSnapin VMware.VimAutomation.Core

# Get Host hardware information
Get-VMHost |Sort Name |Get-View |
Select Name, 
@{N=“Type“;E={$_.Hardware.SystemInfo.Vendor+ “ “ + $_.Hardware.SystemInfo.Model}},
@{N=“CPU“;E={“PROC:“ + $_.Hardware.CpuInfo.NumCpuPackages + “ CORES:“ + $_.Hardware.CpuInfo.NumCpuCores + “ MHZ: “ + [math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0)}},
@{N=“MEM“;E={“” + [math]::round($_.Hardware.MemorySize / 1GB, 0) + “ GB“}} | Export-Csv $scriptlocation\TX-gather-host-perf-stats-hosthw.csv -noTypeInformation

# Get CPU and RAM detailed info and usage per host 
$allhosts = @()
$hosts = Get-VMHost

foreach($vmHost in $hosts){
  $hoststat = "" | Select HostName, MemoryInstalled, MemoryAllocated, MemoryConsumed, MemoryUsage, CPUMax, CPUAvg, CPUMin
  $hoststat.HostName = $vmHost.name
  
  $statcpu = Get-Stat -Entity ($vmHost)-start (get-date).AddDays(-30) -Finish (Get-Date)-MaxSamples 10000 -stat cpu.usage.average
  $statmemconsumed = Get-Stat -Entity ($vmHost)-start (get-date).AddDays(-30) -Finish (Get-Date)-MaxSamples 10000 -stat mem.consumed.average
  $statmemusage = Get-Stat -Entity ($vmHost)-start (get-date).AddDays(-30) -Finish (Get-Date)-MaxSamples 10000 -stat mem.usage.average
  $statmemallocated = Get-VMhost $vmHost.name | Select @{N="allocated";E={$_ | Get-VM | %{$_.MemoryGB} | Measure-Object -Sum | Select -ExpandProperty Sum}}
  $statmeminstalled = Get-VMHost $vmHost.name | select MemoryTotalGB
  $statmeminstalled = $statmeminstalled.MemoryTotalGB

  $cpu = $statcpu | Measure-Object -Property value -Average -Maximum -Minimum
  $memconsumed = $statmemconsumed | Measure-Object -Property value -Average
  $memusage = $statmemusage | Measure-Object -Property value -Average
  
  $CPUMax = "{0:N0}" -f ($cpu.Maximum)
  $CPUAvg = "{0:N0}" -f ($cpu.Average)
  $CPUMin = "{0:N0}" -f ($cpu.Minimum)
  $allocated = "{0:N0}" -f ($statmemallocated.allocated)
  $consumed = "{0:N0}" -f ($memconsumed.Average/1024/1024)
  $usage = "{0:P0}" -f ($memusage.Average/100)
  $installed = "{0:N0}" -f ($statmeminstalled)

  $CPUMax = $CPUMax.ToString() + " %"
  $CPUAvg = $CPUAvg.ToString() + " %"
  $CPUMin = $CPUMin.ToString() + " %"
  $MemoryInstalled = $installed.ToString() + " GB"
  $MemoryAllocated = $allocated.ToString() + " GB"
  $MemoryConsumed = $consumed.ToString() + " GB"
  $MemoryUsage = $usage.ToString()

  $hoststat.CPUMax = $CPUMax
  $hoststat.CPUAvg = $CPUAvg
  $hoststat.CPUMin = $CPUMin
  $hoststat.MemoryInstalled = $MemoryInstalled
  $hoststat.MemoryAllocated = $MemoryAllocated
  $hoststat.MemoryConsumed = $MemoryConsumed
  $hoststat.MemoryUsage = $MemoryUsage
  $allhosts += $hoststat
}
$allhosts | Select HostName, MemoryInstalled, MemoryAllocated, MemoryConsumed, MemoryUsage, CPUMax, CPUAvg, CPUMin | Export-Csv $scriptlocation\TX-gather-host-perf-stats.csv -noTypeInformation

#Get Datastore Usage and save to CSV
Get-Datastore | Select Name,@{N="TotalSpaceGB";E={[Math]::Round(($_.ExtensionData.Summary.Capacity)/1GB,0)}},@{N="UsedSpaceGB";E={[Math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace)/1GB,0)}}, @{N="ProvisionedSpaceGB";E={[Math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,0)}},@{N="NumVM";E={@($_ | Get-VM | where {$_.PowerState -eq "PoweredOn"}).Count}} | Sort Name | Export-Csv $scriptlocation\TX-gather-host-perf-stats-datastores.csv -noTypeInformation

#Disconnect from current vCenter
Disconnect-VIServer $vcenter -Confirm:$false