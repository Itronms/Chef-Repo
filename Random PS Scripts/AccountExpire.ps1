param($MaximumDaysLeft = 15,
      $MinimumDaysLeft = 0,
      $MaximumAge = 100,
      $Path = ".\AccountAgeReport.csv",
      $AccountAgeReport=$False,
      $testing = $True,
      $AdministratorEmail = "Your Email",
      $SMTPSERVER = "Server IP" )



## ALL USERS WITH A Expiration date AND EMAIL ##
$Users = Get-ADUser -filter {Enabled -eq $True -and Mail -like "*" -and AccountExpires -ne "9223372036854775807" -and AccountExpires -ne "0"} -Properties AccountExpires, mail, DisplayName | | Where-Object {$_.DisplayName -ne $null}

##  CREATES DAYS LEFT OBJECT WITH DAYS UNTIL ACCOUNT LOCKOUT
$Users | ForEach-Object {Add-member -InputObject $_ @{daysleft=(New-TimeSpan -End ([datetime]::FromFileTime($_.AccountExpires)))} -Force}

Function CreateMessage()
{
    param($DisplayName = "",
          $ExpirationDate,
          $DaysLeft)
    $MessageTemplate = @"
<html>
	<body style="font-family:times new roman;font-size:16">
		<p>
			<b style="font-size:18"><i><u>$DisplayName,</u></i></b>
		</p>
		<p>
			This is a friendly reminder that your Account is set to expire on <b style="color:red"><i><u>$ExpirationDate</u></i></b>. 
			If your Account is not changed in the next <b style="color:red"><i><u>$DaysLeft</u></i></b> days, your access to Itron 
			resources ( OWOC, FND, etc….) will be restricted until your Account has been reactivated.
		</p>
		<p>
			For instructions on resetting your Account Please send an email to
			CNODS@itron.com.
		</p>
		<p>
			**********************************************************************<br/>
			THIS IS A SYSTEM GENERATED EMAIL MESSAGE. PLEASE DO NOT RESPOND       <br/>
			**********************************************************************<br/>
		</p>
	</body>
</html>
"@
    return $MessageTemplate
}

Function SendEmail()
{
    param($From = "!",
          $To = "!",
          $Subject = "!",
          $HTMLMessage = "<html><body>Test</body></html>",
          $TextMessage = "",
          $SMTPServer = "",
          $AttachmentPath = "",
          $PickupDirectory = "!")
          
    $MailMessage = New-Object System.Net.Mail.MailMessage
    $SMTPClient = New-Object System.Net.Mail.SMTPClient
    
    
    $MailMessage.To.Add("$To")
    $MailMessage.From = "$From"
    $MailMessage.Subject = "$Subject"
    $MailMessage.Body = $HTMLMessage
    $MailMessage.IsBodyHTML = $true
    If($AttachmentPath -ne "")
    {
        $Attachment = New-Object System.Net.Mail.Attachment("$CurrentPath" + "\PasswordResetInstructions.docx")
        $MailMessage.Attachments.Add($Attachment)
    }
    $SMTPClient.PickupDirectoryLocation = $PickupDirectory
    $SMTPClient.DeliveryMethod = "SpecifiedPickupDirectory"
    
    $SMTPClient.Send($MailMessage)
    
}

ForEach($User in $Users)
{
If(($User.daysleft.Days -ge $MinimumDaysLeft) -and ($User.daysleft.Days -le $MaximumDaysLeft) -and ($AccountAgeReport = $false)){
        $Display = "$($user.GivenName) $($user.Surname)"
        $DaysRemaining = $User.daysleft.Days-1
        $Expiration = ([datetime]::Today).AddDays($DaysRemaining)
        $Message = CreateMessage -DisplayName $Display -ExpirationDate $($Expiration.ToShortDateString()) -DaysLeft $DaysRemaining
        if ($testing -eq $true){$Email = $AdministratorEmail}
        else {$Email = $User.mail}
        $Subject = "Reminder: You must reset your Account by $($Expiration.ToShortDateString())"
        Write-Host """$Display"", $($User.SamAccountName), $DaysRemaining"
        SendEmail -To $Email -Subject $Subject -HTMLMessage $Message -AttachmentPath $AttachmentPath
}
elseif(($user.daysleft.Days -lt 0) -and $AccountAgeReport -eq $True){
    Add-Content -Path $Path -Value """Display Name"",""Username"",""Password Age"""
    ForEach($User in $Users)
    {
        $UserName = $User.samaccountname
        $PWDAge = $user.daysleft.Days
        If($PWDAge -gt $MaximumAge)
        {
            $DisplayName = $User.displayname
            $OutputString = """$DisplayName"",""$UserName"",""$PWDAge"""
            Add-Content -Path $Path -Value $OutputString
        }
    }


}


}
