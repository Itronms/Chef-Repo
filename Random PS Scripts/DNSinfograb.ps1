# ------vSphere Targeting Variables tracked below------
$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName

Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds

Get-VM | Select Name,VMHost, @{N="IP Address";E={@($_.guest.IPAddress[0])}} |

Export-Csv -NoTypeInformation C:\Temp\OSIP.csv