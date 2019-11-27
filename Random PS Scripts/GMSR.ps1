$ver= "1.5"

# ------vCenter Targeting Varibles and Connection Commands Below------
# This section insures that the PowerCLI PowerShell Modules are currently active. The pipe to Out-Null can be removed if you desire additional
# Console output.
Get-Module -ListAvailable VMware* | Import-Module | Out-Null

# ------vSphere Targeting Variables tracked below------TE
$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName


# connect to vCenter
Connect-VIServer esxtpll-vc01.itronms.local -Credential $creds


$script:customer = Read-Host -Prompt "Please enter customer code "

$script:customernumber = Read-Host -Prompt "Please enter customer vLAN "

$script:Cluster = Read-Host -Prompt "Is this Production or NonProduction?(P Or NP) "

if ($script:Cluster -eq 'NP') {$Type = Read-Host -Prompt "Is this Test, Dev or QA?(T, D or Q)"}

if ($Script:Cluster -eq 'P') {$Char = 'P'}

elseif ($Type -eq 'T') {$Char = 'T'}

elseif ($Type -eq 'D') {$Char = 'D'}

elseif ($Type -eq 'Q') {$Char = 'Q'}  

$FCS = Read-Host -Prompt "Do you have FCS Servers? (Yes or No) "

$IEE = Read-Host -Prompt "Do you have IEE Servers? (Yes or No) "

$PM = Read-Host -Prompt "Do you have PM Servers? (Yes or No) "

if ($script:Cluster -eq 'P') {$TargetCluster = Get-Cluster -Name "ItronMS-TP-LL-UCS-PROD";$DomainControllerVMName = "$script:customer-P-DC01";$DC02VMName = "$script:customer-P-DC02"}

if ($script:Cluster -eq 'NP') {$TargetCluster = Get-Cluster -Name "ItronMS-TP-LL-UCS-DEV";$DomainControllerVMName = "$script:customer-NP-DC01";$DC02VMName = "$script:customer-NP-DC02"}

$UIP = ($script:customernumber - 500)

if ($script:Cluster -eq 'P') {$NP = $script:customer}
elseif ($script:Cluster -eq 'NP') {$NP = $script:customer + "NP"}

$FQDN = $NP + "AMI"

$Dom = $NP + "AMI.local"

$DomainUser2 = "$script:customerAMI\ihostadmin"
$DomainPWord2 = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential2 = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser2, $DomainPWord2 
 

$IPV6 = @'
-errorAction Silently Continue
Get-AdComputer -Filter {Enabled -eq $True -and OperatingSystem -like "*Windows*" -and Name -notlike "*-DC*"} | Foreach {
    Invoke-Command -ComputerName $_.Name -ScriptBlock { 
    Get-NetAdapter -Name "Ethernet*" | Foreach {
    $local:ifname = $_.Name
    $local:ifindex = $_.ifIndex
    $_ | Get-NetIPAddress | Foreach {
        if ($_.AddressFamily -eq "IPv4") { $script:ipv4address = $_.IPAddress }
        if (($_.AddressFamily -eq "IPv6") -And ($_.IPAddress -match "^fdfa:ffff:0:\d+:10:")) {$script:ipv6address = $_.IPAddress}
}
        if ($script:ipv4address) {
            if ($script:ipv4address.split('.')[1] -eq 50 -or 150 -or 250) {
                $local:nvlan = (([Int]$script:ipv4address.split('.')[1])*10) + [Int]$script:ipv4address.split('.')[2]
                $local:dnvlan = 500+[Int]$script:ipv4address.split('.')[2]
                $local:v6pre = "fdfa:ffff:0:"+$local:nvlan+":"
                $local:newv6 = $local:v6pre + [String]::Join(':',$script:ipv4address.split('.'))
                $local:newgw = $local:newv6.Substring(0, $local:newv6.lastIndexOf(':'))+":1"
                $local:dns1 = "fdfa:ffff:0:"+$local:dnvlan+":10:50:"+[Int]$script:ipv4address.split('.')[2]+":11"
                $local:dns2 = "fdfa:ffff:0:"+$local:dnvlan+":10:50:"+[Int]$script:ipv4address.split('.')[2]+":12"
                "$local:ifname $script:ipv4address Did not find a v6 address configured, may I suggest $local:newv6 for interface: $local:ifindex gateway $local:newgw"
                Enable-NetAdapterBinding -Name $local:ifname -ComponentID ms_tcpip6 
                New-NetIPAddress -InterfaceIndex $local:ifindex -IPAddress $local:newv6 -PrefixLength 64 -AddressFamily IPv6 
                Remove-NetRoute -DestinationPrefix ::/0 -ErrorAction SilentlyContinue 
                New-NetRoute -DestinationPrefix ::/0 -InterfaceIndex $local:ifindex -NextHop $local:newgw 
                "DNS Addresses will be: $local:dns1 and $local:dns2"
                Set-DnsClientServerAddress -InterfaceIndex $local:ifindex -ServerAddresses $local:dns1, $local:dns2 
                netsh int ipv6 set int $local:ifname routerdiscovery=disable 
                netsh int ipv6 set int $local:ifname managedaddress=disable 
               
            } 
        }
    }
}

    }
'@

$Expire = 'Set-ADUser -Identity IHostAdmin -PasswordNeverExpires $True'

$Mount1 = @'
          echo "10.150.$IP.20:/FND /backup nfs auto 0 0" >> /etc/fstab
'@

$Mount = $Mount1.Replace('$IP',$UIP)

$FNDV62 = @'
          echo "IPV6ADDR=fdfa:ffff:0:$vlan:10:50:$IP:33/64" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@

$FNDV6 = $FNDV62.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)

$FNDGateway1 = @'
            echo "IPV6_DEFAULTGW=fdfa:ffff:0:$vlan:10:50:$IP:1" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$FNDGateway = $FNDGateway1.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)

$FNDDNS1 = @'
            echo "DNS3=fdfa:ffff:0:$vlan:10:50:$IP:11" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$FNDDNS = $FNDDNS1.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)

$FNDDNS12 = @'
            echo "DNS4=fdfa:ffff:0:$vlan:10:50:$IP:12" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$FNDDNS2 = $FNDDNS12.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)


$FNDDBV62 = @'
          echo "IPV6ADDR=fdfa:ffff:0:1$vlan:10:150:$IP:33/64" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@

$FNDDBV6 = $FNDDBV62.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)


$FNDDBGateway1 = @'
            echo "IPV6_DEFAULTGW=fdfa:ffff:0:1$vlan:10:150:$IP:1" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$FNDDBGateway = $FNDDBGateway1.Replace('$IP',$UIP).Replace('c$vlan',$script:customernumber)


$TPSV62 = @'
          echo "IPV6ADDR=fdfa:ffff:0:2$vlan:10:250:$IP:17/64" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@

$TPSV6 = $TPSV62.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)


$TPSGateway1 = @'
            echo "IPV6_DEFAULTGW=fdfa:ffff:0:2$vlan:10:250:$IP:1" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$TPSGateway = $TPSGateway1.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)

$NPSInstall = 'Install-WindowsFeature -ConfigurationFilePath C:\Temp\NPSRoleConfig.xml -Restart'


$Lin1 = "root"
$Lin2 = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force 

$FND1 = "$script:customer-$Char-FND-APP"
$FND2 = "$script:customer-$Char-FND-DB"
$TPS  = "$script:customer-$Char-TPS"

Write-Verbose -Message "Creating Backup Mount on FND-DB Server" -Verbose

Write-Verbose -Message "Setting IPV6 Address for FND-APP" -Verbose

Invoke-VMScript -ScriptText 'sed -i "s/IPV6_AUTOCONF=yes/IPV6_AUTOCONF=no/g" /etc/sysconfig/network-scripts/ifcfg-ens192' -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDV6 -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDGateway -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS2 -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText 'service network restart' -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2


Write-Verbose -Message "Setting IPV6 Address For FND-DB" -Verbose

Invoke-VMScript -ScriptText 'sed -i "s/IPV6_AUTOCONF=yes/IPV6_AUTOCONF=no/g" /etc/sysconfig/network-scripts/ifcfg-ens192' -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDBV6 -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDBGateway -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS2 -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText 'service network restart' -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2


Write-Verbose -Message "Setting IPV6 Address For TPS" -Verbose

Invoke-VMScript -ScriptText 'sed -i "s/IPV6_AUTOCONF=yes/IPV6_AUTOCONF=no/g" /etc/sysconfig/network-scripts/ifcfg-ens192' -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $TPSV6 -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $TPSGateway -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS2 -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText 'service network restart' -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Write-Verbose -Message "Configuring NPS Server" -Verbose

Invoke-VMScript -ScriptText $NPSInstall -VM $script:customer-$Char-NPS -GuestUser $DomainUser2 -GuestPassword $DomainPWord2

Write-Verbose -Message "Restarting FND-DB Server" -Verbose

Restart-VM -VM $FND2 -Confirm:$false 

# End of Script