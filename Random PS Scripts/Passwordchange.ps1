$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds

$DomainUser = "ihostadmin"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

$GetVM = Get-VM | where {$_.Name -like "*DC01*" -and  $_.Name -notlike "*IMS-TPLL*" -and $_.Name -notlike "*VECT*" -and $_.Name -notlike "*TECO*"}

Foreach ($vm in $GetVM)
{


 $Script1 =@'
            $Domain = $env:USERDNSDOMAIN
            $Domain1 = $Domain.Split(".")[0]
            Add-ADGroupMember -Identity "Domain Admins" -Members @("LRamalingam")
            Set-ADAccountPassword -Identity LRamalingam -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "B@ng4c0lo" -Force)
'@


Invoke-VMScript -ScriptText $Script1 -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPWord
}
