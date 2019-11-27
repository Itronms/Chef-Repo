$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds
$DomainUser = "ihostadmin"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 
$script = @"
driverquery
"@
$GetVM = Get-VM | where {$_.Name -notlike "*TPS*" -and $_.Name -notlike "*FND*" -and $_.Name -like "*DB*"}
Foreach ($vm in $GetVM){
$output = Invoke-VMScript -ScriptText $script  -VM $vm -GuestCredential $DomainCredential
$vm | Select Name,@{N="vShield Agent present";E={$output -match "vsepflt"}} | Export-Csv C:\Temp\VMToolsTEMP2.csv -NoTypeInformation -UseCulture -Append
}