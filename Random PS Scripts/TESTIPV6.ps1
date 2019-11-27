 $Test = 'netsh int ipv6 set int Ethernet0 routerdiscovery=disable
netsh int ipv6 set int Ethernet0 managedaddress=disable

Get-AdComputer -Filter {Enabled -eq $True -and OperatingSystem -like "*Windows*" -and Name -notlike "*-DC01"} | Foreach {
    Invoke-Command -ComputerName $_.Name -ScriptBlock { 
    "------------------------------------------------------------------------------"
    Hostname
    "------------------------------------------------------------------------------"
    Get-NetAdapter -Name "Ethernet*" | Foreach {
    $local:ifname = $_.Name
    $local:ifindex = $_.ifIndex
    $_ | Get-NetIPAddress | Foreach {
        if ($_.AddressFamily -eq "IPv4") { $script:ipv4address = $_.IPAddress }
        if (($_.AddressFamily -eq "IPv6") -And ($_.IPAddress -match "^fdfa:ffff:0:\d+:10:")) {
            $script:ipv6address = $_.IPAddress
        }
    
	    if (($_.AddressFamily -eq "IPv6") -And !($_.IPAddress -match "^fdfa:ffff:0:\d+:10:") -And !($_.IPAddress -match "^fe80")) {
            "Found Dynamic IPv6:" + $_.IPAddress
            "Applying Fix to turn off DHCPv6 and Stateless"
            netsh int ipv6 set int $local:ifname routerdiscovery=disable
            netsh int ipv6 set int $local:ifname managedaddress=disable
            ipconfig /registerdns | Select-String "Regist" | Write-Host
        }
    }
    if ($script:ipv6address) {
        "Found manual ipv6 address, validating pairing with ipv4"
        $script:ipv6address -match "^fdfa:ffff:0:(\d+):(\d+):(\d+):(\d+):(\d+)$" |Out-Null
        $local:rmatch = $matches
        $script:vlan = $local:rmatch[1]
        if ((($vlan -match "^15\d{2}$") -And ($local:rmatch[3] -eq "150")) -Or (($vlan -match "^5\d{2}$") -And ($local:rmatch[3] -eq "50"))) {
            $local:64con = $local:rmatch[2]+"."+$local:rmatch[3]+"."+$local:rmatch[4]+"."+$local:rmatch[5]
            if ($script:ipv4address -eq $local:64con) {
                "VALID IP Pair for VLAN $vlan $script:ipv4address / $script:ipv6address"
                "    DNS addresses are: "+(Get-DNSClientServerAddress -InterfaceIndex $local:ifindex -AddressFamily ipv6).ServerAddresses
            } else {
                "!!INVALID IP Pair for VLAN $vlan $script:ipv4address / $script:ipv6address please correct it"
            }
        } Else {
            "VLAN ID in IPv6 Address is invalid"
        }
    } else {
        if ($script:ipv4address) {
            if ($script:ipv4address.split(".")[1] -eq 50 -or 150 -or 250) {
                $local:nvlan = (([Int]$script:ipv4address.split(".")[1])*10) + [Int]$script:ipv4address.split(".")[2]
                $local:dnvlan = 500+[Int]$script:ipv4address.split(".")[2]
                $local:v6pre = "fdfa:ffff:0:"+$local:nvlan+":"
                $local:newv6 = $local:v6pre + [String]::Join(":",$script:ipv4address.split("."))
                $local:newgw = $local:newv6.Substring(0, $local:newv6.lastIndexOf(":"))+":1"
                $local:dns1 = "fdfa:ffff:0:"+$local:dnvlan+":10:50:"+[Int]$script:ipv4address.split(".")[2]+":11"
                $local:dns2 = "fdfa:ffff:0:"+$local:dnvlan+":10:50:"+[Int]$script:ipv4address.split(".")[2]+":12"
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
}
Get-AdComputer -Filter{Enabled -eq $True -and OperatingSystem -like "*Windows*"} | Foreach { invoke-command -computername $_.Name -Scriptblock {hostname; ipconfig /flushdns}}
dnscmd localhost /zoneprint CPUTAMI.LOCAL |Select-String fdfa:ffff:0'

Invoke-VMScript -ScriptText $Test -VM LLTP-NP-DC01 -GuestUser LLTPAMI\ihostadmin -GuestPassword cl0ckw!SE