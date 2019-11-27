$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver itron-p-vm-vc.itronhosting.local -Credential $creds
$DomainUser = "ihostadmin"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 
$script = @"
$inst = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
foreach ($i in $inst)
{
   $p = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$i
   (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Edition
   (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Version
}
"@
$GetVM = Get-VM | where where{$_.PowerState -eq 'PoweredOn'}
Foreach ($vm in $GetVM){
$output = Invoke-VMScript -ScriptText $script  -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPword
$vm | Select Name,@{N="ISM Version";E={$output}} | Export-Csv C:\Temp\SQLTestLLDC.csv -NoTypeInformation -UseCulture -Append
}