# Script Version
$Ver = "v1.5.1"

# ------vCenter Targeting Varibles and Connection Commands Below------
# This section insures that the PowerCLI PowerShell Modules are currently active. The pipe to Out-Null can be removed if you desire additional
# Console output.
Get-Module -ListAvailable VMware* | Import-Module | Out-Null

# ------vSphere Targeting Variables tracked below------TE
$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName


# connect to vCenter
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds


 
######################################################-User-Definable Variables-In-This-Section-##########################################################################################

$script:customer = Read-Host -Prompt "Please enter customer code "

$script:customernumber = Read-Host -Prompt "Please enter customer vLAN "

$script:Cluster = Read-Host -Prompt "Is this Production or NonProduction?(P Or NP) "

if ($script:Cluster -eq 'NP') {$Type = Read-Host -Prompt "Is this Test, Dev or QA?(T, D or Q)"}

if ($Script:Cluster -eq 'P') {$Char = 'P'}

elseif ($Type -eq 'T') {$Char = 'T'}

elseif ($Type -eq 'D') {$Char = 'D'}

elseif ($Type -eq 'Q') {$Char = 'Q'}  

$FCS = Read-Host -Prompt "Do you have FCS Servers? (Yes or No) "

$IEE = Read-Host -Prompt "Do you have IEE Servers? (Yes or No) "

$PM = Read-Host -Prompt "Do you have PM Servers? (Yes or No) "

if ($script:Cluster -eq 'P') {$TargetCluster = Get-Cluster -Name "ItronMS-TP-LL-UCS-PROD";$DomainControllerVMName = "$script:customer-P-DC01";$DC02VMName = "$script:customer-P-DC02"}

if ($script:Cluster -eq 'NP') {$TargetCluster = Get-Cluster -Name "ItronMS-TP-LL-UCS-DEV";$DomainControllerVMName = "$script:customer-NP-DC01";$DC02VMName = "$script:customer-NP-DC02"}

$UIP = ($script:customernumber - 500)

if ($script:Cluster -eq 'P') {$NP = $script:customer}
elseif ($script:Cluster -eq 'NP') {$NP = $script:customer + "NP"}

$FQDN = $NP + "AMI"

$Dom = $NP + "AMI.local"

#Create and setup VDS Groups for the customer

if ($script:Cluster -eq 'P'){

$Referencegroup= Get-VDPortgroup -Name "vLAN-0504-ACR-App"

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-0$script:customernumber-$NP-App -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId $script:customernumber

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-1$script:customernumber-$NP-DB -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId 1$script:customernumber -NumPorts 8

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-2$script:customernumber-$NP-DMZ -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId 2$script:customernumber -NumPorts 8
}

elseif ($script:Cluster -eq 'NP'){$Referencegroup= Get-VDPortgroup -Name "vLAN-0504-ACR-App"

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-0$script:customernumber-$NP-App -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId $script:customernumber

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-1$script:customernumber-$NP-DB -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId 1$script:customernumber -NumPorts 8

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-2$script:customernumber-$NP-DMZ -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId 2$script:customernumber -NumPorts 8
}

# ------Virtual Machine Targeting Variables tracked below------

# The Below Variables define the names of the virtual machines upon deployment, the target cluster, and the source template and customization specification inside of vCenter to use during
# the deployment of the VMs.

$SourceVMTemplate = Get-Template -Name "Win2016Std-DTEUCS"
$SourceCustomSpec = Get-OSCustomizationSpec -Name "Win2016Std-DTE-Baseline"


Function Get-Largest()
{
$gldatastores = Get-VMHost -Location $TargetCluster|Get-Datastore| where {$_.name -notlike "*Template*"}|Select Name,FreeSpaceGB
 
#Sets some static info
$LargestFreeSpace = "0"
$LargestDatastore = $null
 
#Performs the calculation of which datastore has most free space
foreach ($gldatastore in $gldatastores) {
    if ($gldatastore.FreeSpaceGB -gt $LargestFreeSpace) { 
            $LargestFreeSpace = $gldatastore.FreeSpaceGB
            $LargestDatastore = $gldatastore.name
            }
        }
        return $LargestDatastore
    }

$Datastore = Get-Largest


#Creates Customer Folder in Vcenter

if ($script:Cluster -eq 'P') { $Folder = $script:customer}

if ($script:Cluster -eq 'NP') { $Folder = "$script:customer-NP"}

New-Folder -Name $Folder -Location Customers


$Lin1 = "root"
$Lin2 = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force 
 
# ------This section contains the commands for defining the IP and networking settings for the new virtual machines------
# NOTE: The below IPs and Interface Names need to be updated for your environment. 
 
# Domain Controller VM IPs Below
# NOTE: Insert IP info in $IP Variable
 
$DCNetworkSettings1 = @'
netsh interface ip set address "Ethernet0" static 10.50.$IP.11 255.255.255.0 10.50.$IP.1
'@
$DCNetworkSettings = $DCNetworkSettings1.Replace('$IP',$UIP)


# DC02 VM IPs Below in $IP Variable

$DC02NetworkSettings1 = @'
netsh interface ip set address "Ethernet0" static 10.50.$IP.12 255.255.255.0 10.50.$IP.1
'@
$DC02NetworkSettings = $DC02NetworkSettings1.Replace('$IP',$UIP)

# NOTE: DNS Server IP Below in $IP Variable

$DNSSettings1 = @'
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses("10.50.$IP.11","10.50.$IP.12")
'@
$DNSSettings = $DNSSettings1.Replace('$IP',$UIP)

$FND1 = "$script:customer-$Char-FND-APP"
$FND2 = "$script:customer-$Char-FND-DB"
$TPS  = "$script:customer-$Char-TPS"

$Record1 = @'
Add-DnsServerResourceRecordA -Name $FND -IPv4Address 10.50.$IP.33 -ZoneName $DomainName -CreatePtr
'@
$Record = $Record1.Replace('$DomainName',$Dom).Replace('$IP',$UIP).Replace('$FND',$FND1)

$Record2 = @'
Add-DnsServerResourceRecordA -Name $FNDDB -IPv4Address 10.150.$IP.33 -ZoneName $DomainName -CreatePtr
'@
$RecordDB = $Record2.Replace('$DomainName',$Dom).Replace('$IP',$UIP).Replace('$FNDDB',$FND2)

$Record3 = @'
Add-DnsServerResourceRecordA -Name $TP -IPv4Address 10.250.$IP.17 -ZoneName $DomainName -CreatePtr
'@
$RecordTPS = $Record3.Replace('$DomainName',$Dom).Replace('$IP',$UIP).Replace('$TP',$TPS)
 
 
# ------This Section Sets the Credentials to be used to connect to Guest VMs that are NOT part of a Domain------

# NOTE - Make sure you input the local credentials for your domain controller virtual machines below. This is used for logins prior to them being promoted to DCs.
# This should be the same local credentials as defined within the template that you are using for the domain controller VM. 
$DCLocalUser = "$DomainControllerVMName\Administrator"
$DCLocalPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DCLocalCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DCLocalUser, $DCLocalPWord

# Below Credentials are used by the DC02 VM for first login to be able to add the machine to the new Domain.
# This should be the same local credentials as defined within the template that you are using for the DC02 VM. 
$DC02LocalUser = "$DC02VMName\Administrator"
$DC02LocalPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DC02LocalCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DC02LocalUser, $DC02LocalPWord

# The below credentials are used by operations below once the domain controller virtual machines and the new domain are in place. These credentials should match the credentials
# used during the provisioning of the new domain. 
$DomainUser = "$script:customerAMI\administrator"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

$DomainUser2 = "$script:customerAMI\ihostadmin"
$DomainPWord2 = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential2 = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser2, $DomainPWord2 
 
 
 
# ------This Section Contains the Scripts to be executed against new VMs Regardless of Role

# This Scriptblock is used to add new VMs to the newly created domain by first defining the domain creds on the machine and then using Add-Computer

$JoinNewDomain1 = @'

                  $DomainUser = "$DomainName\Administrator";
                  $DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force;
                  $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord;
                  Add-Computer -DomainName $DomainName  -Credential $DomainCredential;
                  Start-Sleep -Seconds 20;
                  Shutdown /r /t 0
'@

$JoinNewDomain = $JoinNewDomain1.Replace('$DomainName',$Dom)


 
 
# ------This Section Contains the Scripts to be executed against New Domain Controller VMs------

# This Command will Install the AD Role on the target virtual machine. 
$InstallADRole = 'Install-WindowsFeature -Name "AD-Domain-Services" -Restart'
$InstallADTools = ' Add-windowsfeature rsat-adds -includeallsubfeature'

# This Scriptblock will define settings for a new AD Forest and then provision it with said settings. 
# NOTE - Make sure to define the DSRM Password below in the line below that defines the $DSRMPWord Variable!!!!
$ConfigureNewDomain1 =  @'

                       $DomainMode = "Win2012R2";
                       $ForestMode = "Win2012R2";
                       $DSRMPWord = ConvertTo-SecureString -String "p@ssw0rd" -AsPlainText -Force;
                       Install-ADDSForest -ForestMode $ForestMode -DomainMode $DomainMode -DomainName $DomainName -InstallDns -SafeModeAdministratorPassword $DSRMPWord -Force
'@
$ConfigureNewDomain = $ConfigureNewDomain1.Replace('$DomainName',$Dom)


# ------This Section Contains the Scripts to be executed against DC02 VMs------

$InstallDC02Role1 =    @'
                       $DomainMode = "Win2012R2";
                       $ForestMode = "Win2012R2";
                       $DomainUser = "$DomainName\Administrator";
                       $DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force;
                       $DomainCredential = New-Object -TypeName Syst`em.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord;
                       $DSRMPWord = ConvertTo-SecureString -String "p@ssw0rd" -AsPlainText -Force;
                       Install-ADDSDomainController -DomainName $DomainName -Credential $DomainCredential -InstallDns -SafeModeAdministratorPassword $DSRMPWord -Force
'@
$InstallDC02Role = $InstallDC02Role1.Replace('$DomainName',$Dom)


$InstallDNSZones1 = @'
                    Set-DnsServerForwarder -IPAddress ("10.51.100.101","10.51.100.102","fdfa:ffff:0:200:10:51:100:101","fdfa:ffff:0:200:10:51:100:102") 
                    Add-DnsServerPrimaryZone -NetworkID "10.50.$IP.0/24" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "10.150.$IP.0/24" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "10.250.$IP.0/24" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "fdfa:ffff:0:5$IP::/64" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "fdfa:ffff:0:15$IP::/64" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "fdfa:ffff:0:25$IP::/64" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure
'@

$InstallDNSZones = $InstallDNSZones1.Replace('$IP',$UIP)


$InstallDNSZones2 = 'Set-DnsServerForwarder -IPAddress ("10.51.100.101","10.51.100.102","fdfa:ffff:0:200:10:51:100:101","fdfa:ffff:0:200:10:51:100:102")'


# ----------------This Section Contains the Scripts to Setup Groups and Users-----------

$OU1 =  @'
        New-ADOrganizationalUnit -Name Customers -Path "DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name Itron -Path "DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name Applications -Path "OU=Customers,DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name CGRs -Path "OU=Customers,DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name Meters -Path "OU=Customers,DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name Service_Accounts -Path "OU=Customers,DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name Systems -Path "OU=Customers,DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name Users -Path "OU=Customers,DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name Users -Path "OU=Itron,DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name Service_Accounts -Path "OU=Itron,DC=$Domain,DC=local";
        New-ADOrganizationalUnit -Name Groups -Path "OU=Itron,DC=$Domain,DC=local";
'@
$OU = $OU1.Replace('$Domain',$FQDN)


$Group1A = @'
           $IEE = "$Code"  + "_APP_P_IEE_Admin";
           $IEE2 = "$Code"  + "_APP_P_IEE_User";
           $IEE3 = "$Code"  + "_APP_P_IEECSR_User";
           $ISM = "$Code"  + "_APP_P_ISM_Admin";
           $ISM2 = "$Code"  + "_APP_P_ISM_User";
           $FND = "$Code" + "_FND_Admin";
           $FND1 = "$Code" + "_FND_Endpoint_Operator";
           $FND2 = "$Code" + "_FND_Monitor_Only";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND -SamAccountName $FND -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE -SamAccountName $IEE -DisplayName $IEE -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE2 -SamAccountName $IEE2 -DisplayName $IEE2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE3 -SamAccountName $IEE3 -DisplayName $IEE3 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM -SamAccountName $ISM -DisplayName $ISM -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM2 -SamAccountName $ISM2 -DisplayName $ISM2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND1 -SamAccountName $FND1 -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND2 -SamAccountName $FND2 -DisplayName $FND2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
'@
$Group1 = $Group1A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Group1TestA = @'
               $IEE = "$Code"  + "_APP_T_IEE_Admin";
               $IEE2 = "$Code" + "_APP_T_IEE_User";
               $IEE3 = "$Code"  + "_APP_T_IEECSR_User";
               $ISM = "$Code"  + "_APP_T_ISM_Admin";
               $ISM2 = "$Code"  + "_APP_T_ISM_User";
               $FND = "$Code" + "_FND_Admin";
               $FND1 = "$Code" + "_FND_Endpoint_Operator";
               $FND2 = "$Code" + "_FND_Monitor_Only";
               $ErrorActionPreference = "SilentlyContinue"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND -SamAccountName $FND -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               $ErrorActionPreference = "Continue"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE -SamAccountName $IEE -DisplayName $IEE -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE2 -SamAccountName $IEE2 -DisplayName $IEE2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE3 -SamAccountName $IEE3 -DisplayName $IEE3 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM -SamAccountName $ISM -DisplayName $ISM -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM2 -SamAccountName $ISM2 -DisplayName $ISM2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND1 -SamAccountName $FND1 -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND2 -SamAccountName $FND2 -DisplayName $FND2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
'@
$Group1Test = $Group1TestA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Group1DevA = @'
               $IEE = "$Code"  + "_APP_D_IEE_Admin";
               $IEE2 = "$Code"  + "_APP_D_IEE_User";
               $IEE3 = "$Code" + "_APP_D_IEECSR_User";
               $ISM = "$Code"  + "_APP_D_ISM_Admin";
               $ISM2 = "$Code"  + "_APP_D_ISM_User";
               $FND = "$Code" + "_FND_Admin";
               $FND1 = "$Code" + "_FND_Endpoint_Operator";
               $FND2 = "$Code" + "_FND_Monitor_Only";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND -SamAccountName $FND -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE -SamAccountName $IEE -DisplayName $IEE -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE2 -SamAccountName $IEE2 -DisplayName $IEE2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE3 -SamAccountName $IEE3 -DisplayName $IEE3 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM -SamAccountName $ISM -DisplayName $ISM -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM2 -SamAccountName $ISM2 -DisplayName $ISM2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND1 -SamAccountName $FND1 -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND2 -SamAccountName $FND2 -DisplayName $FND2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
'@
$Group1Dev = $Group1DevA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Group1QAA = @'
               $IEE = "$Code"  + "_APP_QA_IEE_Admin";
               $IEE2 = "$Code"  + "_APP_QA_IEE_User";
               $IEE3 = "$Code"  + "_APP_QA_IEECSR_User";
               $ISM = "$Code"  + "_APP_QA_ISM_Admin";
               $ISM2 = "$Code"  + "_APP_QA_ISM_User";
               $FND = "$Code" + "_FND_Admin";
               $FND1 = "$Code" + "_FND_Endpoint_Operator";
               $FND2 = "$Code" + "_FND_Monitor_Only";
               $ErrorActionPreference = "SilentlyContinue"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND -SamAccountName $FND -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               $ErrorActionPreference = "Continue"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE -SamAccountName $IEE -DisplayName $IEE -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE2 -SamAccountName $IEE2 -DisplayName $IEE2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE3 -SamAccountName $IEE3 -DisplayName $IEE3 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM -SamAccountName $ISM -DisplayName $ISM -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM2 -SamAccountName $ISM2 -DisplayName $ISM2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND1 -SamAccountName $FND1 -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND2 -SamAccountName $FND2 -DisplayName $FND2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
'@

$Group1QA = $Group1QAA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Group2A = @'
           $FND = "$Code" + "_FND_NBAPI"
           $FND2 = "$Code" + "_FND_Root"
           $FND3 = "$Code" + "_FND_Router_Operator"
           $CGR = "CGR_GROUP"
           $Meter =  "$Code" + "_Meters"
           $SVC = "$Code" + "_ServiceAccount"
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND -SamAccountName $FND -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND3 -SamAccountName $FND3 -DisplayName $FND3 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND2 -SamAccountName $FND2 -DisplayName $FND2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 1 -GroupCategory Security -Name $CGR -SamAccountName $CGR -DisplayName $CGR -Path "OU=CGRs,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 1 -GroupCategory Security -Name $Meter -SamAccountName $Meter -DisplayName $Meter -Path "OU=Meters,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $SVC -SamAccountName $SVC -DisplayName $SVC -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local";
'@

$Group2 = $Group2A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Group3A = @'
           $Admin = "$Code" + "_Admin"
           $OW = "$Code" + "_APP_P_OWCEUI_Admin"
           $OW2 = "$Code" + "_APP_P_OWCEUI_User"
           $DBA = "$Code" + "_DBA"
           $DBU =  "$Code" + "_DBU"
           $TS = "$Code" + "_TS_User"
           $User = "$Code" + "_Users"
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $Admin -SamAccountName $Admin -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW -SamAccountName $OW -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW2 -SamAccountName $OW2 -DisplayName $OW2 -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBA -SamAccountName $DBA -DisplayName $DBA -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBU -SamAccountName $DBU -DisplayName $DBU -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $TS -SamAccountName $TS -DisplayName $TS -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $User -SamAccountName $User -DisplayName $User -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
'@

$Group3 = $Group3A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Group3TestA = @'
               $Admin = "$Code" + "_Admin"
               $OW = "$Code" + "_APP_T_OWCEUI_Admin"
               $OW2 = "$Code" + "_APP_T_OWCEUI_User"
               $DBA = "$Code" + "_DBA"
               $DBU =  "$Code" + "_DBU"
               $TS = "$Code" + "_TS_User"
               $User = "$Code" + "_Users"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $Admin -SamAccountName $Admin -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW -SamAccountName $OW -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW2 -SamAccountName $OW2 -DisplayName $OW2 -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBA -SamAccountName $DBA -DisplayName $DBA -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBU -SamAccountName $DBU -DisplayName $DBU -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $TS -SamAccountName $TS -DisplayName $TS -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $User -SamAccountName $User -DisplayName $User -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
'@

$Group3Test = $Group3TestA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Group3DevA = @'
               $Admin = "$Code" + "_Admin"
               $OW = "$Code" + "_APP_D_OWCEUI_Admin"
               $OW2 = "$Code" + "_APP_D_OWCEUI_User"
               $DBA = "$Code" + "_DBA"
               $DBU =  "$Code" + "_DBU"
               $TS = "$Code" + "_TS_User"
               $User = "$Code" + "_Users"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $Admin -SamAccountName $Admin -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW -SamAccountName $OW -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW2 -SamAccountName $OW2 -DisplayName $OW2 -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBA -SamAccountName $DBA -DisplayName $DBA -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBU -SamAccountName $DBU -DisplayName $DBU -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $TS -SamAccountName $TS -DisplayName $TS -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $User -SamAccountName $User -DisplayName $User -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
'@
$Group3Dev = $Group3DevA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Group3QAA = @'
               $Admin = "$Code" + "_Admin"
               $OW = "$Code" + "_APP_QA_OWCEUI_Admin"
               $OW2 = "$Code" + "_APP_QA_OWCEUI_User"
               $DBA = "$Code" + "_DBA"
               $DBU =  "$Code" + "_DBU"
               $TS ="$Code" + "_TS_User"
               $User = "$Code" + "_Users"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $Admin -SamAccountName $Admin -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW -SamAccountName $OW -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW2 -SamAccountName $OW2 -DisplayName $OW2 -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBA -SamAccountName $DBA -DisplayName $DBA -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBU -SamAccountName $DBU -DisplayName $DBU -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $TS -SamAccountName $TS -DisplayName $TS -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $User -SamAccountName $User -DisplayName $User -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
'@
$Group3QA = $Group3QAA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)


$Group4A = @'
           $Admin = "Itron Admins"
           $DBA = "Itron DBA"
           $Net = "Network_Admin"
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $Admin -SamAccountName $Admin -DisplayName $Admin -Path "OU=Groups,OU=Itron,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBA -SamAccountName $DBA -DisplayName $Admin -Path "OU=Groups,OU=Itron,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $NET -SamAccountName $NET -DisplayName $NET -Path "OU=Groups,OU=Itron,DC=$Domain,DC=local";
'@

$Group4 = $Group4A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)


$UsersA = @'
          $CA = "$Code" + "PCASVC";
          $IEE2 = "$Code" + "PIEEDA";
          $IEE = "$Code" + "PIEEDB";  
          $FCS = "$Code" + "PFVCSVC";
          $IEE3 = "$Code" + "PIEESVC";
          $ISM = "$Code" + "PISMAdmin";
          $ISM2 = "$Code" + "PISMDB";
          New-ADUser -Name $CA -GivenName $CA -SamAccountName $CA -Surname "Service" -DisplayName $CA -UserPrincipalName "$CA@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $IEE2 -GivenName $IEE2 -SamAccountName $IEE2 -Surname "Service" -DisplayName $IEE2 -UserPrincipalName "$IEE2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $FCS -GivenName $FCS -SamAccountName $FCS -Surname "Service" -DisplayName $FCS -UserPrincipalName "$FCS@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $IEE3 -GivenName $IEE3 -SamAccountName $IEE3 -Surname "Service" -DisplayName $IEE3 -UserPrincipalName "$IEE3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $ISM -GivenName $ISM -SamAccountName $ISM -Surname "Service" -DisplayName $ISM -UserPrincipalName "$ISM@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $ISM2 -GivenName $ISM2 -SamAccountName $ISM2 -Surname "Service" -DisplayName $ISM2 -UserPrincipalName "$ISM2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1
'@

$Users = $UsersA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$UsersTestA =  @'
               $CA = "$Code" + "TCASVC";
               $IEE2 = "$Code" + "TIEEDA";
               $IEE = "$Code" + "TIEEDB";  
               $FCS = "$Code" + "TFVCSVC";
               $IEE3 = "$Code" + "TIEESVC";
               $ISM = "$Code" + "TISMAdmin";
               $ISM2 = "$Code" + "TISMDB";
               New-ADUser -Name $CA -GivenName $CA -SamAccountName $CA -Surname "Service" -DisplayName $CA -UserPrincipalName "$CA@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE2 -GivenName $IEE2 -SamAccountName $IEE2 -Surname "Service" -DisplayName $IEE2 -UserPrincipalName "$IEE2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $FCS -GivenName $FCS -SamAccountName $FCS -Surname "Service" -DisplayName $FCS -UserPrincipalName "$FCS@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE3 -GivenName $IEE3 -SamAccountName $IEE3 -Surname "Service" -DisplayName $IEE3 -UserPrincipalName "$IEE3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $ISM -GivenName $ISM -SamAccountName $ISM -Surname "Service" -DisplayName $ISM -UserPrincipalName "$ISM@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $ISM2 -GivenName $ISM2 -SamAccountName $ISM2 -Surname "Service" -DisplayName $ISM2 -UserPrincipalName "$ISM2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1
'@

$UsersTest = $UsersTestA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$UsersDevA =  @'
               $CA = "$Code" + "DCASVC";
               $IEE2 = "$Code" + "DIEEDA";
               $IEE = "$Code" + "DIEEDB";  
               $FCS = "$Code" + "DFVCSVC";
               $IEE3 = "$Code" + "DIEESVC";
               $ISM = "$Code" + "DISMAdmin";
               $ISM2 = "$Code" + "DISMDB";
               New-ADUser -Name $CA -GivenName $CA -SamAccountName $CA -Surname "Service" -DisplayName $CA -UserPrincipalName "$CA@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE2 -GivenName $IEE2 -SamAccountName $IEE2 -Surname "Service" -DisplayName $IEE2 -UserPrincipalName "$IEE2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $FCS -GivenName $FCS -SamAccountName $FCS -Surname "Service" -DisplayName $FCS -UserPrincipalName "$FCS@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE3 -GivenName $IEE3 -SamAccountName $IEE3 -Surname "Service" -DisplayName $IEE3 -UserPrincipalName "$IEE3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $ISM -GivenName $ISM -SamAccountName $ISM -Surname "Service" -DisplayName $ISM -UserPrincipalName "$ISM@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $ISM2 -GivenName $ISM2 -SamAccountName $ISM2 -Surname "Service" -DisplayName $ISM2 -UserPrincipalName "$ISM2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1
'@

$UsersDev = $UsersDevA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$UsersQAA =  @'
               $CA = "$Code" + "QACASVC";
               $IEE2 = "$Code" + "QAIEEDA";
               $IEE = "$Code" + "QAIEEDB";  
               $FCS = "$Code" + "QAFVCSVC";
               $IEE3 = "$Code" + "QAIEESVC";
               $ISM = "$Code" + "QAISMAdmin";
               $ISM2 = "$Code" + "QAISMDB";
               New-ADUser -Name $CA -GivenName $CA -SamAccountName $CA -Surname "Service" -DisplayName $CA -UserPrincipalName "$CA@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE2 -GivenName $IEE2 -SamAccountName $IEE2 -Surname "Service" -DisplayName $IEE2 -UserPrincipalName "$IEE2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $FCS -GivenName $FCS -SamAccountName $FCS -Surname "Service" -DisplayName $FCS -UserPrincipalName "$FCS@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE3 -GivenName $IEE3 -SamAccountName $IEE3 -Surname "Service" -DisplayName $IEE3 -UserPrincipalName "$IEE3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $ISM -GivenName $ISM -SamAccountName $ISM -Surname "Service" -DisplayName $ISM -UserPrincipalName "$ISM@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $ISM2 -GivenName $ISM2 -SamAccountName $ISM2 -Surname "Service" -DisplayName $ISM2 -UserPrincipalName "$ISM2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1
'@

$UsersQA = $UsersQAA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Users2A = @'
           $ISM3 = "$Code" + "PISMEXTCon";
           $ISM4 = "$Code" + "PISMSVC";
           $OW = "$Code" + "POWAPP";
           $IEE = "$Code" + "PIEEDB"; 
           $OW2 = "$Code" + "POWDB";
           New-ADUser -Name $ISM3 -GivenName $ISM3 -SamAccountName $ISM3 -Surname "Service" -DisplayName $ISM3 -UserPrincipalName "$ISM3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1; 
           New-ADUser -Name $ISM4 -GivenName $ISM4 -SamAccountName $ISM4 -Surname "Service" -DisplayName $ISM4 -UserPrincipalName "$ISM4@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;                
           New-ADUser -Name $OW -GivenName $OW -SamAccountName $OW -Surname "Service" -DisplayName $OW -UserPrincipalName "$OW@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;        
           New-ADUser -Name $OW2 -GivenName $OW2 -SamAccountName $OW2 -Surname "Service" -DisplayName $OW2 -UserPrincipalName "$OW2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
           New-ADUser -Name $IEE -GivenName $IEE -SamAccountName $IEE -Surname "Service" -DisplayName $IEE -UserPrincipalName "$IEE@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1
'@

$Users2 = $Users2A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Users2TestA = @'
               $ISM3 = "$Code" + "TISMEXTCon";
               $ISM4 = "$Code" + "TISMSVC";
               $OW = "$Code" + "TOWAPP";
               $IEE = "$Code" + "TIEEDB"; 
               $OW2 = "$Code" + "TOWDB";
               New-ADUser -Name $ISM3 -GivenName $ISM3 -SamAccountName $ISM3 -Surname "Service" -DisplayName $ISM3 -UserPrincipalName "$ISM3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1; 
               New-ADUser -Name $ISM4 -GivenName $ISM4 -SamAccountName $ISM4 -Surname "Service" -DisplayName $ISM4 -UserPrincipalName "$ISM4@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;                
               New-ADUser -Name $OW -GivenName $OW -SamAccountName $OW -Surname "Service" -DisplayName $OW -UserPrincipalName "$OW@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;        
               New-ADUser -Name $OW2 -GivenName $OW2 -SamAccountName $OW2 -Surname "Service" -DisplayName $OW2 -UserPrincipalName "$OW2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE -GivenName $IEE -SamAccountName $IEE -Surname "Service" -DisplayName $IEE -UserPrincipalName "$IEE@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1
'@
$Users2Test = $Users2TestA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)


$Users2DevA = @'
               $ISM3 = "$Code" + "DISMEXTCon";
               $ISM4 = "$Code" + "DISMSVC";
               $OW = "$Code" + "DOWAPP";
               $IEE = "$Code" + "DIEEDB"; 
               $OW2 = "$Code" + "DOWDB";
               New-ADUser -Name $ISM3 -GivenName $ISM3 -SamAccountName $ISM3 -Surname "Service" -DisplayName $ISM3 -UserPrincipalName "$ISM3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1; 
               New-ADUser -Name $ISM4 -GivenName $ISM4 -SamAccountName $ISM4 -Surname "Service" -DisplayName $ISM4 -UserPrincipalName "$ISM4@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;                
               New-ADUser -Name $OW -GivenName $OW -SamAccountName $OW -Surname "Service" -DisplayName $OW -UserPrincipalName "$OW@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;        
               New-ADUser -Name $OW2 -GivenName $OW2 -SamAccountName $OW2 -Surname "Service" -DisplayName $OW2 -UserPrincipalName "$OW2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE -GivenName $IEE -SamAccountName $IEE -Surname "Service" -DisplayName $IEE -UserPrincipalName "$IEE@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1
'@

$Users2Dev = $Users2DevA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Users2QAA = @'
               $ISM3 = "$Code" + "QAISMEXTCon";
               $ISM4 = "$Code" + "QAISMSVC";
               $OW = "$Code" + "QAOWAPP";
               $IEE = "$Code" + "QAIEEDB"; 
               $OW2 = "$Code" + "QAOWDB";
               New-ADUser -Name $ISM3 -GivenName $ISM3 -SamAccountName $ISM3 -Surname "Service" -DisplayName $ISM3 -UserPrincipalName "$ISM3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1; 
               New-ADUser -Name $ISM4 -GivenName $ISM4 -SamAccountName $ISM4 -Surname "Service" -DisplayName $ISM4 -UserPrincipalName "$ISM4@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;                
               New-ADUser -Name $OW -GivenName $OW -SamAccountName $OW -Surname "Service" -DisplayName $OW -UserPrincipalName "$OW@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;        
               New-ADUser -Name $OW2 -GivenName $OW2 -SamAccountName $OW2 -Surname "Service" -DisplayName $OW2 -UserPrincipalName "$OW2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE -GivenName $IEE -SamAccountName $IEE -Surname "Service" -DisplayName $IEE -UserPrincipalName "$IEE@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1
'@

$Users2QA = $Users2QAA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Users3A =  @'
            New-ADUser -Name "Prabhu Armugam" -GivenName "Prabhu" -Surname "Armugam" -DisplayName "Prabhu Armugam" -SamAccountName "PArmugam" -UserPrincipalName "PArmugam@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Nishighandha" -GivenName "Nishighandha" -Surname "Kulkarni" -DisplayName "Nishighandha Kulkarni"-SamAccountName "NKulkarni" -UserPrincipalName "NKulkarni@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Dinesh Govindu" -GivenName "Dinesh" -Surname "Govindu" -DisplayName "Dinesh Govindu" -SamAccountName "DGovindu" -UserPrincipalName "DGovindu@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Aravind Manoharan" -GivenName "Aravind" -Surname "Manoharan" -DisplayName "Aravind Manoharan" -SamAccountName "AManoharan" -UserPrincipalName "AManoharan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Ajmal Firdose" -GivenName "Ajmal" -Surname "Firdose" -DisplayName "Ajmal Firdose" -SamAccountName "AFirdose" -UserPrincipalName "AFirdose@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "James Scott" -GivenName "James" -Surname "Scott" -DisplayName "James Scott" -SamAccountName "JScott" -UserPrincipalName "JScott@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
'@

$Users3 = $Users3A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Users4A = @'
            New-ADUser -Name "Pavithra Ramani" -GivenName "Pavithra" -Surname "Ramani" -DisplayName "Pavithra Ramani" -SamAccountName "PRamani" -UserPrincipalName "PRamani@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Muthuraman" -GivenName "Muthuraman" -Surname "Pattavarayan" -DisplayName "Muthuraman Pattavarayan" -SamAccountName "MPattavarayan" -UserPrincipalName "MPattavarayan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "MadhanKumar" -GivenName "MadhanKumar" -Surname "Murugesan" -DisplayName "MadhanKumar Murugesan" -SamAccountName "MMurugesan" -UserPrincipalName "MMurugesan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Kevin Nail" -GivenName "Kevin" -Surname "Nail" -DisplayName "Kevin Nail" -UserPrincipalName "KNail@$Domain.local" -SamAccountName "KNail" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Matt Elliott" -GivenName "Matt" -Surname "Elliott" -DisplayName "Matt Elliott" -UserPrincipalName "MElliott@$Domain.local" -SamAccountName "Melliott" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Lance Pelton" -GivenName "Lance" -Surname "Pelton" -DisplayName "Lance Pelton" -UserPrincipalName "LPelton@$Domain.local" -SamAccountName "LPelton" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
'@

$Users4 = $Users4A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Users5A =   @'
            New-ADUser -Name "Sateesh Poojari" -GivenName "Sateesh" -Surname "Poojari" -DisplayName "Sateesh Poojari" -SamAccountName "Spoojari"  -UserPrincipalName "SPoojari@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Shahab Khan" -GivenName "Shahab" -Surname "Khan" -DisplayName "Shahab Khan" -SamAccountName "SKhan"  -UserPrincipalName "SKhan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Subbaraman" -GivenName "Subbaraman" -Surname "Apparsami" -DisplayName "Subbaraman Apparsami" -SamAccountName "SApparsami"  -UserPrincipalName "SApparsami@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Syed Rizvi" -GivenName "Syed" -Surname "Rizvi" -DisplayName "Syed Rizvi" -SamAccountName "SRizvi"  -UserPrincipalName "SRizvi@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Bence Bihari" -GivenName "Bence" -Surname "Bihari" -DisplayName "Bence Bihari" -SamAccountName "BBihari"  -UserPrincipalName "BBihari@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Senthil Natarajan" -GivenName "Senthil" -Surname "Natarajan" -DisplayName "Senthil Natarajan" -SamAccountName "SNatarajan"  -UserPrincipalName "SNatarajan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Rahul Singh" -GivenName "Rahul" -Surname "RSingh" -DisplayName "Rahul Singh" -SamAccountName "RSingh"  -UserPrincipalName "RSingh@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
'@           

$Users5 = $Users5A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Users6A =   @'
            New-ADUser -Name "nmsconfig" -GivenName "nmsconfig" -Surname "nmsconfig" -DisplayName "nmsconfig" -SamAccountName "nmsconfig"  -UserPrincipalName "nmsconfig@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "RDS_Interface" -GivenName "RDS_Interface" -Surname "RDS_Interface" -DisplayName "RDS_Interface" -SamAccountName "RDS_Interface"  -UserPrincipalName "RDS_Interface@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "swsamsvc" -GivenName "swsamsvc" -Surname "swsamsvc" -DisplayName "swsamsvc" -SamAccountName "swsamsvc"  -UserPrincipalName "swsamsvc@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Akbarsab Patel" -GivenName "Patel" -Surname "APatel" -DisplayName "Akbarsab Patel" -SamAccountName "APatel"  -UserPrincipalName "APatel@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Shaun Tinsley" -GivenName "Shaun" -Surname "STinsley" -DisplayName "Shaun Tinsley" -SamAccountName "STinsley"  -UserPrincipalName "STinsley@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;

'@

$Users6 = $Users6A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$Users7A =   @'
             New-ADUser -Name "Balazs Petovari" -GivenName "Balazs" -Surname "BPetovari" -DisplayName "Balazs Petovari" -SamAccountName "BPetovari"  -UserPrincipalName "BPetovari@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Krisztian Fekete" -GivenName "Krisztian" -Surname "KFekete" -DisplayName "Krisztian Fekete" -SamAccountName "KFekete"  -UserPrincipalName "KFekete@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
'@

$Users7 = $Users7A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$GroupAdd1 = 'Add-ADGroupMember -Identity "Domain Admins" -Members @("PArmugam","NKulkarni","DGovindu","AManoharan","AFirdose","JScott","PRamani","MPattavarayan","MMurugesan","KNail","MElliott","LPelton","SPoojari","SKhan","SApparsami","SRizvi","BBihari","SNatarajan","RSighn","APatel","STinsley","BPetovari","Kfekete")'

$GroupAdd2A = @'
              $IEE2 = "$Code" + "PIEEDA";
              $IEE = "$Code" + "PIEEDB";  
              $FCS = "$Code" + "PFVCSVC";
              $IEE3 = "$Code" + "PIEESVC";
              $ISM = "$Code" + "PISMAdmin";
              $ISM2 = "$Code" + "PISMDB";
              $ISM3 = "$Code" + "PISMEXTCon";
              $ISM4 = "$Code" + "PISMSVC";
              $OW = "$Code" + "POWAPP";
              $OW2 = "$Code" + "POWDB";
              $Group1 = "$Code" + "_ServiceAccount";
              $Group2 = "$Code"  + "_APP_P_IEE_Admin";
              $Group3 = "$Code" + "_APP_P_IEE_User";
              $Group4 = "$Code" + "_APP_P_ISM_Admin";
              $Group5 = "$Code" + "_APP_P_ISM_User";
              $Group6 = "$Code" + "_APP_P_OWCEUI_Admin";
              $Group7 = "$Code" + "_APP_P_OWCEUI_User";
              Add-ADGroupMember -Identity $Group1 -Members @("$CA","$FCS","$IEE3","$IEE","$ISM2","$ISM3","$ISM4");
              Add-ADGroupMember -Identity $Group2 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group3 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group4 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group5 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group6 -Members @("$OW");
              Add-ADGroupMember -Identity $Group7 -Members @("$OW");
'@

$GroupAdd2 = $GroupAdd2A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)


$GroupAddTest2A = @'    
              $CA = "$Code" + "TCASVC";
              $IEE2 = "$Code" + "TIEEDA";
              $IEE = "$Code" + "TIEEDB";  
              $FCS = "$Code" + "TFVCSVC";
              $IEE3 = "$Code" + "TIEESVC";
              $ISM = "$Code" + "TISMAdmin";
              $ISM2 = "$Code" + "TISMDB";
              $ISM3 = "$Code" + "TISMEXTCon";
              $ISM4 = "$Code" + "TISMSVC";
              $OW = "$Code" + "TOWAPP";
              $OW2 = "$Code" + "TOWDB";
              $Group1 = "$Code" + "_ServiceAccount";
              $Group2 = "$Code"  + "_APP_T_IEE_Admin";
              $Group3 = "$Code" + "_APP_T_IEE_User";
              $Group4 = "$Code" + "_APP_T_ISM_Admin";
              $Group5 = "$Code" + "_APP_T_ISM_User";
              $Group6 = "$Code" + "_APP_T_OWCEUI_Admin";
              $Group7 = "$Code" + "_APP_T_OWCEUI_User";
              Add-ADGroupMember -Identity $Group1 -Members @("$CA","$FCS","$IEE3","$IEE","$ISM2","$ISM3","$ISM4");
              Add-ADGroupMember -Identity $Group2 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group3 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group4 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group5 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group6 -Members @("$OW");
              Add-ADGroupMember -Identity $Group7 -Members @("$OW");
'@

$GroupAddTest2 = $GroupAddTest2A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$GroupAddDev2A = @'  
              $CA = "$Code" + "DCASVC";
              $IEE2 = "$Code" + "DIEEDA";
              $IEE = "$Code" + "DIEEDB";  
              $FCS = "$Code" + "DFVCSVC";
              $IEE3 = "$Code" + "DIEESVC";
              $ISM = "$Code" + "DISMAdmin";
              $ISM2 = "$Code" + "DISMDB";
              $ISM3 = "$Code" + "DISMEXTCon";
              $ISM4 = "$Code" + "DISMSVC";
              $OW = "$Code" + "DOWAPP";
              $OW2 = "$Code" + "DOWDB";
              $Group1 = "$Code" + "_ServiceAccount";
              $Group2 = "$Code"  + "_APP_D_IEE_Admin";
              $Group3 = "$Code" + "_APP_D_IEE_User";
              $Group4 = "$Code" + "_APP_D_ISM_Admin";
              $Group5 = "$Code" + "_APP_D_ISM_User";
              $Group6 = "$Code" + "_APP_D_OWCEUI_Admin";
              $Group7 = "$Code" + "_APP_D_OWCEUI_User";
              Add-ADGroupMember -Identity $Group1 -Members @("$CA","$FCS","$IEE3","$IEE","$ISM2","$ISM3","$ISM4");
              Add-ADGroupMember -Identity $Group2 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group3 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group4 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group5 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group6 -Members @("$OW");
              Add-ADGroupMember -Identity $Group7 -Members @("$OW");
'@

$GroupAddDev2 = $GroupAddDev2A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$GroupAddQA2A = @'     
              $CA = "$Code" + "QACASVC";
              $IEE2 = "$Code" + "QAIEEDA";
              $IEE = "$Code" + "QAIEEDB";  
              $FCS = "$Code" + "QAFVCSVC";
              $IEE3 = "$Code" + "QAIEESVC";
              $ISM = "$Code" + "QAISMAdmin";
              $ISM2 = "$Code" + "QAISMDB";
              $ISM3 = "$Code" + "QAISMEXTCon";
              $ISM4 = "$Code" + "QAISMSVC";
              $OW = "$Code" + "QAOWAPP";
              $OW2 = "$Code" + "QAOWDB";
              $Group1 = "$Code" + "_ServiceAccount";
              $Group2 = "$Code"  + "_APP_QA_IEE_Admin";
              $Group3 = "$Code" + "_APP_QA_IEE_User";
              $Group4 = "$Code" + "_APP_QA_ISM_Admin";
              $Group5 = "$Code" + "_APP_QA_ISM_User";
              $Group6 = "$Code" + "_APP_QA_OWCEUI_Admin";
              $Group7 = "$Code" + "_APP_QA_OWCEUI_User";
              Add-ADGroupMember -Identity $Group1 -Members @("$CA","$FCS","$IEE3","$IEE","$ISM2","$ISM3","$ISM4");
              Add-ADGroupMember -Identity $Group2 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group3 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group4 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group5 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group6 -Members @("$OW");
              Add-ADGroupMember -Identity $Group7 -Members @("$OW");
'@

$GroupAddQA2 = $GroupAddQA2A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

#-----------------These 3 are password Resets-----------------------------------

$PWResetA = @'
CD C:\
[String]$path= ".\SVCPasswords.txt"

if ($path -ne $null){Remove-Item $path}


<# Required Assembly to Generate Passwords #>
Add-Type -Assembly System.Web

OU="OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local"

#Get the users inside the OU specified in the Options Above
$users=Get-ADUser -filter * -SearchBase $OU


foreach($Name in $users.samaccountname){
#Variable that will receive the random password
$NewPassword=[Web.Security.Membership]::GeneratePassword(10,4)

#The code below will change the password and will set the Option to change the password on the next logon.
Set-ADAccountPassword -Identity $Name -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
Get-ADUser -Identity $Name |Set-ADUser -ChangePasswordAtLogon:$true

#Here will write the info to the file, so you can communicate to your users the new password.
Write-Output "UserID:$name `t Password:$NewPassword" `n`n|FT -AutoSize >>SVCPasswords.txt

} 
'@

$PWReset = $PWResetA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$PWReset2A = @'
CD C:\
#This is the file that will be generated with the users account ID and the password generated.
[String]$path= ".\ItronSVCPasswords.txt"

if ($path -ne $null){Remove-Item $path}


<# Required Assembly to Generate Passwords #>
Add-Type -Assembly System.Web

$OU="OU=Service_Accounts,OU=Itron,DC=$Domain,DC=local"

#Get the users inside the OU specified in the Options Above
$users=Get-ADUser -filter * -SearchBase $OU


foreach($Name in $users.samaccountname){
#Variable that will receive the random password
$NewPassword=[Web.Security.Membership]::GeneratePassword(10,4)

#The code below will change the password and will set the Option to change the password on the next logon.
Set-ADAccountPassword -Identity $Name -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
Get-ADUser -Identity $Name |Set-ADUser -ChangePasswordAtLogon:$true

#Here will write the info to the file, so you can communicate to your users the new password.
Write-Output "UserID:$name `t Password:$NewPassword" `n`n|FT -AutoSize >>ItronSVCPasswords.txt

} 
'@

$PWReset2 = $PWReset2A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$PWReset3A = @'
CD C:\
#This is the file that will be generated with the users account ID and the password generated.
[String]$path= ".\ItronEmployees.txt"


if ($path -ne $null){Remove-Item $path}


<# Required Assembly to Generate Passwords #>
Add-Type -Assembly System.Web

$OU="OU=Users,OU=Itron,DC=$Domain,DC=local"

#Get the users inside the OU specified in the Options Above
$users=Get-ADUser -filter * -SearchBase $OU


foreach($Name in $users.samaccountname){
#Variable that will receive the random password
$NewPassword=[Web.Security.Membership]::GeneratePassword(10,4)

#The code below will change the password and will set the Option to change the password on the next logon.
Set-ADAccountPassword -Identity $Name -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
Get-ADUser -Identity $Name |Set-ADUser -ChangePasswordAtLogon:$true

#Here will write the info to the file, so you can communicate to your users the new password.
Write-Output "UserID:$name `t Password:$NewPassword" `n`n|FT -AutoSize >>ItronEmployees.txt

} 
'@

$PWReset3 = $PWReset3A.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

#-------------These Setup the GPO's----------------------------

$GPOA = @'
        New-GPO -name "2012 SMB1 Disable"
        New-GPO -name "Admin Hidden Files"
        New-GPO -name "Background"
        New-GPO -name "Backup Drive"
        New-GPO -name "CUST-"$Code""
        New-GPO -name "Itronms-TPLL"
        New-GPO -name "RDP End Disconnected Sessions"
        New-GPO -name "Security Policy - Domain"
        New-GPO -name "UAC Disable"
        New-GPO -name "Windows Update"
        Import-gpo -BackupId 76A59C56-454C-4A04-AB86-9AEC3FF9DB64 -Path C:\GPOBackup\ -TargetName "2012 SMB1 Disable"
        Import-gpo -BackupId 2CDF560A-D9B2-40E8-81D4-975AA5ED5FC3 -Path C:\GPOBackup\ -TargetName "Admin Hidden Files"
        Import-gpo -BackupId F6AA2AF2-9A70-46CF-94E1-8F3F31603DD9 -Path C:\GPOBackup\ -TargetName "Background"
        Import-gpo -BackupId FAB29508-2599-42D6-AFB8-9B8F3B3BEB7B -Path C:\GPOBackup\ -TargetName "Backup Drive"
        Import-gpo -BackupId C7AEBFDB-30A3-4CC0-B516-2D03CD82B866 -Path C:\GPOBackup\ -TargetName "CUST-$Code"
        Import-gpo -BackupId 247F1631-D48C-495A-8A24-EEEC35E89FF9 -Path C:\GPOBackup\ -TargetName "Itronms-TPLL" -MigrationTable C:\GPOBackup\MigTable.migtable
        Import-gpo -BackupId C45D8DB2-AE8F-4CAF-8EE7-A02C4BE95FED -Path C:\GPOBackup\ -TargetName "RDP End Disconnected Sessions"
        Import-gpo -BackupId EF583E60-DFA0-45C5-88DD-B8418464642E -Path C:\GPOBackup\ -TargetName "Security Policy - Domain"
        Import-gpo -BackupId B81A062B-4744-4BED-AEC1-931B5E38AC88 -Path C:\GPOBackup\ -TargetName "UAC Disable"
        Import-gpo -BackupId 805123A0-7499-4049-ADBE-88842C1A5CFC -Path C:\GPOBackup\ -TargetName "Windows Update
        
'@

$GPO = $GPOA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

$GPOLinkA  = @'
             New-GPLink -Name "2012 SMB1 Disable" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "Admin Hidden Files" -Target "DC=$Domain,DC=Local";
             New-GPLink -Name "Background" -Target "DC=$Domain,DC=Local";
             New-GPLink -Name "Backup Drive" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "CUST-"$Code"" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "Itronms-TPLL" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "RDP End Disconnected Sessions" -Target "DC=$Domain,DC=Local";
             New-GPLink -Name "Security Policy - Domain" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "UAC Disable" -Target "DC=$Domain,DC=Local";
             New-GPO -Name "RDS 2016" -Comment "This is for the RDS Servers License" | new-gplink -Target "DC=$Domain,DC=Local";
             New-GPO -Name "Server Level Access" | new-gplink -Target "DC=$Domain,DC=Local";  
'@

$GPOLink = $GPOLinkA.Replace('$Code',$script:customer).Replace('$Domain',$FQDN)

 $IPV6 = @'
-errorAction Silently Continue
Get-AdComputer -Filter {Enabled -eq $True -and OperatingSystem -like "*Windows*" -and Name -notlike "*-DC*"} | Foreach {
    Invoke-Command -ComputerName $_.Name -ScriptBlock { 
    Get-NetAdapter -Name "Ethernet*" | Foreach {
    $local:ifname = $_.Name
    $local:ifindex = $_.ifIndex
    $_ | Get-NetIPAddress | Foreach {
        if ($_.AddressFamily -eq "IPv4") { $script:ipv4address = $_.IPAddress }
        if (($_.AddressFamily -eq "IPv6") -And ($_.IPAddress -match "^fdfa:ffff:0:\d+:10:")) {$script:ipv6address = $_.IPAddress}
}
        if ($script:ipv4address) {
            if ($script:ipv4address.split('.')[1] -eq 50 -or 150 -or 250) {
                $local:nvlan = (([Int]$script:ipv4address.split('.')[1])*10) + [Int]$script:ipv4address.split('.')[2]
                $local:dnvlan = 500+[Int]$script:ipv4address.split('.')[2]
                $local:v6pre = "fdfa:ffff:0:"+$local:nvlan+":"
                $local:newv6 = $local:v6pre + [String]::Join(':',$script:ipv4address.split('.'))
                $local:newgw = $local:newv6.Substring(0, $local:newv6.lastIndexOf(':'))+":1"
                $local:dns1 = "fdfa:ffff:0:"+$local:dnvlan+":10:50:"+[Int]$script:ipv4address.split('.')[2]+":11"
                $local:dns2 = "fdfa:ffff:0:"+$local:dnvlan+":10:50:"+[Int]$script:ipv4address.split('.')[2]+":12"
                "$local:ifname $script:ipv4address Did not find a v6 address configured, may I suggest $local:newv6 for interface: $local:ifindex gateway $local:newgw"
                Enable-NetAdapterBinding -Name $local:ifname -ComponentID ms_tcpip6 
                New-NetIPAddress -InterfaceIndex $local:ifindex -IPAddress $local:newv6 -PrefixLength 64 -AddressFamily IPv6 
                Remove-NetRoute -DestinationPrefix ::/0 -ErrorAction SilentlyContinue 
                New-NetRoute -DestinationPrefix ::/0 -InterfaceIndex $local:ifindex -NextHop $local:newgw 
                "DNS Addresses will be: $local:dns1 and $local:dns2"
                Set-DnsClientServerAddress -InterfaceIndex $local:ifindex -ServerAddresses $local:dns1, $local:dns2 
                netsh int ipv6 set int $local:ifname routerdiscovery=disable 
                netsh int ipv6 set int $local:ifname managedaddress=disable 
               
            } 
        }
    }
}

    }
'@

$Expire = 'Set-ADUser -Identity IHostAdmin -PasswordNeverExpires $True'

$Mount1 = @'
          echo "10.150.$IP.20:/FND /backup nfs auto 0 0" >> /etc/fstab
'@

$Mount = $Mount1.Replace('$IP',$UIP)

$FNDV62 = @'
          echo "IPV6ADDR=fdfa:ffff:0:$vlan:10:50:$IP:33/64" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@

$FNDV6 = $FNDV62.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)

$FNDGateway1 = @'
            echo "IPV6_DEFAULTGW=fdfa:ffff:0:$vlan:10:50:$IP:1" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$FNDGateway = $FNDGateway1.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)

$FNDDNS1 = @'
            echo "DNS3=fdfa:ffff:0:$vlan:10:50:$IP:11" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$FNDDNS = $FNDDNS1.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)

$FNDDNS12 = @'
            echo "DNS4=fdfa:ffff:0:$vlan:10:50:$IP:12" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$FNDDNS2 = $FNDDNS12.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)


$FNDDBV62 = @'
          echo "IPV6ADDR=fdfa:ffff:0:1$vlan:10:150:$IP:33/64" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@

$FNDDBV6 = $FNDDBV62.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)


$FNDDBGateway1 = @'
            echo "IPV6_DEFAULTGW=fdfa:ffff:0:1$vlan:10:150:$IP:1" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$FNDDBGateway = $FNDDBGateway1.Replace('$IP',$UIP).Replace('c$vlan',$script:customernumber)


$TPSV62 = @'
          echo "IPV6ADDR=fdfa:ffff:0:2$vlan:10:250:$IP:17/64" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@

$TPSV6 = $TPSV62.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)


$TPSGateway1 = @'
            echo "IPV6_DEFAULTGW=fdfa:ffff:0:2$vlan:10:250:$IP:1" >> /etc/sysconfig/network-scripts/ifcfg-ens192
'@
$TPSGateway = $TPSGateway1.Replace('$IP',$UIP).Replace('$vlan',$script:customernumber)

$NPSInstall = 'Install-WindowsFeature -ConfigurationFilePath C:\Temp\NPSRoleConfig.xml -Restart'

#########################################################################################################################################################################################

 
 
# Script Execution Occurs from this point down

# ------This Section Deploys the new VM(s) using a pre-built template and then applies a customization specification to it. It then waits for Provisioning To Finish------

Write-Verbose -Message "Deploying Virtual Machine with Name: [$DomainControllerVMName] using Template: [$SourceVMTemplate] and Customization Specification: [$SourceCustomSpec] on Cluster: [$TargetCluster] and waiting for completion" -Verbose

New-VM -Name $DomainControllerVMName -Template $SourceVMTemplate -ResourcePool $TargetCluster -Datastore $Datastore -OSCustomizationSpec $SourceCustomSpec 

Write-Verbose -Message "Virtual Machine $DomainControllerVMName Deployed. Powering On" -Verbose

Get-NetworkAdapter $DomainControllerVMName|Remove-NetworkAdapter -confirm:$false

Start-VM -VM $DomainControllerVMName

Write-Verbose -Message "Deploying Virtual Machine with Name: [$DC02VMName] using Template: [$SourceVMTemplate] and Customization Specification: [$SourceCustomSpec] on Cluster: [$TargetCluster] and waiting for completion" -Verbose

New-VM -Name $DC02VMName -Template $SourceVMTemplate -ResourcePool $TargetCluster -Datastore $Datastore -OSCustomizationSpec $SourceCustomSpec

Write-Verbose -Message "Virtual Machine $DC02VMName Deployed. Powering On" -Verbose

Get-NetworkAdapter $DC02VMName|Remove-NetworkAdapter -confirm:$false

Start-VM -VM $DC02VMName

Move-VM -VM $DomainControllerVMName -Destination $Folder

Move-VM -VM $DC02VMName -Destination $Folder
 
# ------This Section Targets and Executes the Scripts on the New Domain Controller Guest VM------

# We first verify that the guest customization has finished on on the new DC VM by using the below loops to look for the relevant events within vCenter. 
 
Write-Verbose -Message "Verifying that Customization for VM $DomainControllerVMName has started ..." -Verbose
       while($True)
       {
             $DCvmEvents = Get-VIEvent -Entity $DomainControllerVMName 
             $DCstartedEvent = $DCvmEvents | Where { $_.GetType().Name -eq "CustomizationStartedEvent" }

             if ($DCstartedEvent)
             {
                    break  
             }

             else   
             {
                    Start-Sleep -Seconds 5
             }
       }

Write-Verbose -Message "Customization of VM $DomainControllerVMName has started. Checking for Completed Status......." -Verbose
       while($True)
       {
             $DCvmEvents = Get-VIEvent -Entity $DomainControllerVMName 
             $DCSucceededEvent = $DCvmEvents | Where { $_.GetType().Name -eq "CustomizationSucceeded" }
        $DCFailureEvent = $DCvmEvents | Where { $_.GetType().Name -eq "CustomizationFailed" }

             if ($DCFailureEvent)
             {
                    Write-Warning -Message "Customization of VM $DomainControllerVMName failed" -Verbose
            return $False  
             }

             if ($DCSucceededEvent)     
             {
            break
             }
        Start-Sleep -Seconds 5
       }
Write-Verbose -Message "Customization of VM $DomainControllerVMName Completed Successfully!" -Verbose

# NOTE - The below Sleep command is to help prevent situations where the post customization reboot is delayed slightly causing
Start-Sleep -Seconds 30

Write-Verbose -Message "Waiting for VM $DomainControllerVMName to complete post-customization reboot." -Verbose

Wait-Tools -VM $DomainControllerVMName -TimeoutSeconds 300

# NOTE - Another short sleep here to make sure that other services have time to come up after VMware Tools are ready. 
Start-Sleep -Seconds 30

Get-VM $DomainControllerVMName|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $DomainControllerVMName|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $DomainControllerVMName|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $DomainControllerVMName|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2016Std-DTEUCS

Get-VM $DC02VMName|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $DC02VMName|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $DC02VMName|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $DC02VMName|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2016Std-DTEUCS

# After Customization Verification is done we change the IP of the VM to the value defined near the top of the script

if ($script:Cluster -eq 'P') {New-NetworkAdapter -VM $DomainControllerVMName -NetworkName vLAN-0$script:customernumber-$script:customer-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false}

elseif ($script:Cluster -eq 'NP') {New-NetworkAdapter -VM $DomainControllerVMName -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false}

if ($script:Cluster -eq 'P') {New-NetworkAdapter -VM $DC02VMName -NetworkName vLAN-0$script:customernumber-$script:customer-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false}

elseif ($script:Cluster -eq 'NP') {New-NetworkAdapter -VM $DC02VMName -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false}

Write-Verbose -Message "Getting ready to change IP Settings on VM $DomainControllerVMName." -Verbose

Invoke-VMScript -ScriptText $DCNetworkSettings -VM $DomainControllerVMName -GuestCredential $DCLocalCredential

# NOTE - The Below Sleep Command is due to it taking a few seconds for VMware Tools to read the IP Change so that we can return the below output. 
# This is strctly informational and can be commented out if needed, but it's helpful when you want to verify that the settings defined above have been 
# applied successfully within the VM. We use the Get-VM command to return the reported IP information from Tools at the Hypervisor Layer. 
Start-Sleep 30
$DCEffectiveAddress = (Get-VM $DomainControllerVMName).guest.ipaddress[0]
Write-Verbose -Message "Assigned IP for VM [$DomainControllerVMName] is [$DCEffectiveAddress]" -Verbose

# Then we Actually install the AD Role and configure the new domain

Write-Verbose -Message "Getting Ready to Install Active Directory Services on $DomainControllerVMName" -Verbose

Invoke-VMScript -ScriptText $InstallADTools -VM $DomainControllerVMName -GuestCredential $DCLocalCredential

Invoke-VMScript -ScriptText $InstallADRole -VM $DomainControllerVMName -GuestCredential $DCLocalCredential

Write-Verbose -Message "Configuring New AD Forest on $DomainControllerVMName" -Verbose

Invoke-VMScript -ScriptText $ConfigureNewDomain -VM $DomainControllerVMName -GuestCredential $DCLocalCredential

# Script Block for configuration of AD automatically reboots the machine after provisioning

Write-Verbose -Message "Rebooting $DomainControllerVMName to Complete Forest Provisioning" -Verbose

# Below sleep command is in place as the reboot needed from the above command doesn't always happen before the wait-tools command is run

Start-Sleep -Seconds 460

Wait-Tools -VM $DomainControllerVMName -TimeoutSeconds 300

Write-Verbose -Message "Installation of Domain Services and Forest Provisioning on $DomainControllerVMName Complete" -Verbose

# ------This Section Targets and Executes the Scripts on DC02 VM.

# Just like the DC VM, we have to first modify the IP Settings of the VM

Write-Verbose -Message "Getting ready to change IP Settings on VM $DC02VMName." -Verbose

Invoke-VMScript -ScriptText $DC02NetworkSettings -VM $DC02VMName -GuestCredential $DC02LocalCredential

Invoke-VMScript -ScriptText $DNSSettings -VM $DC02VMName -GuestCredential $DC02LocalCredential

Start-Sleep 30

$DC02EffectiveAddress = (Get-VM $DC02VMName).guest.ipaddress[0]

Write-Verbose -Message "Assigned IP for VM [$DC02VMName] is [$DC02EffectiveAddress]" -Verbose 

Start-Sleep 30

Invoke-VMScript -ScriptText $DNSSettings -VM $DomainControllerVMName -GuestCredential $DomainCredential

Write-Verbose -Message "Assigned DNS for VM [$DomainControllerVMName]" -Verbose

# The Below Cmdlets actually add the VM to the newly deployed domain. 

Start-Sleep 30

Invoke-VMScript -ScriptText $JoinNewDomain -VM $DC02VMName -ScriptType Powershell -GuestUser $DC02LocalUser -GuestPassword $DC02LocalPWord

# Below sleep command is in place as the reboot needed from the above command doesn't always happen before the wait-tools command is run

Start-Sleep -Seconds 60

Wait-Tools -VM $DC02VMName -TimeoutSeconds 300

Write-Verbose -Message "VM $DC02VMName Added to Domain and Successfully Rebooted." -Verbose

Write-Verbose -Message "Installing DC02 Role on $DC02VMName." -Verbose

# The below commands actually execute the script blocks defined above to install the DC02 role 

Invoke-VMScript -ScriptText $InstallADTools -VM $DC02VMName -GuestCredential $DomainCredential

Invoke-VMScript -ScriptText $InstallADRole -VM $DC02VMName -GuestCredential $DomainCredential

Write-Verbose -Message "AD and DS Roles have been installed on $DC02VMName." -Verbose

Write-Verbose -Message "Promoting $DC02VMName to a Domain Controller...wow!." -Verbose

try{Invoke-VMScript -ScriptText $InstallDC02Role -VM $DC02VMName -GuestCredential $DomainCredential -ErrorAction:Stop} catch [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.SystemError]{}

Write-Verbose -Message "$DC02VMName has been turned into a Domain Controller!" -Verbose

# The below commands will execute the script block to setup the lookup zones on DC01

Write-Verbose -Message "Configuring DNS Reverse Lookup Zones." -Verbose

Invoke-VMScript -ScriptText $InstallDNSZones -VM $DomainControllerVMName -GuestCredential $DomainCredential

Write-Verbose -Message "Lookup Zones have been configured." -Verbose


# The below set's up an outbound trust with ItronMS

Write-Verbose -Message "Creating a one way trust with Itronms domain on [$DomainControllerVMName]" -Verbose

$DomainTrust = '$strRemoteForest = "Itronms.local"
                $strRemoteAdmin = "TPLLScript"
                $strRemoteAdminPassword = "cl0ckw!SE"

$remoteContext = New-Object -TypeName "System.DirectoryServices.ActiveDirectory.DirectoryContext" -ArgumentList @( "Forest", $strRemoteForest, $strRemoteAdmin, $strRemoteAdminPassword) 
try {
        $remoteForest = [System.DirectoryServices.ActiveDirectory.Forest]::getForest($remoteContext) 
        #Write-Host "GetRemoteForest: Succeeded for domain $($remoteForest)"
    }
catch {
        Write-Warning "GetRemoteForest: Failed:`n`tError: $($($_.Exception).Message)"
    }
Write-Host "Connected to Remote forest: $($remoteForest.Name)"
$localforest=[System.DirectoryServices.ActiveDirectory.Forest]::getCurrentForest() 
Write-Host "Connected to Local forest: $($localforest.Name)"
try {
        $localForest.CreateTrustRelationship($remoteForest,"Outbound")
        Write-Host "CreateTrustRelationship: Succeeded for domain $($remoteForest)"
    }
catch {
        Write-Warning "CreateTrustRelationship: Failed for domain $($remoteForest)`n`tError: $($($_.Exception).Message)"
    }'

Invoke-VMScript -ScriptText $DomainTrust -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Write-Verbose -Message "One way trust has been successfully created on [$DomainControllerVMName]" -Verbose

Write-Verbose -Message "Setting up DNS Forwards on [$DC02VMName]" -Verbose

#This is to allow DC02 to reboot after promoting

Write-Verbose -Message "Setting up OU's on [$DomainControllerVMName]" -Verbos

Invoke-VMScript -ScriptText $OU -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Write-Verbose -Message "Setting up Groups on [$DomainControllerVMName]" -Verbos

if ($Char -eq 'P'){Invoke-VMScript -ScriptText $Group1 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Elseif ($Char -eq 'T'){Invoke-VMScript -ScriptText $Group1Test -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Elseif ($Char -eq 'D'){Invoke-VMScript -ScriptText $Group1Dev -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Elseif ($Char -eq 'Q'){Invoke-VMScript -ScriptText $Group1QA -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Invoke-VMScript -ScriptText $Group2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

if ($Char -eq 'P'){Invoke-VMScript -ScriptText $Group3 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Elseif ($Char -eq 'T'){Invoke-VMScript -ScriptText $Group3Test -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Elseif ($Char -eq 'D'){Invoke-VMScript -ScriptText $Group3Dev -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Elseif ($Char -eq 'Q'){Invoke-VMScript -ScriptText $Group3QA -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Invoke-VMScript -ScriptText $Group4 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Write-Verbose -Message "Setting up Users on [$DomainControllerVMName]" -Verbos

if ($Char -eq 'P'){Invoke-VMScript -ScriptText $Users -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($Char -eq 'T'){Invoke-VMScript -ScriptText $UsersTest -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($Char -eq 'D'){Invoke-VMScript -ScriptText $UsersDev -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($Char -eq 'Q'){Invoke-VMScript -ScriptText $UsersQA -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

if ($Char -eq 'P'){Invoke-VMScript -ScriptText $Users2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($Char -eq 'T'){Invoke-VMScript -ScriptText $Users2Test -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($Char -eq 'D'){Invoke-VMScript -ScriptText $Users2Dev -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($Char -eq 'Q'){Invoke-VMScript -ScriptText $Users2QA -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Invoke-VMScript -ScriptText $Users3 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Invoke-VMScript -ScriptText $Users4 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Invoke-VMScript -ScriptText $Users5 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Invoke-VMScript -ScriptText $Users6 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Invoke-VMScript -ScriptText $Users7 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Write-Verbose -Message "Adding Users to Groups on [$DomainControllerVMName]" -Verbos

Invoke-VMScript -ScriptText $GroupAdd1 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

if ($Char -eq 'P'){Invoke-VMScript -ScriptText $GroupAdd2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($Char -eq 'T'){Invoke-VMScript -ScriptText $GroupAddTest2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($Char -eq 'D'){Invoke-VMScript -ScriptText $GroupAddDev2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($Char -eq 'Q'){Invoke-VMScript -ScriptText $GroupAddQA2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Write-Verbose -Message "Resetting Service Account Passwords on [$DomainControllerVMName] The file location is C:\SVCPasswords" -Verbos

Invoke-VMScript -ScriptText $PWReset -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Write-Verbose -Message "Resetting Itron Service Account Passwords on [$DomainControllerVMName] The file location is C:\ItronSVCPasswords" -Verbos

Invoke-VMScript -ScriptText $PWReset2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Write-Verbose -Message "Resetting Itron Service Account Passwords on [$DomainControllerVMName] The file location is C:\ItronEmployees.txt" -Verbos

Invoke-VMScript -ScriptText $PWReset3 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Start-Sleep 60

Write-Verbose -Message "Setting up GPO's on [$DomainControllerVMName] " -Verbose

Invoke-VMScript -ScriptText $GPO -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Start-Sleep 30

Invoke-VMScript -ScriptText $InstallDNSZones2 -VM $DC02VMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Invoke-VMScript -ScriptText $GPOLink -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Write-Verbose -Message "Restarting [$DomainControllerVMName] and [$DC02VMName] to finish setup  " -Verbose

Restart-VM -VM $DomainControllerVMName -Confirm:$false 

Restart-VM -VM $DC02VMName -Confirm:$false

start-sleep 60

Write-Verbose -Message "Environment Setup for DC's Complete" -Verbose

Write-Verbose -Message "Deploying VM's for New Domain" -Verbose

Write-Verbose -Message "Deploying ECC-CA Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-ECC-CA -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-ECC-CA|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-ECC-CA -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-ECC-CA 
Get-OSCustomizationSpec -Name $script:customer-$Char-ECC-CA|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-ECC-CA |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.18 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-ECC-CA |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-ECC-CA|Set-VM -MemoryGB 8 -NumCpu 2 -OSCustomizationSpec $script:customer-$Char-ECC-CA -Confirm:$false
Get-VM $script:customer-$Char-ECC-CA|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-ECC-CA|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-ECC-CA|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-ECC-CA|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-ECC-CA).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-ECC-CA' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-ECC-CA
wait-tools -VM $script:customer-$Char-ECC-CA
remove-oscustomizationspec $script:customer-$Char-ECC-CA -confirm:$false

Write-Verbose -Message "Deploying RSA-CA Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-RSA-CA -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-RSA-CA|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-RSA-CA -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-RSA-CA
Get-OSCustomizationSpec -Name $script:customer-$Char-RSA-CA|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-RSA-CA |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.19 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-RSA-CA |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-RSA-CA|Set-VM -MemoryGB 8 -NumCpu 2 -OSCustomizationSpec $script:customer-$Char-RSA-CA -Confirm:$false
Get-VM $script:customer-$Char-RSA-CA|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-RSA-CA|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-RSA-CA|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-RSA-CA|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-RSA-CA).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-RSA-CA' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-RSA-CA
wait-tools -VM $script:customer-$Char-RSA-CA
remove-oscustomizationspec $script:customer-$Char-RSA-CA -confirm:$false

Write-Verbose -Message "Deploying NPS Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-NPS -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-NPS|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-NPS -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-NPS
Get-OSCustomizationSpec -Name $script:customer-$Char-NPS|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-NPS |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.16 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-NPS |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-NPS|Set-VM -MemoryGB 8 -NumCpu 2 -OSCustomizationSpec $script:customer-$Char-NPS -Confirm:$false
Get-VM $script:customer-$Char-NPS|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-NPS|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-NPS|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-NPS|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-NPS).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-NPS' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-NPS
wait-tools -VM $script:customer-$Char-NPS
remove-oscustomizationspec $script:customer-$Char-NPS -confirm:$false

Write-Verbose -Message "Deploying WIFI-CA Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-WIFI-CA -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-WIFI-CA|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-WIFI-CA -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-WIFI-CA
Get-OSCustomizationSpec -Name $script:customer-$Char-WIFI-CA|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-WIFI-CA |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.20 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-WIFI-CA |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-WIFI-CA|Set-VM -MemoryGB 8 -NumCpu 2 -OSCustomizationSpec $script:customer-$Char-WIFI-CA -Confirm:$false
Get-VM $script:customer-$Char-WIFI-CA|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-WIFI-CA|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-WIFI-CA|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-WIFI-CA|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-WIFI-CA).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-WIFI-CA' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-WIFI-CA
wait-tools -VM $script:customer-$Char-WIFI-CA
remove-oscustomizationspec $script:customer-$Char-WIFI-CA -confirm:$false

Write-Verbose -Message "Deploying RDS01 Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-RDS01 -Template Win2016Std-DTEUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-RDS01|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-RDS01 -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2016Std-DTE-Baseline|New-OSCustomizationSpec -Name $script:customer-$Char-RDS01
Get-OSCustomizationSpec -Name $script:customer-$Char-RDS01|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-RDS01 |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.26 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-RDS01 |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-RDS01|Set-VM -MemoryGB 16 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-RDS01 -Confirm:$false
Get-VM $script:customer-$Char-RDS01|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-RDS01|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-RDS01|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-RDS01|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2016Std-DTEUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-RDS01).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-RDS01' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-RDS01
wait-tools -VM $script:customer-$Char-RDS01
remove-oscustomizationspec $script:customer-$Char-RDS01 -confirm:$false


Write-Verbose -Message "Deploying OW-CM Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-OW-CM -Template OWOC-41-APP-UCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-OW-CM|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-OW-CM -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-OW-CM
Get-OSCustomizationSpec -Name $script:customer-$Char-OW-CM|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-OW-CM |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.31 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-OW-CM |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-OW-CM|Set-VM -MemoryGB 16 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-OW-CM -Confirm:$false
Get-VM $script:customer-$Char-OW-CM|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-OW-CM|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-OW-CM|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-OW-CM|Set-Annotation -CustomAttribute "Deployment Template" -Value OWOC-41-APP-UCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-OW-CM).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-OW-CM' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-OW-CM
wait-tools -VM $script:customer-$Char-OW-CM
remove-oscustomizationspec $script:customer-$Char-OW-CM -confirm:$false

Write-Verbose -Message "Deploying SQL-DB2 Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-SQL-DB2 -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-SQL-DB2|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-SQL-DB2 -NetworkName vLAN-1$script:customernumber-$NP-DB -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-SQL-DB2
Get-OSCustomizationSpec -Name $script:customer-$Char-SQL-DB2|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-SQL-DB2 |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.150.$UIP.32 -SubnetMask 255.255.255.0 -DefaultGateway 10.150.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-SQL-DB2 |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-SQL-DB2|Set-VM -MemoryGB 32 -NumCpu 16 -OSCustomizationSpec $script:customer-$Char-SQL-DB2 -Confirm:$false
Get-VM $script:customer-$Char-SQL-DB2|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-SQL-DB2|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-SQL-DB2|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-SQL-DB2|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-SQL-DB2).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-SQL-DB2' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-SQL-DB2
wait-tools -VM $script:customer-$Char-SQL-DB2
remove-oscustomizationspec $script:customer-$Char-SQL-DB2 -confirm:$false

Write-Verbose -Message "Deploying ISM-APP Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-ISM-APP -Template ISM-34-APP-UCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-ISM-APP|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-ISM-APP -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-ISM-APP
Get-OSCustomizationSpec -Name $script:customer-$Char-ISM-APP|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-ISM-APP |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.32 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-ISM-APP |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-ISM-APP|Set-VM -MemoryGB 8 -NumCpu 2 -OSCustomizationSpec $script:customer-$Char-ISM-APP -Confirm:$false
Get-VM $script:customer-$Char-ISM-APP|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-ISM-APP|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-ISM-APP|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-ISM-APP|Set-Annotation -CustomAttribute "Deployment Template" -Value ISM-34-APP-UCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-ISM-APP).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-ISM-APP' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-ISM-APP
wait-tools -VM $script:customer-$Char-ISM-APP
remove-oscustomizationspec $script:customer-$Char-ISM-APP -confirm:$false

Write-Verbose -Message "Deploying SQL-DB1 Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-SQL-DB1 -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-SQL-DB1|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-SQL-DB1 -NetworkName vLAN-1$script:customernumber-$NP-DB -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-SQL-DB1
Get-OSCustomizationSpec -Name $script:customer-$Char-SQL-DB1|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-SQL-DB1 |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.150.$UIP.31 -SubnetMask 255.255.255.0 -DefaultGateway 10.150.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-SQL-DB1 |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-SQL-DB1|Set-VM -MemoryGB 32 -NumCpu 16 -OSCustomizationSpec $script:customer-$Char-SQL-DB1 -Confirm:$false
Get-VM $script:customer-$Char-SQL-DB1|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-SQL-DB1|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-SQL-DB1|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-SQL-DB1|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-SQL-DB1).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-SQL-DB1' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-SQL-DB1
wait-tools -VM $script:customer-$Char-SQL-DB1
remove-oscustomizationspec $script:customer-$Char-SQL-DB1 -confirm:$false

Write-Verbose -Message "Deploying BACKUP Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-BACKUP -Template Backup-Template -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-BACKUP|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-BACKUP -NetworkName vLAN-1$script:customernumber-$NP-DB -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2016Std-DTE-Baseline|New-OSCustomizationSpec -Name $script:customer-$Char-BACKUP
Get-OSCustomizationSpec -Name $script:customer-$Char-BACKUP|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-BACKUP |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.150.$UIP.20 -SubnetMask 255.255.255.0 -DefaultGateway 10.150.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-BACKUP |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-BACKUP|Set-VM -MemoryGB 8 -NumCpu 2 -OSCustomizationSpec $script:customer-$Char-BACKUP -Confirm:$false
Get-VM $script:customer-$Char-BACKUP|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-BACKUP|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-BACKUP|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-BACKUP|Set-Annotation -CustomAttribute "Deployment Template" -Value Backup-Template

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-BACKUP).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-BACKUP' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-BACKUP
wait-tools -VM $script:customer-$Char-BACKUP
remove-oscustomizationspec $script:customer-$Char-BACKUP -confirm:$false

Write-Verbose -Message "Deploying FND-APP Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-FND-APP -Template RHEL7.3-Full-UCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-FND-APP|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-FND-APP -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name RHEL7.3-Full|New-OSCustomizationSpec -Name $script:customer-$Char-FND-APP
Get-OSCustomizationSpec -Name $script:customer-$Char-FND-APP|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-FND-APP |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.33 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-FND-APP |Set-OSCUstomizationSpec -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-FND-APP|Set-VM -MemoryGB 8 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-FND-APP -Confirm:$false
Get-VM $script:customer-$Char-FND-APP|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-FND-APP|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-FND-APP|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-FND-APP|Set-Annotation -CustomAttribute "Deployment Template" -Value RHEL7.3-Full-UCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-FND-APP).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-FND-APP' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-FND-APP
wait-tools -VM $script:customer-$Char-FND-APP
remove-oscustomizationspec $script:customer-$Char-FND-APP -confirm:$false


Write-Verbose -Message "Deploying FND-DB Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-FND-DB -Template RHEL-7.3-Full-GUI-Oracle12c-UCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-FND-DB|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-FND-DB -NetworkName vLAN-1$script:customernumber-$NP-DB -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name RHEL7.3-Full|New-OSCustomizationSpec -Name $script:customer-$Char-FND-DB
Get-OSCustomizationSpec -Name $script:customer-$Char-FND-DB|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-FND-DB |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.150.$UIP.33 -SubnetMask 255.255.255.0 -DefaultGateway 10.150.$UIP.1  -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-FND-DB |Set-OSCUstomizationSpec -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-FND-DB|Set-VM -MemoryGB 8 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-FND-DB -Confirm:$false
Get-VM $script:customer-$Char-FND-DB|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-FND-DB|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-FND-DB|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-FND-DB|Set-Annotation -CustomAttribute "Deployment Template" -Value RHEL-7.3-Full-GUI-Oracle12c-UCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-FND-DB).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-FND-DB' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-FND-DB
wait-tools -VM $script:customer-$Char-FND-DB
remove-oscustomizationspec $script:customer-$Char-FND-DB -confirm:$false

Write-Verbose -Message "Deploying TPS Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-TPS -Template RHEL7.3-Full-UCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-TPS|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-TPS -NetworkName vLAN-2$script:customernumber-$NP-DMZ -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name RHEL7.3-Full|New-OSCustomizationSpec -Name $script:customer-$Char-TPS
Get-OSCustomizationSpec -Name $script:customer-$Char-TPS|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-TPS |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.250.$UIP.17 -SubnetMask 255.255.255.0 -DefaultGateway 10.250.$UIP.1 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-TPS |Set-OSCUstomizationSpec -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-TPS|Set-VM -MemoryGB 8 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-TPS -Confirm:$false
Get-VM $script:customer-$Char-TPS|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-TPS|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-TPS|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-TPS|Set-Annotation -CustomAttribute "Deployment Template" -Value RHEL7.3-Full-UCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-TPS).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-TPS' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-TPS
wait-tools -VM $script:customer-$Char-TPS
remove-oscustomizationspec $script:customer-$Char-TPS -confirm:$false

if ($FCS -eq 'Yes') {

Write-Verbose -Message "Deploying FCS-APP Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-FCS-APP -Template FCS-APP-UCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-FCS-APP|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-FCS-APP -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2016Std-DTE-Baseline|New-OSCustomizationSpec -Name $script:customer-$Char-FCS-APP
Get-OSCustomizationSpec -Name $script:customer-$Char-FCS-APP|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-FCS-APP |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.36 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-FCS-APP |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-FCS-APP|Set-VM -MemoryGB 8 -NumCpu 2 -OSCustomizationSpec $script:customer-$Char-FCS-APP -Confirm:$false
Get-VM $script:customer-$Char-FCS-APP|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-FCS-APP|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-FCS-APP|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-FCS-APP|Set-Annotation -CustomAttribute "Deployment Template" -Value FCS-APP-UCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-FCS-APP).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-FCS-APP' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-FCS-APP
wait-tools -VM $script:customer-$Char-FCS-APP
remove-oscustomizationspec $script:customer-$Char-FCS-APP -confirm:$false
}

if ($IEE -eq 'Yes') {
Write-Verbose -Message "Deploying IEE-APP Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-IEE-APP -Template IEE-82-APP-UCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-IEE-APP|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-IEE-APP -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-IEE-APP
Get-OSCustomizationSpec -Name $script:customer-$Char-IEE-APP|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-IEE-APP |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.34 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-IEE-APP |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-IEE-APP|Set-VM -MemoryGB 8 -NumCpu 2 -OSCustomizationSpec $script:customer-$Char-IEE-APP -Confirm:$false
Get-VM $script:customer-$Char-IEE-APP|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-IEE-APP|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-IEE-APP|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-IEE-APP|Set-Annotation -CustomAttribute "Deployment Template" -Value IEE-82-APP-UCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-IEE-APP).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-IEE-APP' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-IEE-APP
wait-tools -VM $script:customer-$Char-IEE-APP
remove-oscustomizationspec $script:customer-$Char-IEE-APP -confirm:$false

Write-Verbose -Message "Deploying IEE-DB Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-IEE-DB -Template IEE-82-DB-UCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-IEE-DB|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-IEE-DB -NetworkName vLAN-1$script:customernumber-$NP-DB -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-IEE-DB
Get-OSCustomizationSpec -Name $script:customer-$Char-IEE-DB|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-IEE-DB |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.150.$UIP.34 -SubnetMask 255.255.255.0 -DefaultGateway 10.150.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-IEE-DB |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-IEE-DB|Set-VM -MemoryGB 8 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-IEE-DB -Confirm:$false
Get-VM $script:customer-$Char-IEE-DB|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-IEE-DB|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-IEE-DB|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-IEE-DB|Set-Annotation -CustomAttribute "Deployment Template" -Value IEE-82-DB-UCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-IEE-DB).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-IEE-DB' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-IEE-DB
wait-tools -VM $script:customer-$Char-IEE-DB
remove-oscustomizationspec $script:customer-$Char-IEE-DB -confirm:$false
}

if($PM -eq 'Yes'){
Write-Verbose -Message "Deploying PM-AGT Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-PM-AGT -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-PM-AGT|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-PM-AGT -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-PM-AGT 
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-AGT|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-AGT |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.45 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-AGT |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-PM-AGT|Set-VM -MemoryGB 8 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-PM-AGT -Confirm:$false
Get-VM $script:customer-$Char-PM-AGT|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-PM-AGT|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-PM-AGT|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-PM-AGT|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-PM-AGT).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-PM-AGT' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-PM-AGT
wait-tools -VM $script:customer-$Char-PM-AGT
remove-oscustomizationspec $script:customer-$Char-PM-AGT -confirm:$false

Write-Verbose -Message "Deploying PM-HUB Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-PM-HUB -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-PM-HUB|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-PM-HUB -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-PM-HUB 
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-HUB|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-HUB |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.46 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-HUB |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-PM-HUB|Set-VM -MemoryGB 8 -NumCpu 8 -OSCustomizationSpec $script:customer-$Char-PM-HUB -Confirm:$false
Get-VM $script:customer-$Char-PM-HUB|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-PM-HUB|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-PM-HUB|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-PM-HUB|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-PM-HUB).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-PM-HUB' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-PM-HUB
wait-tools -VM $script:customer-$Char-PM-HUB
remove-oscustomizationspec $script:customer-$Char-PM-HUB -confirm:$false

Write-Verbose -Message "Deploying PM-ID Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-PM-ID -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-PM-ID|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-PM-ID -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-PM-ID 
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-ID|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-ID |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.47 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-ID |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-PM-ID|Set-VM -MemoryGB 8 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-PM-ID -Confirm:$false
Get-VM $script:customer-$Char-PM-ID|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-PM-ID|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-PM-ID|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-PM-ID|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-PM-ID).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-PM-ID' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-PM-ID
wait-tools -VM $script:customer-$Char-PM-ID
remove-oscustomizationspec $script:customer-$Char-PM-ID -confirm:$false

Write-Verbose -Message "Deploying PM-MQ Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-PM-MQ -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-PM-MQ|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-PM-MQ -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-PM-MQ 
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-MQ|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-MQ |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.48 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-MQ |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-PM-MQ|Set-VM -MemoryGB 8 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-PM-MQ -Confirm:$false
Get-VM $script:customer-$Char-PM-MQ|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-PM-MQ|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-PM-MQ|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-PM-MQ|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-PM-MQ).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-PM-MQ' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-PM-MQ
wait-tools -VM $script:customer-$Char-PM-MQ
remove-oscustomizationspec $script:customer-$Char-PM-MQ -confirm:$false

Write-Verbose -Message "Deploying PM-APP Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-PM-APP -Template Win2012R2Std-GUIUCS -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-PM-APP|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-PM-APP -NetworkName vLAN-0$script:customernumber-$NP-App -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-PM-APP 
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-APP|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-APP |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.50.$UIP.44 -SubnetMask 255.255.255.0 -DefaultGateway 10.50.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-APP |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-PM-APP|Set-VM -MemoryGB 16 -NumCpu 4 -OSCustomizationSpec $script:customer-$Char-PM-APP -Confirm:$false
Get-VM $script:customer-$Char-PM-APP|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-PM-APP|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-PM-APP|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-PM-APP|Set-Annotation -CustomAttribute "Deployment Template" -Value Win2012R2Std-GUIUCS

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-PM-APP).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-PM-APP' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-PM-APP
wait-tools -VM $script:customer-$Char-PM-APP
remove-oscustomizationspec $script:customer-$Char-PM-APP -confirm:$false

Write-Verbose -Message "Deploying PM-DB Server" -Verbose

$Datastore = Get-Largest

New-VM -Name $script:customer-$Char-PM-DB -Template PM-SQL-NEW -ResourcePool $TargetCluster -Datastore $Datastore  -Location $Folder
Get-NetworkAdapter $script:customer-$Char-PM-DB|Remove-NetworkAdapter -confirm:$false
New-NetworkAdapter -VM $script:customer-$Char-PM-DB -NetworkName vLAN-1$script:customernumber-$NP-DB -Type Vmxnet3 -StartConnected:$True -Confirm:$false

Get-OSCustomizationSpec -Name Win2012R2Std-GUI|New-OSCustomizationSpec -Name $script:customer-$Char-PM-DB 
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-DB|Get-OSCustomizationNicMapping|Remove-OSCustomizationNicMapping -confirm:$false
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-DB |New-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.150.$UIP.44 -SubnetMask 255.255.255.0 -DefaultGateway 10.150.$UIP.1 -Dns 10.50.$UIP.11,10.50.$UIP.12 -Position 1
Get-OSCustomizationSpec -Name $script:customer-$Char-PM-DB |Set-OSCUstomizationSpec -Domain $Dom -DomainCredentials $DomainCredential2 -DnsServer 10.50.$UIP.11,10.50.$UIP.12

Get-VM $script:customer-$Char-PM-DB|Set-VM -MemoryGB 24 -NumCpu 8 -OSCustomizationSpec $script:customer-$Char-PM-DB -Confirm:$false
Get-VM $script:customer-$Char-PM-DB|Set-Annotation -CustomAttribute "Created by" -Value "New VM Script(run as $User)"
$DateTime=Get-Date
Get-VM $script:customer-$Char-PM-DB|Set-Annotation -CustomAttribute "Created on" -Value $DateTime
Get-VM $script:customer-$Char-PM-DB|Set-Annotation -CustomAttribute "Deployment Script Version" -Value $Ver
Get-VM $script:customer-$Char-PM-DB|Set-Annotation -CustomAttribute "Deployment Template" -Value PM-SQL-NEW

$spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec -Property @{"NumCoresPerSocket" = 2}
(get-VM $script:customer-$Char-PM-DB).ExtensionData.ReconfigVM_Task($spec)
Write-Host $script:customer-$Char-PM-DB' Built:'
Write-Host "Booting"
Start-sleep -Seconds 30
# Power On New VM
Start-VM $script:customer-$Char-PM-DB
wait-tools -VM $script:customer-$Char-PM-DB
remove-oscustomizationspec $script:customer-$Char-PM-DB -confirm:$false
}

Write-Verbose -Message " All servers have been built doing post build clean up" -Verbose

Write-Verbose -Message "Setting IPV6 Address" -Verbose

Invoke-VMScript -ScriptText $IPV6 -VM $DomainControllerVMName -GuestUser $DomainUser2 -GuestPassword $DomainPWord2

Write-Verbose -Message "Setting Admin Account to not Expire" -Verbose

Invoke-VMScript -ScriptText $Expire -VM $DomainControllerVMName -GuestUser $DomainUser2 -GuestPassword $DomainPWord2

Write-Verbose -Message "Adding Linux VM's to DNS" -Verbose

Invoke-VMScript -ScriptText $Record -VM $DomainControllerVMName -GuestUser $DomainUser2 -GuestPassword $DomainPWord2

Invoke-VMScript -ScriptText $RecordDB -VM $DomainControllerVMName -GuestUser $DomainUser2 -GuestPassword $DomainPWord2

Invoke-VMScript -ScriptText $RecordTPS -VM $DomainControllerVMName -GuestUser $DomainUser2 -GuestPassword $DomainPWord2

Write-Verbose -Message "Creating Backup Mount on FND-DB Server" -Verbose

Invoke-VMScript -ScriptText 'mkdir /backup' -Scripttype Bash -VM $script:customer-$Char-FND-DB -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $Mount -Scripttype Bash -VM $script:customer-$Char-FND-DB -GuestUser $Lin1 -GuestPassword $Lin2

Start-Sleep 20

Invoke-VMScript -ScriptText 'mount -a' -Scripttype Bash -VM $script:customer-$Char-FND-DB -GuestUser $Lin1 -GuestPassword $Lin2

Write-Verbose -Message "Setting IPV6 Address for FND-APP" -Verbose

Invoke-VMScript -ScriptText 'sed -i "s/IPV6_AUTOCONF=yes/IPV6_AUTOCONF=no/g" /etc/sysconfig/network-scripts/ifcfg-ens192' -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDV6 -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDGateway -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS2 -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText 'service network restart' -Scripttype Bash -VM $FND1 -GuestUser $Lin1 -GuestPassword $Lin2


Write-Verbose -Message "Setting IPV6 Address For FND-DB" -Verbose

Invoke-VMScript -ScriptText 'sed -i "s/IPV6_AUTOCONF=yes/IPV6_AUTOCONF=no/g" /etc/sysconfig/network-scripts/ifcfg-ens192' -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDBV6 -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDBGateway -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS2 -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText 'service network restart' -Scripttype Bash -VM $FND2 -GuestUser $Lin1 -GuestPassword $Lin2


Write-Verbose -Message "Setting IPV6 Address For TPS" -Verbose

Invoke-VMScript -ScriptText 'sed -i "s/IPV6_AUTOCONF=yes/IPV6_AUTOCONF=no/g" /etc/sysconfig/network-scripts/ifcfg-ens192' -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $TPSV6 -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $TPSGateway -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText $FNDDNS2 -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Invoke-VMScript -ScriptText 'service network restart' -Scripttype Bash -VM $TPS -GuestUser $Lin1 -GuestPassword $Lin2

Write-Verbose -Message "Configuring NPS Server" -Verbose

Invoke-VMScript -ScriptText $NPSInstall -VM $script:customer-$Char-NPS -GuestUser $DomainUser2 -GuestPassword $DomainPWord2

Write-Verbose -Message "Restarting FND-DB Server" -Verbose

Restart-VM -VM $FND2 -Confirm:$false 

# End of Script