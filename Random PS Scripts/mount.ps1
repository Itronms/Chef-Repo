﻿Get-Module -ListAvailable VMware* | Import-Module | Out-Null
$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver itron-p-vm-vc.itronhosting.local -Credential $creds
$DomainUser = "root"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

$csv = Import-Csv C:\DNSL2.csv
$csv | ForEach-Object {
    $Name = $_.name
    Write-Verbose -Message "Getting ready to mount Settings on  $Name." -Verbose
Invoke-VMScript -ScriptText "umount -l /backup" -Scripttype Bash -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord
Invoke-VMScript -ScriptText 'mount -a' -Scripttype Bash -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord
}
