$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds
$DomainUser = "root"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 
$GetVM = Get-VM | where {$_.Name -like "*FND-DB"}
Foreach ($vm in $GetVM){
Invoke-VMScript -ScriptText 'mkdir /backup' -Scripttype Bash -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPWord
Invoke-VMScript -ScriptText 'umount /mnt/backup' -Scripttype Bash -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPWord
Invoke-VMScript -ScriptText 'sed -i "s/mnt[/]//g" /etc/fstab' -Scripttype Bash -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPWord
Start-Sleep 5
Invoke-VMScript -ScriptText 'mount -a' -Scripttype Bash -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPWord
}