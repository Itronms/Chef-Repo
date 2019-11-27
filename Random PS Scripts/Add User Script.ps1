$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds

$DomainUser = "ihostadmin"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

$GetVM = Get-VM | where {$_.Name -like "*DC01*"}

Foreach ($vm in $GetVM)
{


 $Script1 =@'
            $Domain = $env:USERDNSDOMAIN
            $Domain1 = $Domain.Split(".")[0]
            New-ADUser -Name "splunksrvc" -GivenName "splunksrvc" -Surname "splunksrvc" -DisplayName "splunksrvc" -SamAccountName "splunksrvc"  -UserPrincipalName "splunksrvc@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "b1fMymQsM65j" -Force) -PasswordNeverExpires 1 -Path "OU=Service Accounts,OU=Itron,DC=$Domain1,DC=local" -Enabled 1;
'@


Invoke-VMScript -ScriptText $Script1 -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPWord
}
