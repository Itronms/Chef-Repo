$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName

$VC = Read-Host -Prompt "Which Data Center are you running?(TP,LL,TX,LV)"

if ($VC -eq 'TP'){$Connection = "esxtpll-vc01.itronms.local"; $File="LLTP"}
elseif ($VC -eq 'LL'){$Connection = "itron-p-vm-vc.itronhosting.local"; $File="LLDC"} 
elseif ($VC -eq 'TX'){$Connection = "esxtx-vc01.itronms.local"; $File="LLTX"}
elseif ($VC -eq 'LV'){$Connection = "esxtx-vc01.itronms.local"; $File="LV"}

Connect-VIserver $Connection -Credential $creds

$FinalResult = @()

foreach($vm in Get-View -ViewType "VirtualMachine"){

       $totalCapacity = $totalFree = 0

       $vm.Guest.Disk | %{

            $object = New-Object -TypeName PSObject

            $Capacity = "{0:N0}" -f [math]::Round($_.Capacity / 1MB)

            $totalCapacity += $_.Capacity

            $totalFree += $_.FreeSpace

            $Freespace = "{0:N0}" -f [math]::Round($_.FreeSpace / 1MB)

            $Percent = [math]::Round(($FreeSpace)/ ($Capacity) * 100)

            $PercentFree = "{0:P0}" -f ($Percent/100)

            $object | Add-Member -MemberType NoteProperty -Name "Server Name" -Value $vm.Name

            $object | Add-Member -MemberType NoteProperty -Name Disk -Value $_.DiskPath

            $object | Add-Member -MemberType NoteProperty -Name "Capacity MB" -Value $Capacity

            $object | Add-Member -MemberType NoteProperty -Name "Free MB" -Value $FreeSpace

            $object | Add-Member -MemberType NoteProperty -Name "Free %" -Value $PercentFree

            $finalResult += $object

        }

        $object = New-Object -TypeName PSObject

        $object | Add-Member -MemberType NoteProperty -Name "Server Name" -Value $vm.Name

        $object | Add-Member -MemberType NoteProperty -Name Disk -Value 'SubTotal'

        $object | Add-Member -MemberType NoteProperty -Name "Capacity MB" -Value ("{0:N0}" -f ($totalCapacity/1MB))

        $object | Add-Member -MemberType NoteProperty -Name "Free MB" -Value ("{0:N0}" -f ($totalFree/1MB))

        $object | Add-Member -MemberType NoteProperty -Name "Free %" -Value ("{0:P0}" -f ($totalFree/$totalCapacity))

        $finalResult += $object

    }

$Date = Get-Date -f MMddyy
$File= $VC + "-" + $Date
$finalResult | Export-Csv "C:\Temp\$file.csv" -NoTypeInformation  -UseCulture  