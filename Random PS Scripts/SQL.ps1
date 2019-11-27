$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds
$DomainUser = "ihostadmin"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 
$inst1 = @'
   (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$T\Setup" -Name "Edition")."Edition"
   
'@
$inst = $inst1.Replace('$T',$P.scriptoutput)

$instA = @'
   (Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\$T\Setup" -Name "Version")."Version"
   
'@
$instB = $instA.Replace('$T',$P.ScriptOutput)

$D =@'
 (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" -Name "MSSQLSERVER")."MSSQLSERVER"
'@



$GetVM = Get-VM | where {$_.Name -like "*DB*" -and $_.Name  -notlike "*FND*"}
Foreach ($vm in $GetVM){
$P = Invoke-VMScript -ScriptText $D  -VM $vm -GuestUser $DomainUser -GuestPassword $DomainPword 
Write-Host $P
}