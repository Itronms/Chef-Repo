# ------vSphere Targeting Variables tracked below------
$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName

Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds


$NICSettingsReport = @()
#Get WINS and DNS from VMs via PowerCLI
$VMs = Get-Cluster "ItronMS-TP-LL-UCS-PROD" | Get-VM
    Foreach ($VM in $VMs){
        $Line               = "" | Select Name, DNS1, DNS2, WINS1, WINS2
        $Line.Name          = (Get-VMGuest $VM).HostName #VM.Name
        $Line.DNS1          = $VM.ExtensionData.Guest.net.dnsconfig.IpAddress[0]
        $Line.DNS2          = $VM.ExtensionData.Guest.net.dnsconfig.IpAddress[1]
        $Line.WINS1         = $VM.ExtensionData.Guest.net.netbiosconfig.primarywins
        $Line.WINS2         = $VM.ExtensionData.Guest.net.netbiosconfig.SecondaryWINS
        $NICSettingsReport += $line
     }
$NICSettingsReport