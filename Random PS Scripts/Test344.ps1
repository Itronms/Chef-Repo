$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds
$DomainUser = ".\ihostadmin"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 
$GetVM = Get-VM | 
Foreach ($vm in $GetVM){
Invoke-VMScript -ScriptText 'driverquery' -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPWord

}