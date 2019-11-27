# Script to create base OU and User structure in new envrinoment
# Written by Anthony Fuller (afuller) 9/27/2017
# Validated by: 
#
# V1.1 (Revised 10/5/2017)


function CreateOUIfNotExists ($ouname, $oupath) {
    try{
        [string]$local:oudn = "OU="+$ouname+","+$oupath
        Get-ADOrganizationalUnit -Identity $local:oudn | Out-Null
    } catch {
        "Creating $ouname OU"
        New-ADOrganizationalUnit $ouname -Path $oupath
    }
}
function CreateCustomerGroup($local:groupsuffix, $local:grouppath, $local:add2users) {
    [string]$local:groupname = $script:customer+$local:groupsuffix
    try {
        New-AdGroup -Name $local:groupname -Path $local:grouppath -GroupScope DomainLocal -ErrorAction SilentlyContinue
        if ($local:add2users) {$script:nestedgroups += $local:groupname}
    } catch {
        "Error creating $local:groupname"
    }
}
function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog()|Out-Null
    $OpenFileDialog.filename
}
function CreateUsersFromCSV {
    try {
        $userfile = Get-FileName "c:\"
        import-csv $userfile -UseCulture|%{
            [string]$local:uusername = $_.SAMAccountName.Trim()
            [string]$local:uoupath = $_.OU.Trim() +","+ $script:basedn
            [string]$local:uupn = $local:uusername + "@" + (Get-AdDomain | foreach { $_.DNSRoot })
            $local:usecurepass = $_.Pass.Trim() | ConvertTo-SecureString -AsPlainText -Force
            if ($_.PNE -eq 1) { [Boolean]$local:upne = $true } else { [Boolean]$local:upne = $false }
            $newuserparams = @{
                SamAccountName = $local:uusername
                Name = $_.FullName.Trim()
                GivenName = $_.First.Trim()
                Surname = $_.Last.Trim()
                DisplayName = $_.DispName.Trim()
                AccountPassword = $local:usecurepass
                PasswordNeverExpires = $local:upne
                Path = $local:uoupath
                UserPrincipalName = $local:uupn
            }

            "Creating User $local:uusername"
            $newuserparams | FT
            New-AdUser @newuserparams -PassThru | Enable-AdAccount
            $_.Groups.Split(";") | Foreach {
                $local:ugroup = $_.Trim()
                "Adding $local:uusername to Group: $local:ugroup"
                Add-AdGroupMember $local:ugroup $local:uusername -ErrorAction SilentlyContinue
            }
        }
    } catch {
            "Error creating $local:uusername :: $error[0]"
    }
}

try {
    $script:nestedgroups = @()
    [string]$script:basedn = (Get-AdDomain | foreach { $_.DistinguishedName })

    # We need some information, customer code, contact name and contact email.
    $script:customer = Read-Host -Prompt "Please enter customer code: "

    $script:contactname = Read-Host -Prompt "Please enter contact name: "
    $script:contactemail = Read-Host -Prompt "Please enter contact email: "

    $rundate = get-date -format "M-d-yyyy-hh-mm"

    Start-Transcript -Path .\"$($scriopt:customer)-$($rundate)-$($env:UserName)-deployment.txt"

    #Create Itron OU and Sub-OU's
    "Creating OU's"
    [string]$script:itronou = "OU=Itron," + $script:basedn
    CreateOUIfNotExists "Itron" $script:basedn
    CreateOUIfNotExists "Groups" $script:itronou
    CreateOUIfNotExists "Users" $script:itronou
    CreateOUIfNotExists "Service Accounts" $script:itronou


    [string]$script:custou = "OU=Customer," + $script:basedn

    # Create Customer OU
    CreateOUIfNotExists "Customer" $script:basedn

    # Create Customer Sub-OU's
    "Creating Sub-OU's"
    CreateOUIfNotExists "Users" $script:custou
    CreateOUIfNotExists "Systems" $script:custou
    CreateOUIfNotExists "Service_Accounts" $script:custou
    CreateOUIfNotExists "Applications" $script:custou
	CreateOUIfNotExists "Meters" $script:custou

    # Create Site Owner Contact
    "Creating Site-owner Contact Object"

    try {
        [string]$local:conname = $script:customer+"_Site_Owner"
        New-AdObject -type contact -Name $local:conname -Path $script:custou -DisplayName $script:contactname -OtherAttributes @{'mail'="$script:contactemail"} -ErrorAction SilentlyContinue
    } catch {}

    # Create Groups
    "Creating Base Customer Groups"
    [string]$local:usersou = "OU=Users,OU=Customer,"+$script:basedn
    [string]$local:saou = "OU=Service_Accounts,OU=Customer,"+$script:basedn
	[string]$local:metersou = "OU=Mesters,OU=Customer,"+$script:basedn
	[string]$local:Applicationsou = "OU=Applications,OU=Customer,"+$script:basedn

    CreateCustomerGroup "_Admin" $local:usersou $true
    CreateCustomerGroup "_ServiceAccount" $local:saou $false
    CreateCustomerGroup "_TS_User" $local:usersou $true
    CreateCustomerGroup "_APP_T_OWCEUI_User" $local:usersou $true
    CreateCustomerGroup "_APP_T_OWCEUI_Admin" $local:usersou $true
    CreateCustomerGroup "_DBA" $local:usersou $true
    CreateCustomerGroup "_DBU" $local:usersou $true
    CreateCustomerGroup "_Users" $local:usersou $false
	CreateCustomerGroup "_Meters" $local:metersou $false
	CreateCustomerGroup "_APP_T_ISM_Admin" $local:Applicationsou $false
	CreateCustomerGroup "_APP_T_ISM_User" $local:Applicationsou $false
	CreateCustomerGroup "_FND_Monitor_Only" $local:Applicationsou $false
	CreateCustomerGroup "_FND_Endpoint_Operator" $local:Applicationsou $false
	CreateCustomerGroup "_FND_Admin" $local:Applicationsou $false
	CreateCustomerGroup "_FND_NBAPI" $local:Applicationsou $false
	CreateCustomerGroup "_FND_Root" $local:Applicationsou $false
	CreateCustomerGroup "_FND_Router_Operator" $local:Applicationsou $false
	CreateCustomerGroup "_APP_T_IEE_Admin" $local:Applicationsou $false
	CreateCustomerGroup "_APP_T_IEE_User" $local:Applicationsou $false
    CreateCustomerGroup "_APP_T_IEECSR_User" $local:Applicationsou $false

    # Create Itron Groups
    "Creating Itron Groups"
    try {
        [string]$local:itrongou = "OU=Groups,OU=Itron,"+$script:basedn
        New-AdGroup -Name "Itron Admins" -Path $local:itrongou -GroupScope DomainLocal -ErrorAction SilentlyContinue
        New-AdGroup -Name "Itron DBA" -Path $local:itrongou -GroupScope DomainLocal -ErrorAction SilentlyContinue
        New-AdGroup -Name "Network_Admin" -Path $local:itrongou -GroupScope DomainLocal -ErrorAction SilentlyContinue
    } catch {
        "Error creating $local:groupname"
    }

    #Set Admin Members
    "Adding Itron-Admins to Customer Admin Group"
    try {
        Add-ADGroupMember $local:gradmin "Itron Admins" -ErrorAction SilentlyContinue
    } catch {
            $error[0]
    }
    #Set DBA Members
    "Adding Itron-DBA to Customer DBA Group"
    try {
        Add-ADGroupMember $local:grdba "Itron DBA" -ErrorAction SilentlyContinue
    } catch {
            $error[0]
    }
    #Set User Members
    "Set User group membership"
    try {
        $local:grusers = $script:customer+"_Users"
        Add-AdGroupMember $local:grusers $script:nestedgroups
    } catch {
            $error[0]
    }
    #Create Itron base users
    "Importing Users from CSV"
    CreateUsersFromCSV

}
catch {
    $error[0]
}
finally {
    "Script Run Completed"
    Stop-Transcript
}