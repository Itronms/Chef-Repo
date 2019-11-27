$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds

$DomainUser = "root"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

$csv = Import-Csv C:\Temp\RH.csv
$csv | ForEach-Object {
        
       $Name = $_.Name
$Script1 = @'
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

'@
$script2 = @'
service sshd restart
'@
    Write-Verbose -Message "Getting ready to create sym link for $vm." -Verbose
Invoke-VMScript -ScriptText $Script1 -Scripttype Bash -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord
Invoke-VMScript -ScriptText $Script2 -Scripttype Bash -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord
}
Export-Csv C:\Temp\whatever.csv -NoTypeInformation -UseCulture  