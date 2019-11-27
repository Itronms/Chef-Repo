# Begin Script --------------------------------------------------
# CSV Deployment Script 
# Modified 7/20/2017 by Lance Pelton & Fred Rotinski
# Version 4.9
# ------vCenter Targeting Varibles and Connection Commands Below------
# This section insures that the PowerCLI PowerShell Modules are currently active. The pipe to Out-Null can be removed if you desire additional
# Console output.
Get-Module -ListAvailable VMware* | Import-Module | Out-Null

# Function to determine largest Datastore

Function Get-Largest()
{
$gldatastores = Get-VMHost -Location $_.cluster|Get-Datastore| where {$_.name -notlike "*AFF*"}|Select Name,FreeSpaceGB
 
#Sets some static info
$LargestFreeSpace = "0"
$LargestDatastore = $null
 
#Performs the calculation of which datastore has most free space
foreach ($gldatastore in $gldatastores) {
    if ($gldatastore.FreeSpaceGB -gt $LargestFreeSpace) { 
            $LargestFreeSpace = $gldatastore.FreeSpaceGB
            $LargestDatastore = $gldatastore.name
            }
        }
        return $LargestDatastore
}

Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog()|Out-Null
    $OpenFileDialog.filename
}


# Designate CSV file and log file
$customer = Read-Host "Enter Customer Abbreviation"
$rundate = get-date -format "M-d-yyyy-hh-mm"
Start-Transcript -Path C:\Deploy\"$($customer)-$($rundate)-$($env:UserName)-deployment.txt"
$deployfile = Get-FileName "C:\deploy"

$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName


# connect to vCenter
Connect-VIserver itron-p-vm-vc.itronhosting.local -Credential $creds

$adcreds = Get-Credential -Message 'Enter credentials for joining server to domain'



# Import Build List

import-csv $deployfile -UseCulture|%{
#determine datastore
If ($_.Hostname -like "*-DB*"){ 
$_.Datastore = "vsanDatastore"
} ELSE {
$_.Datastore = Get-Largest
}
#make initial Clone
New-VM -Name $_.Hostname -Template $_.Template -ResourcePool $_.cluster -Datastore $_.Datastore -Location Staging
#strip NICs
Get-NetworkAdapter $_.Hostname|Remove-NetworkAdapter -confirm:$false

#Add Appropriate NIC(s)
New-NetworkAdapter -VM $_.Hostname -NetworkName $_.VLAN -Type Vmxnet3 -StartConnected:$True -Confirm:$false 
#IF ($_.Hostname -like '*-DB') {
        #IF ($_.cluster -eq 'Prod6') {New-NetworkAdapter -VM $_.Hostname -Portgroup VL16-Backup -Type Vmxnet3 -Startconnected:$True -confirm:$false}
        #ELSE {New-NetworkAdapter -VM $_.Hostname -Portgroup 16_Isolated -Type Vmxnet3 -Startconnected:$True -confirm:$false} }    

#create customization script
Get-OSCustomizationSpec -Name $_."Guest Spec"|New-OSCustomizationSpec -Name $_.Hostname
#add Network information to script
Get-OSCustomizationSpec -Name $_.Hostname|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
IF ($_.winlinux -eq 'win'){ 
    Get-OSCustomizationSpec -Name $_.Hostname |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $_.IP -SubnetMask $_.SubNet -DefaultGateway $_.Gateway -Dns $_.ns1,$_.ns2 -Position 1
    Get-OSCustomizationSpec -Name $_.Hostname |Set-OSCUstomizationSpec -Domain $_.domain -DomainCredentials $adcreds -DnsServer $_.ns1,$_.ns2
    }
ELSE {
    Get-OSCustomizationSpec -Name $_.Hostname |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $_.IP -SubnetMask $_.SubNet -DefaultGateway $_.Gateway -Position 1
    Get-OSCustomizationSpec -Name $_.Hostname |Set-OSCustomizationSpec -Domain $_.domain -DnsServer $_.ns1,$_.ns2
    }
#IF ($_.Hostname -like '*-DB'){Get-OSCustomizationSpec -Name $_.Hostname |New-OSCustomizationNicMapping -IpMode UseDhcp -Position 2}

#apply spec and resources
Get-VM $_.Hostname|Set-VM -MemoryGB $_.vRAM -NumCpu $_.vCPU -OSCustomizationSpec $_.Hostname -Confirm:$false
Get-VM $_.Hostname|Set-Annotation -CustomAttribute "Created by" -Value "VMBuild Script(run as $User)"
$DateTime=Get-Date
Get-VM $_.Hostname|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $_.Hostname|Set-Annotation -CustomAttribute "Deployment Script Version" -Value "v4.9"
Get-VM $_.Hostname|Set-Annotation -CustomAttribute "Deployment Template" -Value $_.Template

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $_.Hostname).ExtensionData.ReconfigVM_Task($spec)
Write-Host $_.Hostname' Built:'
Write-Host "Booting"
Start-sleep -Seconds 15
# Power On New VM
Start-VM $_.Hostname
wait-tools -VM $_.Hostname
remove-oscustomizationspec $_.Hostname -confirm:$false
dnscmd $_.ns1 /RecordAdd $_.domain $_.Hostname A $_.IP

}
Stop-Transcript
Disconnect-VIServer -confirm:$false
# SIG # Begin signature block
# MIIJZgYJKoZIhvcNAQcCoIIJVzCCCVMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTc8kVCmDJE0IvrG6VdGKMFMS
# 27qgggbMMIIGyDCCBLCgAwIBAgIKeayL9AABAAABYTANBgkqhkiG9w0BAQUFADBV
# MRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxHDAaBgoJkiaJk/IsZAEZFgxJdHJvbkhv
# c3RpbmcxHjAcBgNVBAMTFUl0cm9uIEhvc3RlZCBTZXJ2aWNlczAeFw0xNzA3MTMx
# NjExMjVaFw0xODA3MTMxNjExMjVaMIGWMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwx
# HDAaBgoJkiaJk/IsZAEZFgxJdHJvbkhvc3RpbmcxDjAMBgNVBAsTBUl0cm9uMQ4w
# DAYDVQQLEwVVc2VyczEPMA0GA1UECxMGTmV0T3BzMRcwFQYDVQQLEw5JbmZyYXN0
# cnVjdHVyZTEVMBMGA1UEAxMMTGFuY2UgUGVsdG9uMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEAiYk864rnOPvBUE194Yuy7JM3SjvRgyd4TcutAO5D2aar
# 6ojcNsi1ftiGTudJqyqWnAKD35Fntrvq9M1zW5epIwmrflJCWlaSyxkx8IvqF+Hg
# 2pWuOaE3p0GSK/i+jhaLDVmOqw4MeBUjF7NXgZffWfQ6OBvFyCcfTVT6K1W3hD6l
# jt+BMxwrK6syJOERESuc2/RbrGCi43gIQ6PGOwkUxYaoivP5oFxYmKoHFE8eXM+c
# pspGM67kBKlu43FQQMi5jiYHnRHPeFEila3yjFURFcvhZXE+0nFXT6h3mwke8wMw
# 3j8RRWFgxmxf3h5JMhtc5StAxgFR/EC7r071/nbrVQIDAQABo4ICVjCCAlIwJQYJ
# KwYBBAGCNxQCBBgeFgBDAG8AZABlAFMAaQBnAG4AaQBuAGcwEwYDVR0lBAwwCgYI
# KwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMB0GA1UdDgQWBBTRI3f1VPIA1uZZLzd1
# JcT+z3uplzAfBgNVHSMEGDAWgBThdW5j77/M1HhD4j1suV2FGBqG2zCBtwYDVR0f
# BIGvMIGsMIGpoIGmoIGjhk1odHRwOi8vYWNjZXNzLml0cm9uLWhvc3RpbmcuY29t
# L3BvcnRhbC9jZXJ0cy9JdHJvbiUyMEhvc3RlZCUyMFNlcnZpY2VzKDEpLmNybIZS
# aHR0cDovL2lob3N0LXdlYjEuaXRyb25ob3N0aW5nLmxvY2FsL3BvcnRhbC9jZXJ0
# cy9JdHJvbiUyMEhvc3RlZCUyMFNlcnZpY2VzKDEpLmNybDCB0gYIKwYBBQUHAQEE
# gcUwgcIwgb8GCCsGAQUFBzAChoGybGRhcDovLy9DTj1JdHJvbiUyMEhvc3RlZCUy
# MFNlcnZpY2VzLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1T
# ZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPUl0cm9uSG9zdGluZyxEQz1sb2Nh
# bD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1
# dGhvcml0eTA1BgNVHREELjAsoCoGCisGAQQBgjcUAgOgHAwabHBlbHRvbkBJdHJv
# bkhvc3RpbmcubG9jYWwwDQYJKoZIhvcNAQEFBQADggIBACUbbaERkUdmm9i86iHa
# MXOUcyaEOTjdpwohrgeeNtrSVqBhz+PAcVXglMralrOjv8Tdhbp87ap6D7n9xIcz
# LWUOIvyFoDoChufSs9ApMyFYVdcV6v/kAfOeBxTa65ArOZimqE3uPr5LFNZL9Kne
# xBHvdHXDGlP5V1/Ya6s0L7KG8jWFOT2o2ikn7VKhbCcTKTbZCqe0WRIfVZVyMD6q
# Aaoklpt0Uby/bXXTOPrYyKcxOtwBnxVQ0C1JUR3A5i9EV5Jz+RhWhSPQmd/bPB9Q
# NKX72osmsqQsX35tEdF/1XB9M4UOx12FZIJgE3zGNd/Xgbt7S42dHqvYT+cCCx1F
# Us/0kZYCuQn5/a2XowGXFWLwpLC2nI+OMuq0IxSGaG1s6sIIoKWYDK67lqRJ4kf0
# eIA20vMop5wqRR+51oQch5iv36Dbo80QKrADphxCdMsCKXmXC1fCspkEAe3ZE/OE
# n2x+04i5WWCSQRwnNhIiDHuG37yG/MTuawI+RccWgFUWb0pDdbmOwdJ0XR+m7pbe
# hH7V6uyZ/ATPbBAHvBQPadzMtdCwZTYANU70Lo75ATYKDVW7ASGfUFMBYgaoBT+5
# H73TwBefE8sw6QLKgyNEcwLR4oXHMaa3UolmHxSW/coz4GpFu8lfj6EXV1jEeNt1
# myvEDlfvVqzJtjH7OuwiEZY9MYICBDCCAgACAQEwYzBVMRUwEwYKCZImiZPyLGQB
# GRYFbG9jYWwxHDAaBgoJkiaJk/IsZAEZFgxJdHJvbkhvc3RpbmcxHjAcBgNVBAMT
# FUl0cm9uIEhvc3RlZCBTZXJ2aWNlcwIKeayL9AABAAABYTAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQU2qbZ2V9hgvrac5+40EWFKyv73skwDQYJKoZIhvcNAQEBBQAEggEAE4rg+fdV
# 355araN9cjOnVUFM1L4ASYHV0vI9iFGGH8SrmZfr03eFC/0Otd7soi31fIA7UZKm
# EfNH6hubUrkn8iFww9kCbX1iz9SpbDknu35dN4EOel6b9WZkbYAO+7eWwCIXE/EW
# PV5J2qo3JWIpsbfd6waLn3LdD5f+tUjsYdGI5rVvyqLd4zsTykHmu/AMlFPsMAw5
# E5MlQjMnFKPhs73FfQDaa3CrboR63MxYfeHIYKUaZUZelwzplitBnlqk8kyvHcF5
# TusGFLfa2kyuQ/Q/Ql+IlWpUg8JWipWY98qsXYCz4dfQ/3NiabgaILPZFi4a385D
# u5JeMdFF5GUixQ==
# SIG # End signature block
