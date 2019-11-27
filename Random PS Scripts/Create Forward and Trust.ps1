Function New-ADForestTrust
{
	Param
	(
		[parameter(Mandatory=$true)]
		[String]$RemoteForest,
		[parameter(Mandatory=$true)]
		[String]$RemoteAdmin,
		[parameter(Mandatory=$true)]
		[String]$RemotePassword,
		[parameter(Mandatory=$true)]
		[ValidateSet("Inbound", "Outbound", "Bidirectional")]
		[String]$TrustDirection
	)

	$remoteConnection = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Forest',$RemoteForest,$RemoteAdmin,$RemotePassword)
	$remoteForestConnection = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($remoteConnection)
	$localForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
	$localForest.CreateTrustRelationship($remoteForestConnection,$TrustDirection)
}

dnscmd /zoneadd itronms.local /dsforwarder 10.51.100.11 10.51.100.12 fdfa:ffff:0:200:10:51:100:11 fdfa:ffff:0:200:10:51:100:12 /timeout 30
dnscmd /zoneChangeDirectoryPartition itronms.local /forest

$script:remforest = "itronms.local"
$script:remadmin = Read-Host -Prompt "Admin username on $script:remforest"

New-ADForestTrust -RemoteForest $script:remforest -RemoteAdmin $script:remadmin -RemotePassword ( [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((Read-Host -Prompt "Admin password on $script:remforest" -AsSecureString))) ) -TrustDirection Outbound