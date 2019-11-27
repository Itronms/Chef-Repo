$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds

$DomainUser = "root"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

$GetVM = Get-VM | where {$_.Name -like "*AKRON*" -or $_.Name -like "*BORD*"}

Foreach ($vm in $GetVM)
{
Select Name,@{N='VMHost';E={$_.VMHost.Name}},

    NumCpu,MemoryGB,UsedSpaceGB |

Export-Csv C:\temp\report11.csv -NoTypeInformation -UseCulture -Append

}
