 [string]$script:basedn = (Get-AdDomain | foreach { $_.DistinguishedName })
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
CreateUsersFromCSV

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');