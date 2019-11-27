$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds

$DomainUser1 = "itronms\melliott"
$DomainPWord1 = ConvertTo-SecureString -String "Sassaroo1254" -AsPlainText -Force

$csv = Import-Csv C:\Splunk.Csv
$csv | ForEach-Object {

    $Name = $_.Name

$DomainUser = "$Name\ihostadmin"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force

$Script2 = @'
Copy-Item "\\10.51.100.43\software\Splunk Builds\Universal Forwarders\Windows\splunkforwarder-7.3.0-657388c7a488-x64.msi" C:\BG\

'@


$Script = @'
msiexec.exe /i "C:\BG\splunkforwarder-7.3.0-657388c7a488-x64.msi" DEPLOYMENT_SERVER="splunk-deploy.itronms.local:8089"  SPLUNKPASSWORD="SpLunk$e<urityRu1es"  WINEVENTLOG_SEC_ENABLE=1  AGREETOLICENSE=Yes SET_ADMIN_USER=0 /quiet /qn

'@

$Script3 = @'
Remove-Item –path "C:\BG\splunkforwarder-7.3.0-657388c7a488-x64.msi"
'@

Write-Verbose -Message "Copying Files on  $Name." -Verbose
Invoke-VMScript -ScriptText $Script2  -ScriptType Powershell  -VM $Name -GuestUser $DomainUser1 -GuestPassword $DomainPWord1
Invoke-VMScript -ScriptText $Script  -ScriptType Powershell  -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord

Start-Sleep 30
Invoke-VMScript -ScriptText $Script3 -ScriptType Powershell  -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord
Write-Verbose -Message "Splunk have been installed on  $Name." -Verbose
}