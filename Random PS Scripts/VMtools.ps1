$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds
$DomainUser = "ihostadmin"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force


$csv = Import-Csv C:\VMTools1.csv
$csv | ForEach-Object {

    $Name = $_.Name

Write-Verbose -Message "Mounting ISO on $Name." -Verbose

Get-CDDrive $Name | Set-CDDrive -StartConnected:$true -Connected:$true -IsoPath "[]/vmimages/tools-isoimages/windows.iso" -Confirm:$false

$Script = @'
D:\setup64.exe /S /v "/qn REBOOT=R ADDLOCAL=ALL"
'@

Write-Verbose -Message "Getting ready to install drivers on  $Name." -Verbose
Invoke-VMScript -ScriptText $Script  -ScriptType Powershell  -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord
Write-Verbose -Message "Drivers have been installed on  $Name." -Verbose


Start-Sleep 45

Write-Verbose -Message "Unmounting ISO on $Name." -Verbose
Get-VM -Name $name | Get-CDDrive | Where {$_.ISOPath -ne $null} | Set-CDDrive -NoMedia -Confirm:$false

Start-Sleep 10

}