$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver 192.168.17.254  -Credential $creds
$DomainUser = "ihostadmin"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

$GetVM = Get-VM | Where-Object {$_.powerstate -eq 'PoweredOn'}
Foreach ($vm in $GetVM){

$inst1 = @'
   $T = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" -Name "MSSQLSERVER")."MSSQLSERVER"
   (Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\$T\Setup" -Name "Edition")."Edition"
   
'@


$instA = @'
   $T = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" -Name "MSSQLSERVER")."MSSQLSERVER"
   (Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\$T\Setup" -Name "Version")."Version"
   
'@


$D =@'
 (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" -Name "MSSQLSERVER")."MSSQLSERVER"
'@

$output = Invoke-VMScript -ScriptText $inst1  -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPword
$outputA = Invoke-VMScript -ScriptText $instA  -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPword
$vm | Select Name,@{N="SQL Edition";E={$output}},@{N="SQL Version";E={$outputA}} | Export-Csv C:\Temp\LVSWSQL.csv -NoTypeInformation -UseCulture -Append
}