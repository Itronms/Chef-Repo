$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName

# connect to vCenter
Connect-VIserver itron-p-vm-vc.itronhosting.local -Credential $creds

#Replace Variables Below. This may not be needed depending on how you want to run the script
$DomainUser = "LLTPAMI\administrator"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 


#Script Block that runs on the VM's for Windows and Linux
#This Script Changes DNS for all NIC's on Windows VM Input the DNS Address where 10.99.93.11 and 10.99.93.12 are
$DNSChange = 'Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses("172.24.19.6","172.24.19.7")'
#These Two Scripts modify the network-scripts config for the default Linux VM NIC used in LLDC The Old DNS goes on the left DNS and the New DNS IP Goes on the right side
$DNSLinux1 = 'cat /etc/sysconfig/network-scripts/ifcfg-ens192 | sed -e "s/DNS1=200.200.200.200/DNS1=10.50.1.1/" > /home/ifcfg-ens192'
$DNSLinux2 = 'cat /etc/sysconfig/network-scripts/ifcfg-ens192 | sed -e "s/DNS2=10.50.50.50/DNS2=10.50.1.2/" > /home/ifcfg-ens192'
#This script is ran after the above two to copy the modified file back to the network script location
$DNSLinuxCopy = 'mv /home/ifcfg-ens192 /etc/sysconfig/network-scripts/ifcfg-ens192 -f'
#Restarts services after DNS change
$DNSLinux3 = 'service network restart'
#For 2008 Server
$DNSChange2008 = 'netsh interface ip add dnsserver "Local Area Connection 6" 172.24.19.6 index=1;
                netsh interface ip add dnsserver "Local Area Connection 6" 172.24.19.7 index=2; 
                netsh interface ip delete dnsserver "Local Area Connection 6" 172.24.19.0 
                netsh interface ip delete dnsserver "Local Area Connection 6" 172.24.19.1'

#importing out CSV location C:\DNS.csv should have 4 headers name Username Password and OS
#This For block will run for each VM under the Name Column and connect to that VM with the supplied username and password in the CSV. If you were doing only itronhosting.local domain you could use the $Domacredential variable above.
#Then Delete the Username and password from the CSV and put in the $DomainCredential Variable on the Invoke-VMScript (See DNSReplacementScript.ps1)
$csv = Import-Csv C:\DNSFN12.csv
$csv | ForEach-Object {

    $Name = $_.name
    $Username = $_.Username
    $Password = $_.Password
    $OS = $_.OS

If ($OS -eq  "Windows"){
#if CSV Has OS Windows it runs this

Write-Verbose -Message "Getting ready to change IP Settings on  $Name." -Verbose
Invoke-VMScript -ScriptText $DNSChange -VM $Name -GuestUser $Username -GuestPassword $Password
Write-Verbose -Message "Assigned DNS Addresses [172.24.19.6,172.24.19.7] for [$Name]"  -Verbose
}

#If CSV has OS Linux it runs this
 elseif ($OS -eq "Linux"){
$DNSBefore2 = (Get-VM $Name).ExtensionData.Guest.net.dnsconfig.IpAddress
Write-Verbose -Message "Getting ready to change IP Settings on  $Name." -Verbose
Invoke-VMScript -ScriptText $DNSLinux1  -ScriptType Bash  -VM $Name -GuestUser root -GuestPassword cl0ckw!SE
Invoke-VMScript -ScriptText $DNSLinuxCopy -ScriptType Bash -VM $Name -GuestUser root -GuestPassword cl0ckw!SE
Invoke-VMScript -ScriptText $DNSLinux2 -ScriptType Bash -VM $Name -GuestUser root -GuestPassword cl0ckw!SE
Invoke-VMScript -ScriptText $DNSLinuxCopy -ScriptType Bash -VM $Name -GuestUser root -GuestPassword cl0ckw!SE
Invoke-VMScript -ScriptText $DNSLinux3 -ScriptType Bash -VM $Name -GuestUser root -GuestPassword cl0ckw!SE
}
