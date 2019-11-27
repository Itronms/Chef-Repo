﻿$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName

Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds


$DomainUser = "root"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

$S1 = 'sed -i "s/10.50.93.11/172.24.19.6/g ; s/10.50.93.12/172.24.19.7/g" /etc/sysconfig/network-scripts/ifcfg-e*'
$S2 = 'sed -i "s/10.50.93.11/172.24.19.6/g ; s/10.50.93.12/172.24.19.7/g" /etc/resolv.conf'


$csv = Import-Csv C:\DNSL.csv
$csv | ForEach-Object {

    $Name = $_.name
    
Write-Verbose -Message "Getting ready to change IP Settings on  $Name." -Verbose
Invoke-VMScript -ScriptText $S1 -Scripttype Bash -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord
Invoke-VMScript -ScriptText $S2  -Scripttype Bash -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord

}