
Import-module ActiveDirectory
Import-module GroupPolicy
Read-host "Please copy the GPOBackup folder to the C Drive"

$script:customer = Read-Host -Prompt "Please enter customer code: "

New-GPO -name "2012 SMB1 Disable"
New-GPO -name "Admin Hidden Files"
New-GPO -name "Background"
New-GPO -name "CUST-$script:customer"
New-GPO -name "Itronms-TPLL"
New-GPO -name "RDP End Disconnected Sessions"
New-GPO -name "Security Policy - Domain"
New-GPO -name "UAC Disable"

Import-gpo -BackupId 76A59C56-454C-4A04-AB86-9AEC3FF9DB64 -Path C:\GPOBackup\ -TargetName "2012 SMB1 Disable"
Import-gpo -BackupId 2CDF560A-D9B2-40E8-81D4-975AA5ED5FC3 -Path C:\GPOBackup\ -TargetName "Admin Hidden Files"
Import-gpo -BackupId F6AA2AF2-9A70-46CF-94E1-8F3F31603DD9 -Path C:\GPOBackup\ -TargetName "Background"
Import-gpo -BackupId C7AEBFDB-30A3-4CC0-B516-2D03CD82B866 -Path C:\GPOBackup\ -TargetName "CUST-$script:customer"
Import-gpo -BackupId 247F1631-D48C-495A-8A24-EEEC35E89FF9 -Path C:\GPOBackup\ -TargetName "Itronms-TPLL" -MigrationTable C:\GPOBackup\MigTable.migtable
Import-gpo -BackupId C45D8DB2-AE8F-4CAF-8EE7-A02C4BE95FED -Path C:\GPOBackup\ -TargetName "RDP End Disconnected Sessions"
Import-gpo -BackupId EF583E60-DFA0-45C5-88DD-B8418464642E -Path C:\GPOBackup\ -TargetName "Security Policy - Domain"
Import-gpo -BackupId B81A062B-4744-4BED-AEC1-931B5E38AC88 -Path C:\GPOBackup\ -TargetName "UAC Disable"

