$creds = Get-Credential -Message 'Please Enter vCenter Credentials'

Connect-VIserver itron-p-vm-vc.itronhosting.local -Credential $creds
$DomainUser = "root"
$DomainPWord = ConvertTo-SecureString -String "cl0ckw!SE" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 
$Script =@"

!/bin/bash


# Detect Stale file handle and write output into a variable and then into a file
mounts=`df 2>&1 | grep 'Stale file handle' |awk '{print ""$2"" }' > NFS_stales.txt`
# Remove : ‘ and ’ characters from the output
sed -r -i 's/://' NFS_stales.txt && sed -r -i 's/‘//' NFS_stales.txt && sed -r -i 's/’//' NFS_stales.txt

# Not used: replace space by a new line
# stales=`cat NFS_stales.txt && sed -r -i ':a;N;$!ba;s/ /\n /g' NFS_stales.txt`

# read NFS_stales.txt output file line by line then unmount stale by stale.
#    IFS='' (or IFS=) prevents leading/trailing whitespace from being trimmed.
#    -r prevents backslash escapes from being interpreted.
#    || [[ -n $line ]] prevents the last line from being ignored if it doesn't end with a \n (since read returns a non-zero exit code when it encounters EOF).

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Unmounting due to NFS Stale file handle: $line"
    umount -fl $line
done < "NFS_stales.txt"
#EOF
"@

Invoke-VMScript -ScriptText @$Script -Scripttype Bash -VM $Name -GuestUser $DomainUser -GuestPassword $DomainPWord

