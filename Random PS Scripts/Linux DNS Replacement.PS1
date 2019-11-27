$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver itron-p-vm-vc.itronhosting.local -Credential $creds
$DomainUser = "root"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 
$S1 = 
$S2 = 
$csv = Import-Csv C:\DNSL.csv
$csv | ForEach-Object {
    $Name = $_.name  
Write-Verbose -Message "Getting ready to change IP Settings on  $Name." -Verbose
Invoke-VMScript -ScriptText 'sed -i "s/172.24.19.0/172.24.19.6/g ; s/172.24.19.1/172.24.19.7/g" /etc/sysconfig/network-scripts/ifcfg-e*' -Scripttype Bash -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord
Invoke-VMScript -ScriptText 'sed -i "s/172.24.19.0/172.24.19.6/g ; s/172.24.19.1/172.24.19.7/g" /etc/resolv.conf' -Scripttype Bash -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord
}
