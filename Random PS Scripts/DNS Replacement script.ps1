$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName

# connect to vCenter
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds

#Replace Variables Below
$DomainUser = "LLTPAMI\administrator"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 


#Runs the DNS Change
$DNSChange = 'Set-DnsClientServerAddress -InterfaceAlias "E*" -ServerAddresses("172.24.19.6","172.24.19.7")'


$csv = Import-Csv C:\DNS.csv
$csv | ForEach-Object {

    $Name = $_.name

Invoke-VMScript -ScriptText $DNSChange -VM $_.name -GuestUser $DomainUser -GuestPassword $DomainPWord
}