# ------vCenter Targeting Varibles and Connection Commands Below------
# This section insures that the PowerCLI PowerShell Modules are currently active. The pipe to Out-Null can be removed if you desire additional
# Console output.
Get-Module -ListAvailable VMware* | Import-Module | Out-Null

# ------vSphere Targeting Variables tracked below------
$creds = Get-Credential -Message 'Please Enter vCenter Credentials'
$User = $creds.UserName


# connect to vCenter
Connect-VIserver esxtpll-vc01.itronms.local -Credential $creds
 
######################################################-User-Definable Variables-In-This-Section-##########################################################################################

$script:customer = Read-Host -Prompt "Please enter customer code "

$script:customernumber = Read-Host -Prompt "Please enter customer vLAN "

$script:Cluster = Read-Host -Prompt "Is this Production or NonProduction?(P Or NP) "

if ($script:Cluster -eq 'P') {$TargetCluster = Get-Cluster -Name "ItronMS-TP-LL-UCS-PROD";$DomainControllerVMName = "$script:customer-P-DC01";$DC02VMName = "$script:customer-P-DC02"}

if ($script:Cluster -eq 'NP') {$TargetCluster = Get-Cluster -Name "ItronMS-TP-LL-UCS-DEV";$DomainControllerVMName = "$script:customer-NP-DC01";$DC02VMName = "$script:customer-NP-DC02"}

$UIP = ($script:customernumber - 500)

$Dom = $script:customer + "AMI.local"

$NP = $script:customer + "NP" 

#Create and setup VDS Groups for the customer

if ($script:Cluster -eq 'P'){

$Referencegroup= Get-VDPortgroup -Name "vLAN-0504-ACR-App"

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-0$script:customernumber-$script:customer-App -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId $script:customernumber

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-1$script:customernumber-$script:customer-DB -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId $script:customernumber -NumPorts 8

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-2$script:customernumber-$script:customer-DMZ -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId $script:customernumber -NumPorts 8
}

elseif ($script:Cluster -eq 'NP') {

$Referencegroup= Get-VDPortgroup -Name "vLAN-0504-ACR-App"

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-0$script:customernumber-$NP-App -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId $script:customernumber

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-1$script:customernumber-$NP-DB -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId $script:customernumber -NumPorts 8

New-VDPortgroup -VDSwitch Data-Dswitch -Name vLAN-2$script:customernumber-$NP-DMZ -ReferencePortgroup $Referencegroup | Set-VDPortgroup -VlanId $script:customernumber -NumPorts 8
}

# ------Virtual Machine Targeting Variables tracked below------

# The Below Variables define the names of the virtual machines upon deployment, the target cluster, and the source template and customization specification inside of vCenter to use during
# the deployment of the VMs.

$SourceVMTemplate = Get-Template -Name "Win2016Std-DTEUCS"
$SourceCustomSpec = Get-OSCustomizationSpec -Name "Win2016Std-DTE-Baseline"


#Creates Customer Folder in Vcenter

if ($script:Cluster -eq 'P') { $Folder = $script:customer}

if ($script:Cluster -eq 'NP') { $Folder = "$script:customer-NP"}

New-Folder -Name $Folder -Location Customers

 
 
# ------This section contains the commands for defining the IP and networking settings for the new virtual machines------
# NOTE: The below IPs and Interface Names need to be updated for your environment. 
 
# Domain Controller VM IPs Below
# NOTE: Insert IP info in $IP Variable
 
$DCNetworkSettings = ' $IP = "89";
                       netsh interface ip set address "Ethernet0" static 10.50.$IP.11 255.255.255.0 10.50.$IP.1'


# DC02 VM IPs Below in $IP Variable

$DC02NetworkSettings = '$IP = "89";
                        netsh interface ip set address "Ethernet0" static 10.50.$IP.12 255.255.255.0 10.50.$IP.1'

# NOTE: DNS Server IP Below in $IP Variable

$DNSSettings = '$IP = "89";
                    Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses("10.50.$IP.11","10.50.$IP.12")'

$InstallDNSZones = '$IP = "89";
                    Set-DnsServerForwarder -IPAddress ("10.51.100.101","10.51.100.102","fdfa:ffff:0:200:10:51:100:101","fdfa:ffff:0:200:10:51:100:102") 
                    Add-DnsServerPrimaryZone -NetworkID "10.50.$IP.0/24" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "10.150.$IP.0/24" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "10.250.$IP.0/24" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "fdfa:ffff:0:5$IP::/64" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "fdfa:ffff:0:15$IP::/64" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure;
                    Add-DnsServerPrimaryZone -NetworkID "fdfa:ffff:0:25$IP::/64" -ReplicationScope Forest -DynamicUpdate NonsecureAndSecure'


 
 
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
 
 
 
# ------This Section Contains the Scripts to be executed against new VMs Regardless of Role

# This Scriptblock is used to add new VMs to the newly created domain by first defining the domain creds on the machine and then using Add-Computer

$JoinNewDomain = '$Code = "LLTPNP";
                  $Domain = $Code + "AMI.local"
                  $DomainUser = "$Domain\Administrator";
                  $DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force;
                  $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord;
                  Add-Computer -DomainName $Domain -Credential $DomainCredential;
                  Start-Sleep -Seconds 20;
                  Shutdown /r /t 0'

 
 
# ------This Section Contains the Scripts to be executed against New Domain Controller VMs------

# This Command will Install the AD Role on the target virtual machine. 
$InstallADRole = 'Install-WindowsFeature -Name "AD-Domain-Services" -Restart'
$InstallADTools = ' Add-windowsfeature rsat-adds -includeallsubfeature'

# This Scriptblock will define settings for a new AD Forest and then provision it with said settings. 
# NOTE - Make sure to define the DSRM Password below in the line below that defines the $DSRMPWord Variable!!!!
$ConfigureNewDomain =  '$Code = "LLTPNP";
                       $DomainName = $Code + "AMI.local"
                       $DomainMode = "Win2012R2";
                       $ForestMode = "Win2012R2";
                       $DSRMPWord = ConvertTo-SecureString -String "p@ssw0rd" -AsPlainText -Force;
                       Install-ADDSForest -ForestMode $ForestMode -DomainMode $DomainMode -DomainName $DomainName -InstallDns -SafeModeAdministratorPassword $DSRMPWord -Force'

# ------This Section Contains the Scripts to be executed against DC02 VMs------

$InstallDC02Role =    '$Code = "LLTPNP";
                       $DomainName = $Code + "AMI.local"
                       $DomainMode = "Win2012R2";
                       $ForestMode = "Win2012R2";
                       $DomainUser = "$DomainName\Administrator";
                       $DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force;
                       $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord;
                       $DSRMPWord = ConvertTo-SecureString -String "p@ssw0rd" -AsPlainText -Force;
                       Install-ADDSDomainController -DomainName $DomainName -Credential $DomainCredential -InstallDns -SafeModeAdministratorPassword $DSRMPWord -Force'



$InstallDNSZones2 = 'Set-DnsServerForwarder -IPAddress ("10.51.100.101","10.51.100.102","fdfa:ffff:0:200:10:51:100:101","fdfa:ffff:0:200:10:51:100:102")'


# ----------------This Section Contains the Scripts to Setup Groups and Users-----------

$OU =  '$Code = "LLTPNP";
        $Domain = $Code + "AMI"
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
        New-ADOrganizationalUnit -Name Groups -Path "OU=Itron,DC=$Domain,DC=local";'

$Group1 = '$Code = "LLTPNP";
           $Domain = $Code + "AMI";
           $IEE = $Code  + "_APP_P_IEE_Admin";
           $IEE2 = $Code  + "_APP_P_IEE_User";
           $IEE3 = $Code  + "_APP_P_IEECSR_User";
           $ISM = $Code  + "_APP_P_ISM_Admin";
           $ISM2 = $Code  + "_APP_P_ISM_User";
           $FND = $Code + "_FND_Admin";
           $FND1 = $Code + "_FND_Endpoint_Operator";
           $FND2 = $Code + "_FND_Monitor_Only";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND -SamAccountName $FND -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE -SamAccountName $IEE -DisplayName $IEE -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE2 -SamAccountName $IEE2 -DisplayName $IEE2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE3 -SamAccountName $IEE3 -DisplayName $IEE3 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM -SamAccountName $ISM -DisplayName $ISM -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM2 -SamAccountName $ISM2 -DisplayName $ISM2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND1 -SamAccountName $FND1 -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND2 -SamAccountName $FND2 -DisplayName $FND2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";'


$Group1Test = '$Code = "LLTPNP";
               $Domain = $Code + "AMI";
               $IEE = $Code  + "_APP_T_IEE_Admin";
               $IEE2 = $Code  + "_APP_T_IEE_User";
               $IEE3 = $Code  + "_APP_T_IEECSR_User";
               $ISM = $Code  + "_APP_T_ISM_Admin";
               $ISM2 = $Code  + "_APP_T_ISM_User";
               $FND = $Code + "_FND_Admin";
               $FND1 = $Code + "_FND_Endpoint_Operator";
               $FND2 = $Code + "_FND_Monitor_Only";
               $ErrorActionPreference = "SilentlyContinue"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND -SamAccountName $FND -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               $ErrorActionPreference = "Continue"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE -SamAccountName $IEE -DisplayName $IEE -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE2 -SamAccountName $IEE2 -DisplayName $IEE2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $IEE3 -SamAccountName $IEE3 -DisplayName $IEE3 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM -SamAccountName $ISM -DisplayName $ISM -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $ISM2 -SamAccountName $ISM2 -DisplayName $ISM2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND1 -SamAccountName $FND1 -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND2 -SamAccountName $FND2 -DisplayName $FND2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";'

$Group2 = '$Code = "LLTPNP"
           $Domain = $Code + "AMI"
           $FND = $Code + "_FND_NBAPI"
           $FND2 = $Code + "_FND_Root"
           $FND3 = $Code + "_FND_Router_Operator"
           $CGR = "CGR_GROUP"
           $Meter =  $Code + "_Meters"
           $SVC = $Code + "_ServiceAccount"
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND -SamAccountName $FND -DisplayName $FND -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND3 -SamAccountName $FND3 -DisplayName $FND3 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $FND2 -SamAccountName $FND2 -DisplayName $FND2 -Path "OU=Applications,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 1 -GroupCategory Security -Name $CGR -SamAccountName $CGR -DisplayName $CGR -Path "OU=CGRs,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 1 -GroupCategory Security -Name $Meter -SamAccountName $Meter -DisplayName $Meter -Path "OU=Meters,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $SVC -SamAccountName $SVC -DisplayName $SVC -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local";'

$Group3 = '$Code = "LLTPNP"
           $Domain = $Code + "AMI"
           $Admin = $Code + "_Admin"
           $OW = $Code + "_APP_P_OWCEUI_Admin"
           $OW2 = $Code + "_APP_P_OWCEUI_User"
           $DBA = $Code + "_DBA"
           $DBU =  $Code + "_DBU"
           $TS = $Code + "_TS_User"
           $User = $Code + "_Users"
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $Admin -SamAccountName $Admin -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW -SamAccountName $OW -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW2 -SamAccountName $OW2 -DisplayName $OW2 -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBA -SamAccountName $DBA -DisplayName $DBA -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBU -SamAccountName $DBU -DisplayName $DBU -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $TS -SamAccountName $TS -DisplayName $TS -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $User -SamAccountName $User -DisplayName $User -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";'


$Group3Test = '$Code = "LLTPNP"
               $Domain = $Code + "AMI"
               $Admin = $Code + "_Admin"
               $OW = $Code + "_APP_T_OWCEUI_Admin"
               $OW2 = $Code + "_APP_T_OWCEUI_User"
               $DBA = $Code + "_DBA"
               $DBU =  $Code + "_DBU"
               $TS = $Code + "_TS_User"
               $User = $Code + "_Users"
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $Admin -SamAccountName $Admin -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW -SamAccountName $OW -DisplayName $Admin -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $OW2 -SamAccountName $OW2 -DisplayName $OW2 -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBA -SamAccountName $DBA -DisplayName $DBA -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBU -SamAccountName $DBU -DisplayName $DBU -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $TS -SamAccountName $TS -DisplayName $TS -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";
               New-ADGroup -GroupScope 0 -GroupCategory Security -Name $User -SamAccountName $User -DisplayName $User -Path "OU=Users,OU=Customers,DC=$Domain,DC=local";'

$Group4 = '$Code = "LLTPNP"
           $Domain = $Code + "AMI"
           $Admin = "Itron Admins"
           $DBA = "Itron DBA"
           $Net = "Network_Admin"
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $Admin -SamAccountName $Admin -DisplayName $Admin -Path "OU=Groups,OU=Itron,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $DBA -SamAccountName $DBA -DisplayName $Admin -Path "OU=Groups,OU=Itron,DC=$Domain,DC=local";
           New-ADGroup -GroupScope 0 -GroupCategory Security -Name $NET -SamAccountName $NET -DisplayName $NET -Path "OU=Groups,OU=Itron,DC=$Domain,DC=local";'



$Users =  '$Code = "LLTPNP";
          $Domain = $Code + "AMI"
          $CA = $Code + "PCASVC";
          $IEE2 = $Code + "PIEEDA";
          $IEE = $Code + "PIEEDB";  
          $FCS = $Code + "PFVCSVC";
          $IEE3 = $Code + "PIEESVC";
          $ISM = $Code + "PISMAdmin";
          $ISM2 = $Code + "PISMDB";
          New-ADUser -Name $CA -GivenName $CA -SamAccountName $CA -Surname "Service" -DisplayName $CA -UserPrincipalName "$CA@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $IEE2 -GivenName $IEE2 -SamAccountName $IEE2 -Surname "Service" -DisplayName $IEE2 -UserPrincipalName "$IEE2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $FCS -GivenName $FCS -SamAccountName $FCS -Surname "Service" -DisplayName $FCS -UserPrincipalName "$FCS@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $IEE3 -GivenName $IEE3 -SamAccountName $IEE3 -Surname "Service" -DisplayName $IEE3 -UserPrincipalName "$IEE3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $ISM -GivenName $ISM -SamAccountName $ISM -Surname "Service" -DisplayName $ISM -UserPrincipalName "$ISM@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
          New-ADUser -Name $ISM2 -GivenName $ISM2 -SamAccountName $ISM2 -Surname "Service" -DisplayName $ISM2 -UserPrincipalName "$ISM2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1'


$UsersTest =  '$Code = "LLTPNP";
               $Domain = $Code + "AMI"
               $CA = $Code + "TCASVC";
               $IEE2 = $Code + "TIEEDA";
               $IEE = $Code + "TIEEDB";  
               $FCS = $Code + "TFVCSVC";
               $IEE3 = $Code + "TIEESVC";
               $ISM = $Code + "TISMAdmin";
               $ISM2 = $Code + "TISMDB";
               New-ADUser -Name $CA -GivenName $CA -SamAccountName $CA -Surname "Service" -DisplayName $CA -UserPrincipalName "$CA@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE2 -GivenName $IEE2 -SamAccountName $IEE2 -Surname "Service" -DisplayName $IEE2 -UserPrincipalName "$IEE2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $FCS -GivenName $FCS -SamAccountName $FCS -Surname "Service" -DisplayName $FCS -UserPrincipalName "$FCS@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE3 -GivenName $IEE3 -SamAccountName $IEE3 -Surname "Service" -DisplayName $IEE3 -UserPrincipalName "$IEE3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $ISM -GivenName $ISM -SamAccountName $ISM -Surname "Service" -DisplayName $ISM -UserPrincipalName "$ISM@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $ISM2 -GivenName $ISM2 -SamAccountName $ISM2 -Surname "Service" -DisplayName $ISM2 -UserPrincipalName "$ISM2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1'


$Users2 = '$Code = "LLTPNP"
           $Domain = $Code + "AMI"
           $ISM3 = $Code + "PISMEXTCon";
           $ISM4 = $Code + "PISMSVC";
           $OW = $Code + "POWAPP";
           $IEE = $Code + "PIEEDB"; 
           $OW2 = $Code + "POWDB";
           New-ADUser -Name $ISM3 -GivenName $ISM3 -SamAccountName $ISM3 -Surname "Service" -DisplayName $ISM3 -UserPrincipalName "$ISM3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1; 
           New-ADUser -Name $ISM4 -GivenName $ISM4 -SamAccountName $ISM4 -Surname "Service" -DisplayName $ISM4 -UserPrincipalName "$ISM4@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;                
           New-ADUser -Name $OW -GivenName $OW -SamAccountName $OW -Surname "Service" -DisplayName $OW -UserPrincipalName "$OW@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;        
           New-ADUser -Name $OW2 -GivenName $OW2 -SamAccountName $OW2 -Surname "Service" -DisplayName $OW2 -UserPrincipalName "$OW2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
           New-ADUser -Name $IEE -GivenName $IEE -SamAccountName $IEE -Surname "Service" -DisplayName $IEE -UserPrincipalName "$IEE@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1'


$Users2Test = '$Code = "LLTPNP"
               $Domain = $Code + "AMI"
               $ISM3 = $Code + "TISMEXTCon";
               $ISM4 = $Code + "TISMSVC";
               $OW = $Code + "TOWAPP";
               $IEE = $Code + "TIEEDB"; 
               $OW2 = $Code + "TOWDB";
               New-ADUser -Name $ISM3 -GivenName $ISM3 -SamAccountName $ISM3 -Surname "Service" -DisplayName $ISM3 -UserPrincipalName "$ISM3@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1; 
               New-ADUser -Name $ISM4 -GivenName $ISM4 -SamAccountName $ISM4 -Surname "Service" -DisplayName $ISM4 -UserPrincipalName "$ISM4@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;                
               New-ADUser -Name $OW -GivenName $OW -SamAccountName $OW -Surname "Service" -DisplayName $OW -UserPrincipalName "$OW@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;        
               New-ADUser -Name $OW2 -GivenName $OW2 -SamAccountName $OW2 -Surname "Service" -DisplayName $OW2 -UserPrincipalName "$OW2@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1;
               New-ADUser -Name $IEE -GivenName $IEE -SamAccountName $IEE -Surname "Service" -DisplayName $IEE -UserPrincipalName "$IEE@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local" -Enabled 1'


$Users3 =  '$Code = "LLTPNP";
            $Domain = $Code + "AMI";
            New-ADUser -Name "Prabhu Armugam" -GivenName "Prabhu" -Surname "Armugam" -DisplayName "Prabhu Armugam" -SamAccountName "PArmugam" -UserPrincipalName "PArmugam@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Nishighandha" -GivenName "Nishighandha" -Surname "Kulkarni" -DisplayName "Nishighandha Kulkarni"-SamAccountName "NKulkarni" -UserPrincipalName "NKulkarni@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Dinesh Govindu" -GivenName "Dinesh" -Surname "Govindu" -DisplayName "Dinesh Govindu" -SamAccountName "DGovindu" -UserPrincipalName "DGovindu@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Aravind Manoharan" -GivenName "Aravind" -Surname "Manoharan" -DisplayName "Aravind Manoharan" -SamAccountName "AManoharan" -UserPrincipalName "AManoharan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Ajmal Firdose" -GivenName "Ajmal" -Surname "Firdose" -DisplayName "Ajmal Firdose" -SamAccountName "AFirdose" -UserPrincipalName "AFirdose@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "James Scott" -GivenName "James" -Surname "Scott" -DisplayName "James Scott" -SamAccountName "JScott" -UserPrincipalName "JScott@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;'

$Users4 =   '$Code = "LLTPNP";
            $Domain = $Code + "AMI";
            New-ADUser -Name "Pavithra Ramani" -GivenName "Pavithra" -Surname "Ramani" -DisplayName "Pavithra Ramani" -SamAccountName "PRamani" -UserPrincipalName "PRamani@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Muthuraman" -GivenName "Muthuraman" -Surname "Pattavarayan" -DisplayName "Muthuraman Pattavarayan" -SamAccountName "MPattavarayan" -UserPrincipalName "MPattavarayan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "MadhanKumar" -GivenName "MadhanKumar" -Surname "Murugesan" -DisplayName "MadhanKumar Murugesan" -SamAccountName "MMurugesan" -UserPrincipalName "MMurugesan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Kevin Nail" -GivenName "Kevin" -Surname "Nail" -DisplayName "Kevin Nail" -UserPrincipalName "KNail@$Domain.local" -SamAccountName "KNail" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Matt Elliott" -GivenName "Matt" -Surname "Elliott" -DisplayName "Matt Elliott" -UserPrincipalName "MElliott@$Domain.local" -SamAccountName "Melliott" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Lance Pelton" -GivenName "Lance" -Surname "Pelton" -DisplayName "Lance Pelton" -UserPrincipalName "LPelton@$Domain.local" -SamAccountName "LPelton" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;'


$Users5 =   '$Code = "LLTPNP";
            $Domain = $Code + "AMI";
            New-ADUser -Name "Sateesh Poojari" -GivenName "Sateesh" -Surname "Poojari" -DisplayName "Sateesh Poojari" -SamAccountName "Spoojari"  -UserPrincipalName "SPoojari@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Shahab Khan" -GivenName "Shahab" -Surname "Khan" -DisplayName "Shahab Khan" -SamAccountName "SKhan"  -UserPrincipalName "SKhan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Subbaraman" -GivenName "Subbaraman" -Surname "Apparsami" -DisplayName "Subbaraman Apparsami" -SamAccountName "SApparsami"  -UserPrincipalName "SApparsami@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Syed Rizvi" -GivenName "Syed" -Surname "Rizvi" -DisplayName "Syed Rizvi" -SamAccountName "SRizvi"  -UserPrincipalName "SRizvi@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Bence Bihari" -GivenName "Bence" -Surname "Bihari" -DisplayName "Bence Bihari" -SamAccountName "BBihari"  -UserPrincipalName "BBihari@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Senthil Natarajan" -GivenName "Senthil" -Surname "Natarajan" -DisplayName "Senthil Natarajan" -SamAccountName "SNatarajan"  -UserPrincipalName "SNatarajan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "Tom Moldovan" -GivenName "Tom" -Surname "Moldovan" -DisplayName "Tom Moldovan" -SamAccountName "TMoldovan"  -UserPrincipalName "TMoldovan@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Users,OU=Itron,DC=$Domain,DC=local" -Enabled 1;'           


$Users6 =   '$Code = "LLTPNP";
            $Domain = $Code + "AMI";
            New-ADUser -Name "nmsconfig" -GivenName "nmsconfig" -Surname "nmsconfig" -DisplayName "nmsconfig" -SamAccountName "nmsconfig"  -UserPrincipalName "nmsconfig@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "RDS_Interface" -GivenName "RDS_Interface" -Surname "RDS_Interface" -DisplayName "RDS_Interface" -SamAccountName "RDS_Interface"  -UserPrincipalName "RDS_Interface@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Itron,DC=$Domain,DC=local" -Enabled 1;
            New-ADUser -Name "swsamsvc" -GivenName "swsamsvc" -Surname "swsamsvc" -DisplayName "swsamsvc" -SamAccountName "swsamsvc"  -UserPrincipalName "swsamsvc@$Domain.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "Temp1234" -Force) -PasswordNeverExpires 1 -Path "OU=Service_Accounts,OU=Itron,DC=$Domain,DC=local" -Enabled 1;'

$GroupAdd1 = 'Add-ADGroupMember -Identity "Domain Admins" -Members @("PArmugam","NKulkarni","DGovindu","AManoharan","AFirdose","JScott","PRamani","MPattavarayan","MMurugesan","KNail","MElliott","LPelton","SPoojari","SKhan","SApparsami","SRizvi","BBihari","SNatarajan","TMoldovan")'

$GroupAdd2 = '$Code = "LLTPNP"     
              $CA = $Code + "PCASVC";
              $IEE2 = $Code + "PIEEDA";
              $IEE = $Code + "PIEEDB";  
              $FCS = $Code + "PFVCSVC";
              $IEE3 = $Code + "PIEESVC";
              $ISM = $Code + "PISMAdmin";
              $ISM2 = $Code + "PISMDB";
              $ISM3 = $Code + "PISMEXTCon";
              $ISM4 = $Code + "PISMSVC";
              $OW = $Code + "POWAPP";
              $OW2 = $Code + "POWDB";
              $Group1 = $Code + "_ServiceAccount";
              $Group2 = $Code  + "_APP_P_IEE_Admin";
              $Group3 = $Code + "_APP_P_IEE_User";
              $Group4 = $Code + "_APP_P_ISM_Admin";
              $Group5 = $Code + "_APP_P_ISM_User";
              $Group6 = $Code + "_APP_P_OWCEUI_Admin";
              $Group7 = $Code + "_APP_P_OWCEUI_User";
              Add-ADGroupMember -Identity $Group1 -Members @("$CA","$FCS","$IEE3","$IEE","$ISM2","$ISM3","$ISM4");
              Add-ADGroupMember -Identity $Group2 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group3 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group4 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group5 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group6 -Members @("$OW");
              Add-ADGroupMember -Identity $Group7 -Members @("$OW");'

$GroupAddTest2 = '$Code = "LLTPNP"     
              $CA = $Code + "TCASVC";
              $IEE2 = $Code + "TIEEDA";
              $IEE = $Code + "TIEEDB";  
              $FCS = $Code + "TFVCSVC";
              $IEE3 = $Code + "TIEESVC";
              $ISM = $Code + "TISMAdmin";
              $ISM2 = $Code + "TISMDB";
              $ISM3 = $Code + "TISMEXTCon";
              $ISM4 = $Code + "TISMSVC";
              $OW = $Code + "TOWAPP";
              $OW2 = $Code + "TOWDB";
              $Group1 = $Code + "_ServiceAccount";
              $Group2 = $Code  + "_APP_T_IEE_Admin";
              $Group3 = $Code + "_APP_T_IEE_User";
              $Group4 = $Code + "_APP_T_ISM_Admin";
              $Group5 = $Code + "_APP_T_ISM_User";
              $Group6 = $Code + "_APP_T_OWCEUI_Admin";
              $Group7 = $Code + "_APP_T_OWCEUI_User";
              Add-ADGroupMember -Identity $Group1 -Members @("$CA","$FCS","$IEE3","$IEE","$ISM2","$ISM3","$ISM4");
              Add-ADGroupMember -Identity $Group2 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group3 -Members @("$IEE2");
              Add-ADGroupMember -Identity $Group4 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group5 -Members @("$ISM");
              Add-ADGroupMember -Identity $Group6 -Members @("$OW");
              Add-ADGroupMember -Identity $Group7 -Members @("$OW");'

#-----------------These 3 are password Resets-----------------------------------

$PWReset = '$Code = "LLTPNP"
            $Domain = $Code + "AMI"
CD C:\
#This is the file that will be generated with the users account ID and the password generated.
[String]$path= ".\SVCPasswords.txt"

#This will check if the file exist and will delete that file so a new one can be created from the scratch
#If the doesnt exist will through an error saying that the file doesnt exist and will continue.
if ($path -ne $null){Remove-Item $path}


<# Required Assembly to Generate Passwords #>
Add-Type -Assembly System.Web
#In my case I created a OU for test purposes here it is.
#You need to change it to meet your requirements.
$OU="OU=Service_Accounts,OU=Customers,DC=$Domain,DC=local"

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

} '

$PWReset2 = '$Code = "LLTPNP"
            $Domain = $Code + "AMI"
CD C:\
#This is the file that will be generated with the users account ID and the password generated.
[String]$path= ".\ItronSVCPasswords.txt"

#This will check if the file exist and will delete that file so a new one can be created from the scratch
#If the doesnt exist will through an error saying that the file doesnt exist and will continue.
if ($path -ne $null){Remove-Item $path}


<# Required Assembly to Generate Passwords #>
Add-Type -Assembly System.Web
#In my case I created a OU for test purposes here it is.
#You need to change it to meet your requirements.
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

} '

$PWReset3 = '$Code = "LLTPNP"
            $Domain = $Code + "AMI"
CD C:\
#This is the file that will be generated with the users account ID and the password generated.
[String]$path= ".\ItronEmployees.txt"

#This will check if the file exist and will delete that file so a new one can be created from the scratch
#If the doesnt exist will through an error saying that the file doesnt exist and will continue.
if ($path -ne $null){Remove-Item $path}


<# Required Assembly to Generate Passwords #>
Add-Type -Assembly System.Web
#In my case I created a OU for test purposes here it is.
#You need to change it to meet your requirements.
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

} '

#-------------These Setup the GPO's----------------------------

$GPO = '$Code = "LLTPNP"
        $Domain = $Code + "AMI"
        New-GPO -name "2012 SMB1 Disable"
        New-GPO -name "Admin Hidden Files"
        New-GPO -name "Background"
        New-GPO -name "Backup Drive"
        New-GPO -name "CUST-$Code"
        New-GPO -name "Itronms-TPLL"
        New-GPO -name "RDP End Disconnected Sessions"
        New-GPO -name "Security Policy - Domain"
        New-GPO -name "UAC Disable"
        Import-gpo -BackupId 76A59C56-454C-4A04-AB86-9AEC3FF9DB64 -Path C:\GPOBackup\ -TargetName "2012 SMB1 Disable"
        Import-gpo -BackupId 2CDF560A-D9B2-40E8-81D4-975AA5ED5FC3 -Path C:\GPOBackup\ -TargetName "Admin Hidden Files"
        Import-gpo -BackupId F6AA2AF2-9A70-46CF-94E1-8F3F31603DD9 -Path C:\GPOBackup\ -TargetName "Background"
        Import-gpo -BackupId FAB29508-2599-42D6-AFB8-9B8F3B3BEB7B -Path C:\GPOBackup\ -TargetName "Backup Drive"
        Import-gpo -BackupId C7AEBFDB-30A3-4CC0-B516-2D03CD82B866 -Path C:\GPOBackup\ -TargetName "CUST-$Code"
        Import-gpo -BackupId 247F1631-D48C-495A-8A24-EEEC35E89FF9 -Path C:\GPOBackup\ -TargetName "Itronms-TPLL" -MigrationTable C:\GPOBackup\MigTable.migtable
        Import-gpo -BackupId C45D8DB2-AE8F-4CAF-8EE7-A02C4BE95FED -Path C:\GPOBackup\ -TargetName "RDP End Disconnected Sessions"
        Import-gpo -BackupId EF583E60-DFA0-45C5-88DD-B8418464642E -Path C:\GPOBackup\ -TargetName "Security Policy - Domain"
        Import-gpo -BackupId B81A062B-4744-4BED-AEC1-931B5E38AC88 -Path C:\GPOBackup\ -TargetName "UAC Disable"'

$GPOLink  = '$Code = "LLTPNP";
             $Domain = $Code + "AMI";
             New-GPLink -Name "2012 SMB1 Disable" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "Admin Hidden Files" -Target "DC=$Domain,DC=Local";
             New-GPLink -Name "Background" -Target "DC=$Domain,DC=Local";
             New-GPLink -Name "Backup Drive" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "CUST-$Code" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "Itronms-TPLL" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "RDP End Disconnected Sessions" -Target "DC=$Domain,DC=Local";
             New-GPLink -Name "Security Policy - Domain" -Target "DC=$Domain,DC=Local"; 
             New-GPLink -Name "UAC Disable" -Target "DC=$Domain,DC=Local";'
             




#########################################################################################################################################################################################

 
 
# Script Execution Occurs from this point down

# ------This Section Deploys the new VM(s) using a pre-built template and then applies a customization specification to it. It then waits for Provisioning To Finish------

Write-Verbose -Message "Deploying Virtual Machine with Name: [$DomainControllerVMName] using Template: [$SourceVMTemplate] and Customization Specification: [$SourceCustomSpec] on Cluster: [$TargetCluster] and waiting for completion" -Verbose

New-VM -Name $DomainControllerVMName -Template $SourceVMTemplate -ResourcePool $TargetCluster -OSCustomizationSpec $SourceCustomSpec 

Write-Verbose -Message "Virtual Machine $DomainControllerVMName Deployed. Powering On" -Verbose

Get-NetworkAdapter $DomainControllerVMName|Remove-NetworkAdapter -confirm:$false

Start-VM -VM $DomainControllerVMName

Write-Verbose -Message "Deploying Virtual Machine with Name: [$DC02VMName] using Template: [$SourceVMTemplate] and Customization Specification: [$SourceCustomSpec] on Cluster: [$TargetCluster] and waiting for completion" -Verbose

New-VM -Name $DC02VMName -Template $SourceVMTemplate -ResourcePool $TargetCluster -OSCustomizationSpec $SourceCustomSpec

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

Start-Sleep -Seconds 360

Wait-Tools -VM $DomainControllerVMName -TimeoutSeconds 300

Write-Verbose -Message "Installation of Domain Services and Forest Provisioning on $DomainControllerVMName Complete" -Verbose

# ------This Section Targets and Executes the Scripts on DC02 VM.

# Just like the DC VM, we have to first modify the IP Settings of the VM


Write-Verbose -Message "Getting ready to change IP Settings on VM $DC02VMName." -Verbose

Invoke-VMScript -ScriptText $DC02NetworkSettings -VM $DC02VMName -GuestCredential $DC02LocalCredential

Invoke-VMScript -ScriptText $DNSSettings -VM $DC02VMName -GuestCredential $DC02LocalCredential

# NOTE - The Below Sleep Command is due to it taking a few seconds for VMware Tools to read the IP Change so that we can return the below output. 
# This is strctly informational and can be commented out if needed, but it's helpful when you want to verify that the settings defined above have been 
# applied successfully within the VM. We use the Get-VM command to return the reported IP information from Tools at the Hypervisor Layer.
Start-Sleep 30
$DC02EffectiveAddress = (Get-VM $DC02VMName).guest.ipaddress[0]

Write-Verbose -Message "Assigned IP for VM [$DC02VMName] is [$DC02EffectiveAddress]" -Verbose 

Invoke-VMScript -ScriptText $DNSSettings -VM $DomainControllerVMName -GuestCredential $DomainCredential

Write-Verbose -Message "Assigned DNS for VM [$DomainControllerVMName]" -Verbose

# The Below Cmdlets actually add the VM to the newly deployed domain. 

Start-Sleep 30

#This string has a known bug with the command so we just hide the error

$ErrorActionPreference = "SilentlyContinue"

Invoke-VMScript -ScriptText $JoinNewDomain -VM $DC02VMName -GuestCredential $DC02LocalCredential

$ErrorActionPreference = "Continue"

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

if ($script:Cluster -eq 'P'){Invoke-VMScript -ScriptText $Group1 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Elseif ($script:Cluster -eq 'NP'){Invoke-VMScript -ScriptText $Group1Test -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Invoke-VMScript -ScriptText $Group2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

if ($script:Cluster -eq 'P'){Invoke-VMScript -ScriptText $Group3 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Elseif ($script:Cluster -eq 'NP'){Invoke-VMScript -ScriptText $Group3Test -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Invoke-VMScript -ScriptText $Group4 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Write-Verbose -Message "Setting up Users on [$DomainControllerVMName]" -Verbos

if ($script:Cluster -eq 'P'){Invoke-VMScript -ScriptText $Users -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($script:Cluster -eq 'NP'){Invoke-VMScript -ScriptText $UsersTest -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

if ($script:Cluster -eq 'P'){Invoke-VMScript -ScriptText $Users2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($script:Cluster -eq 'NP'){Invoke-VMScript -ScriptText $Users2Test -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

Invoke-VMScript -ScriptText $Users3 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Invoke-VMScript -ScriptText $Users4 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Invoke-VMScript -ScriptText $Users5 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Invoke-VMScript -ScriptText $Users6 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

Write-Verbose -Message "Adding Users to Groups on [$DomainControllerVMName]" -Verbos

Invoke-VMScript -ScriptText $GroupAdd1 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord

if ($script:Cluster -eq 'P'){Invoke-VMScript -ScriptText $GroupAdd2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

elseif ($script:Cluster -eq 'NP'){Invoke-VMScript -ScriptText $GroupAddTest2 -VM $DomainControllerVMName -GuestUser $DomainUser -GuestPassword $DomainPWord}

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

Write-Verbose -Message "Environment Setup Complete" -Verbose

# End of Script
