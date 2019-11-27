$vmName = "DTE-P-PM-DB"

$stat = "datastore.totalReadLatency.average","datastore.totalWriteLatency.average",
  "datastore.numberReadAveraged.average","datastore.numberWriteAveraged.average"
$entity = Get-VM -Name $vmName
$start = (Get-Date).AddHours(-1)

$dsTab = @{}
Get-Datastore | Where {$_.Type -eq "VMFS"} | %{
  $key = $_.ExtensionData.Info.Vmfs.Uuid
  if(!$dsTab.ContainsKey($key)){
    $dsTab.Add($key,$_.Name)
  }
  else{
    "Datastore $($_.Name) with UUID $key already in hash table"
  }
}

Get-Stat -Entity $entity -Stat $stat -Start $start |
Group-Object -Property {$_.Entity.Name} | %{
  $vmName = $_.Values[0]
  $VMReadLatency = $_.Group |
    where {$_.MetricId -eq "datastore.totalReadLatency.average"} |
    Measure-Object -Property Value -Average |
    Select -ExpandProperty Average
  $VMWriteLatency = $_.Group |
    where {$_.MetricId -eq "datastore.totalWriteLatency.average"} |
    Measure-Object -Property Value -Average |
    Select -ExpandProperty Average
  $VMReadIOPSAverage = $_.Group |
    where {$_.MetricId -eq "datastore.numberReadAveraged.average"} |
    Measure-Object -Property Value -Average |
    Select -ExpandProperty Average
  $VMWriteIOPSAverage = $_.Group |
    where {$_.MetricId -eq "datastore.numberWriteAveraged.average"} |
    Measure-Object -Property Value -Average |
    Select -ExpandProperty Average
  $_.Group | Group-Object -Property Instance | %{
    New-Object PSObject -Property @{
      VM = $vmName
      Host = $_.Group[0].Entity.Host.Name
      Datastore = $dsTab[$($_.Values[0])]
      Start = $start
      DSReadLatencyAvg = [math]::Round(($_.Group | 
          where {$_.MetricId -eq "datastore.totalReadLatency.average"} |
          Measure-Object -Property Value -Average |
          Select -ExpandProperty Average),2)
      DSWriteLatencyAvg = [math]::Round(($_.Group | 
          where {$_.MetricId -eq "datastore.totalWriteLatency.average"} |
          Measure-Object -Property Value -Average |
          Select -ExpandProperty Average),2)
      VMReadLatencyAvg = [math]::Round($VMReadLatency,2)
      VMWriteLatencyAvg = [math]::Round($VMWriteLatency,2)
      VMReadIOPSAvg = [math]::Round($VMReadIOPSAverage,2)
      VMWriteIOPSAvg = [math]::Round($VMWriteIOPSAverage,2)
    }
  }
} | Export-Csv c:\temp\report.csv -NoTypeInformation -UseCulture