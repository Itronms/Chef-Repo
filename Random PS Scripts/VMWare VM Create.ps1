<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    VMWare VM Create
.SYNOPSIS
    Create VMWare VM's quickly and easily with this great GUI
.DESCRIPTION
    Create VMWare VM's quickly and easily with this great GUI
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$VMCreator                       = New-Object system.Windows.Forms.Form
$VMCreator.ClientSize            = '645,727'
$VMCreator.text                  = "VMWare VM Creator"
$VMCreator.TopMost               = $false

$VMNameTextBox                   = New-Object system.Windows.Forms.TextBox
$VMNameTextBox.multiline         = $false
$VMNameTextBox.width             = 197
$VMNameTextBox.height            = 20
$VMNameTextBox.location          = New-Object System.Drawing.Point(126,238)
$VMNameTextBox.Font              = 'Microsoft Sans Serif,10'

$VMNameLabel                     = New-Object system.Windows.Forms.Label
$VMNameLabel.text                = "VM Name"
$VMNameLabel.AutoSize            = $true
$VMNameLabel.width               = 200
$VMNameLabel.height              = 10
$VMNameLabel.location            = New-Object System.Drawing.Point(50,241)
$VMNameLabel.Font                = 'Microsoft Sans Serif,10'

$RAMinGBTextBox                  = New-Object system.Windows.Forms.TextBox
$RAMinGBTextBox.multiline        = $false
$RAMinGBTextBox.text             = "4"
$RAMinGBTextBox.width            = 100
$RAMinGBTextBox.height           = 20
$RAMinGBTextBox.location         = New-Object System.Drawing.Point(127,328)
$RAMinGBTextBox.Font             = 'Microsoft Sans Serif,10'

$VMRAMinGBLabel                  = New-Object system.Windows.Forms.Label
$VMRAMinGBLabel.text             = "Ram In GB"
$VMRAMinGBLabel.AutoSize         = $true
$VMRAMinGBLabel.width            = 30
$VMRAMinGBLabel.height           = 10
$VMRAMinGBLabel.location         = New-Object System.Drawing.Point(44,328)
$VMRAMinGBLabel.Font             = 'Microsoft Sans Serif,10'

$CPUCountTextBox                 = New-Object system.Windows.Forms.TextBox
$CPUCountTextBox.multiline       = $false
$CPUCountTextBox.text            = "2"
$CPUCountTextBox.width           = 100
$CPUCountTextBox.height          = 20
$CPUCountTextBox.location        = New-Object System.Drawing.Point(126,299)
$CPUCountTextBox.Font            = 'Microsoft Sans Serif,10'

$CPUCountLabel                   = New-Object system.Windows.Forms.Label
$CPUCountLabel.text              = "CPU Count"
$CPUCountLabel.AutoSize          = $true
$CPUCountLabel.width             = 30
$CPUCountLabel.height            = 10
$CPUCountLabel.location          = New-Object System.Drawing.Point(43,299)
$CPUCountLabel.Font              = 'Microsoft Sans Serif,10'

$HardwareVersionComboBox         = New-Object system.Windows.Forms.ComboBox
$HardwareVersionComboBox.text    = "v8 (ESX 5.0)"
$HardwareVersionComboBox.width   = 131
$HardwareVersionComboBox.height  = 20
@('v4 (ESX 3)','v7 (ESX 4)','v8 (ESX 5.0)','v9 (ESX 5.1)','v10 (ESX 5.5)','v11 (ESX 6.0)','v13 (ESX 6.5)','v14 (ESX 6.7)') | ForEach-Object {[void] $HardwareVersionComboBox.Items.Add($_)}
$HardwareVersionComboBox.location  = New-Object System.Drawing.Point(392,338)
$HardwareVersionComboBox.Font    = 'Microsoft Sans Serif,10'

$HardwareVersionLabel            = New-Object system.Windows.Forms.Label
$HardwareVersionLabel.text       = "Hardware Version"
$HardwareVersionLabel.AutoSize   = $true
$HardwareVersionLabel.width      = 25
$HardwareVersionLabel.height     = 10
$HardwareVersionLabel.location   = New-Object System.Drawing.Point(273,342)
$HardwareVersionLabel.Font       = 'Microsoft Sans Serif,10'

$VMHostComboBox                  = New-Object system.Windows.Forms.ComboBox
$VMHostComboBox.text             = "Please connect first to populate list"
$VMHostComboBox.width            = 370
$VMHostComboBox.height           = 20
$VMHostComboBox.location         = New-Object System.Drawing.Point(250,140)
$VMHostComboBox.Font             = 'Microsoft Sans Serif,10'

$UserNameTextBox                 = New-Object system.Windows.Forms.TextBox
$UserNameTextBox.multiline       = $false
$UserNameTextBox.text            = "username@vsphere.local"
$UserNameTextBox.width           = 180
$UserNameTextBox.height          = 20
$UserNameTextBox.location        = New-Object System.Drawing.Point(100,20)
$UserNameTextBox.Font            = 'Microsoft Sans Serif,10'

$UsreNameLabel                   = New-Object system.Windows.Forms.Label
$UsreNameLabel.text              = "UserName"
$UsreNameLabel.AutoSize          = $true
$UsreNameLabel.width             = 25
$UsreNameLabel.height            = 10
$UsreNameLabel.location          = New-Object System.Drawing.Point(25,20)
$UsreNameLabel.Font              = 'Microsoft Sans Serif,10'

$PasswordLabel                   = New-Object system.Windows.Forms.Label
$PasswordLabel.text              = "Password"
$PasswordLabel.AutoSize          = $true
$PasswordLabel.width             = 25
$PasswordLabel.height            = 10
$PasswordLabel.location          = New-Object System.Drawing.Point(25,50)
$PasswordLabel.Font              = 'Microsoft Sans Serif,10'

$ServerTextBox                   = New-Object system.Windows.Forms.TextBox
$ServerTextBox.multiline         = $false
$ServerTextBox.text              = "192.168.1.11"
$ServerTextBox.width             = 238
$ServerTextBox.height            = 20
$ServerTextBox.location          = New-Object System.Drawing.Point(380,20)
$ServerTextBox.Font              = 'Microsoft Sans Serif,10'

$ServerLabel                     = New-Object system.Windows.Forms.Label
$ServerLabel.text                = "Server"
$ServerLabel.AutoSize            = $true
$ServerLabel.width               = 25
$ServerLabel.height              = 10
$ServerLabel.location            = New-Object System.Drawing.Point(317,20)
$ServerLabel.Font                = 'Microsoft Sans Serif,10'

$ConnectButton                   = New-Object system.Windows.Forms.Button
$ConnectButton.text              = "Connect to vCenter or Host"
$ConnectButton.width             = 297
$ConnectButton.height            = 32
$ConnectButton.location          = New-Object System.Drawing.Point(321,48)
$ConnectButton.Font              = 'Microsoft Sans Serif,10'

$LastResultLabel                 = New-Object system.Windows.Forms.Label
$LastResultLabel.text            = "Please Connect to Host or vCenter"
$LastResultLabel.BackColor       = "#b8e986"
$LastResultLabel.AutoSize        = $true
$LastResultLabel.width           = 450
$LastResultLabel.height          = 40
$LastResultLabel.location        = New-Object System.Drawing.Point(101,94)
$LastResultLabel.Font            = 'Microsoft Sans Serif,18'

$ResultHeadingLabel              = New-Object system.Windows.Forms.Label
$ResultHeadingLabel.text         = "Last Result"
$ResultHeadingLabel.AutoSize     = $true
$ResultHeadingLabel.width        = 25
$ResultHeadingLabel.height       = 10
$ResultHeadingLabel.location     = New-Object System.Drawing.Point(9,100)
$ResultHeadingLabel.Font         = 'Microsoft Sans Serif,10,style=Bold'

$SelectDataStoreLabel            = New-Object system.Windows.Forms.Label
$SelectDataStoreLabel.text       = "Select Datastore for VM Creation"
$SelectDataStoreLabel.AutoSize   = $true
$SelectDataStoreLabel.width      = 25
$SelectDataStoreLabel.height     = 10
$SelectDataStoreLabel.location   = New-Object System.Drawing.Point(34,170)
$SelectDataStoreLabel.Font       = 'Microsoft Sans Serif,10'

$RunChecks                       = New-Object system.Windows.Forms.Button
$RunChecks.BackColor             = "#b8e986"
$RunChecks.text                  = "Run Checks"
$RunChecks.width                 = 312
$RunChecks.height                = 75
$RunChecks.location              = New-Object System.Drawing.Point(302,409)
$RunChecks.Font                  = 'Microsoft Sans Serif,10,style=Bold'

$XLabel                          = New-Object system.Windows.Forms.Label
$XLabel.text                     = "X"
$XLabel.AutoSize                 = $true
$XLabel.width                    = 25
$XLabel.height                   = 10
$XLabel.location                 = New-Object System.Drawing.Point(209,522)
$XLabel.Font                     = 'Microsoft Sans Serif,10'

$XTextBox                        = New-Object system.Windows.Forms.TextBox
$XTextBox.multiline              = $false
$XTextBox.width                  = 50
$XTextBox.height                 = 20
$XTextBox.location               = New-Object System.Drawing.Point(229,522)
$XTextBox.Font                   = 'Microsoft Sans Serif,7'

$VLabel                          = New-Object system.Windows.Forms.Label
$VLabel.text                     = "V"
$VLabel.AutoSize                 = $true
$VLabel.width                    = 25
$VLabel.height                   = 10
$VLabel.location                 = New-Object System.Drawing.Point(209,482)
$VLabel.Font                     = 'Microsoft Sans Serif,10'

$VTextBox                        = New-Object system.Windows.Forms.TextBox
$VTextBox.multiline              = $false
$VTextBox.width                  = 50
$VTextBox.height                 = 20
$VTextBox.location               = New-Object System.Drawing.Point(229,482)
$VTextBox.Font                   = 'Microsoft Sans Serif,7'

$WLabel                          = New-Object system.Windows.Forms.Label
$WLabel.text                     = "W"
$WLabel.AutoSize                 = $true
$WLabel.width                    = 25
$WLabel.height                   = 10
$WLabel.location                 = New-Object System.Drawing.Point(209,502)
$WLabel.Font                     = 'Microsoft Sans Serif,10'

$WTextBox                        = New-Object system.Windows.Forms.TextBox
$WTextBox.multiline              = $false
$WTextBox.width                  = 50
$WTextBox.height                 = 20
$WTextBox.location               = New-Object System.Drawing.Point(229,502)
$WTextBox.Font                   = 'Microsoft Sans Serif,7'

$ULabel                          = New-Object system.Windows.Forms.Label
$ULabel.text                     = "U"
$ULabel.AutoSize                 = $true
$ULabel.width                    = 25
$ULabel.height                   = 10
$ULabel.location                 = New-Object System.Drawing.Point(209,462)
$ULabel.Font                     = 'Microsoft Sans Serif,10'

$UTextBox                        = New-Object system.Windows.Forms.TextBox
$UTextBox.multiline              = $false
$UTextBox.width                  = 50
$UTextBox.height                 = 20
$UTextBox.location               = New-Object System.Drawing.Point(229,462)
$UTextBox.Font                   = 'Microsoft Sans Serif,7'

$SLabel                          = New-Object system.Windows.Forms.Label
$SLabel.text                     = "S"
$SLabel.AutoSize                 = $true
$SLabel.width                    = 25
$SLabel.height                   = 10
$SLabel.location                 = New-Object System.Drawing.Point(209,422)
$SLabel.Font                     = 'Microsoft Sans Serif,10'

$STextBox                        = New-Object system.Windows.Forms.TextBox
$STextBox.multiline              = $false
$STextBox.width                  = 50
$STextBox.height                 = 20
$STextBox.location               = New-Object System.Drawing.Point(229,422)
$STextBox.Font                   = 'Microsoft Sans Serif,7'

$TLabel                          = New-Object system.Windows.Forms.Label
$TLabel.text                     = "T"
$TLabel.AutoSize                 = $true
$TLabel.width                    = 25
$TLabel.height                   = 10
$TLabel.location                 = New-Object System.Drawing.Point(209,442)
$TLabel.Font                     = 'Microsoft Sans Serif,10'

$TTextBox                        = New-Object system.Windows.Forms.TextBox
$TTextBox.multiline              = $false
$TTextBox.width                  = 50
$TTextBox.height                 = 20
$TTextBox.location               = New-Object System.Drawing.Point(229,442)
$TTextBox.Font                   = 'Microsoft Sans Serif,7'

$ZLabel                          = New-Object system.Windows.Forms.Label
$ZLabel.text                     = "Z"
$ZLabel.AutoSize                 = $true
$ZLabel.width                    = 25
$ZLabel.height                   = 10
$ZLabel.location                 = New-Object System.Drawing.Point(209,562)
$ZLabel.Font                     = 'Microsoft Sans Serif,10'

$ZTextBox                        = New-Object system.Windows.Forms.TextBox
$ZTextBox.multiline              = $false
$ZTextBox.width                  = 50
$ZTextBox.height                 = 20
$ZTextBox.location               = New-Object System.Drawing.Point(229,562)
$ZTextBox.Font                   = 'Microsoft Sans Serif,7'

$YLabel                          = New-Object system.Windows.Forms.Label
$YLabel.text                     = "Y"
$YLabel.AutoSize                 = $true
$YLabel.width                    = 25
$YLabel.height                   = 10
$YLabel.location                 = New-Object System.Drawing.Point(209,542)
$YLabel.Font                     = 'Microsoft Sans Serif,10'

$YTextBox                        = New-Object system.Windows.Forms.TextBox
$YTextBox.multiline              = $false
$YTextBox.width                  = 50
$YTextBox.height                 = 20
$YTextBox.location               = New-Object System.Drawing.Point(229,542)
$YTextBox.Font                   = 'Microsoft Sans Serif,7'

$HLabel                          = New-Object system.Windows.Forms.Label
$HLabel.text                     = "H"
$HLabel.AutoSize                 = $true
$HLabel.width                    = 25
$HLabel.height                   = 10
$HLabel.location                 = New-Object System.Drawing.Point(29,522)
$HLabel.Font                     = 'Microsoft Sans Serif,10'

$HTextBox                        = New-Object system.Windows.Forms.TextBox
$HTextBox.multiline              = $false
$HTextBox.width                  = 50
$HTextBox.height                 = 20
$HTextBox.location               = New-Object System.Drawing.Point(49,522)
$HTextBox.Font                   = 'Microsoft Sans Serif,7'

$FLabel                          = New-Object system.Windows.Forms.Label
$FLabel.text                     = "F"
$FLabel.AutoSize                 = $true
$FLabel.width                    = 25
$FLabel.height                   = 10
$FLabel.location                 = New-Object System.Drawing.Point(29,482)
$FLabel.Font                     = 'Microsoft Sans Serif,10'

$FTextBox                        = New-Object system.Windows.Forms.TextBox
$FTextBox.multiline              = $false
$FTextBox.width                  = 50
$FTextBox.height                 = 20
$FTextBox.location               = New-Object System.Drawing.Point(49,482)
$FTextBox.Font                   = 'Microsoft Sans Serif,7'

$GLabel                          = New-Object system.Windows.Forms.Label
$GLabel.text                     = "G"
$GLabel.AutoSize                 = $true
$GLabel.width                    = 25
$GLabel.height                   = 10
$GLabel.location                 = New-Object System.Drawing.Point(29,502)
$GLabel.Font                     = 'Microsoft Sans Serif,10'

$GTextBox                        = New-Object system.Windows.Forms.TextBox
$GTextBox.multiline              = $false
$GTextBox.width                  = 50
$GTextBox.height                 = 20
$GTextBox.location               = New-Object System.Drawing.Point(49,502)
$GTextBox.Font                   = 'Microsoft Sans Serif,7'

$ELabel                          = New-Object system.Windows.Forms.Label
$ELabel.text                     = "E"
$ELabel.AutoSize                 = $true
$ELabel.width                    = 25
$ELabel.height                   = 10
$ELabel.location                 = New-Object System.Drawing.Point(29,462)
$ELabel.Font                     = 'Microsoft Sans Serif,10'

$ETextBox                        = New-Object system.Windows.Forms.TextBox
$ETextBox.multiline              = $false
$ETextBox.width                  = 50
$ETextBox.height                 = 20
$ETextBox.location               = New-Object System.Drawing.Point(49,462)
$ETextBox.Font                   = 'Microsoft Sans Serif,7'

$CLabel                          = New-Object system.Windows.Forms.Label
$CLabel.text                     = "C"
$CLabel.AutoSize                 = $true
$CLabel.width                    = 25
$CLabel.height                   = 10
$CLabel.location                 = New-Object System.Drawing.Point(29,422)
$CLabel.Font                     = 'Microsoft Sans Serif,10'

$CTextBox                        = New-Object system.Windows.Forms.TextBox
$CTextBox.multiline              = $false
$CTextBox.text                   = "85"
$CTextBox.width                  = 50
$CTextBox.height                 = 20
$CTextBox.location               = New-Object System.Drawing.Point(49,422)
$CTextBox.Font                   = 'Microsoft Sans Serif,7'

$DLabel                          = New-Object system.Windows.Forms.Label
$DLabel.text                     = "D"
$DLabel.AutoSize                 = $true
$DLabel.width                    = 25
$DLabel.height                   = 10
$DLabel.location                 = New-Object System.Drawing.Point(29,442)
$DLabel.Font                     = 'Microsoft Sans Serif,10'

$DTextBox                        = New-Object system.Windows.Forms.TextBox
$DTextBox.multiline              = $false
$DTextBox.width                  = 50
$DTextBox.height                 = 20
$DTextBox.location               = New-Object System.Drawing.Point(49,442)
$DTextBox.Font                   = 'Microsoft Sans Serif,7'

$JLabel                          = New-Object system.Windows.Forms.Label
$JLabel.text                     = "J"
$JLabel.AutoSize                 = $true
$JLabel.width                    = 25
$JLabel.height                   = 10
$JLabel.location                 = New-Object System.Drawing.Point(29,562)
$JLabel.Font                     = 'Microsoft Sans Serif,10'

$JTextBox                        = New-Object system.Windows.Forms.TextBox
$JTextBox.multiline              = $false
$JTextBox.width                  = 50
$JTextBox.height                 = 20
$JTextBox.location               = New-Object System.Drawing.Point(49,562)
$JTextBox.Font                   = 'Microsoft Sans Serif,7'

$ILabel                          = New-Object system.Windows.Forms.Label
$ILabel.text                     = "I"
$ILabel.AutoSize                 = $true
$ILabel.width                    = 25
$ILabel.height                   = 10
$ILabel.location                 = New-Object System.Drawing.Point(29,542)
$ILabel.Font                     = 'Microsoft Sans Serif,10'

$ITextBox                        = New-Object system.Windows.Forms.TextBox
$ITextBox.multiline              = $false
$ITextBox.width                  = 50
$ITextBox.height                 = 20
$ITextBox.location               = New-Object System.Drawing.Point(49,542)
$ITextBox.Font                   = 'Microsoft Sans Serif,7'

$QLabel                          = New-Object system.Windows.Forms.Label
$QLabel.text                     = "Q"
$QLabel.AutoSize                 = $true
$QLabel.width                    = 25
$QLabel.height                   = 10
$QLabel.location                 = New-Object System.Drawing.Point(119,542)
$QLabel.Font                     = 'Microsoft Sans Serif,10'

$QTextBox                        = New-Object system.Windows.Forms.TextBox
$QTextBox.multiline              = $false
$QTextBox.width                  = 50
$QTextBox.height                 = 20
$QTextBox.location               = New-Object System.Drawing.Point(139,542)
$QTextBox.Font                   = 'Microsoft Sans Serif,7'

$OLabel                          = New-Object system.Windows.Forms.Label
$OLabel.text                     = "O"
$OLabel.AutoSize                 = $true
$OLabel.width                    = 25
$OLabel.height                   = 10
$OLabel.location                 = New-Object System.Drawing.Point(119,502)
$OLabel.Font                     = 'Microsoft Sans Serif,10'

$OTextBox                        = New-Object system.Windows.Forms.TextBox
$OTextBox.multiline              = $false
$OTextBox.width                  = 50
$OTextBox.height                 = 20
$OTextBox.location               = New-Object System.Drawing.Point(139,502)
$OTextBox.Font                   = 'Microsoft Sans Serif,7'

$PLabel                          = New-Object system.Windows.Forms.Label
$PLabel.text                     = "P"
$PLabel.AutoSize                 = $true
$PLabel.width                    = 25
$PLabel.height                   = 10
$PLabel.location                 = New-Object System.Drawing.Point(119,522)
$PLabel.Font                     = 'Microsoft Sans Serif,10'

$PTextBox                        = New-Object system.Windows.Forms.TextBox
$PTextBox.multiline              = $false
$PTextBox.width                  = 50
$PTextBox.height                 = 20
$PTextBox.location               = New-Object System.Drawing.Point(139,522)
$PTextBox.Font                   = 'Microsoft Sans Serif,7'

$MLabel                          = New-Object system.Windows.Forms.Label
$MLabel.text                     = "M"
$MLabel.AutoSize                 = $true
$MLabel.width                    = 25
$MLabel.height                   = 10
$MLabel.location                 = New-Object System.Drawing.Point(119,462)
$MLabel.Font                     = 'Microsoft Sans Serif,10'

$MTextBox                        = New-Object system.Windows.Forms.TextBox
$MTextBox.multiline              = $false
$MTextBox.width                  = 50
$MTextBox.height                 = 20
$MTextBox.location               = New-Object System.Drawing.Point(139,462)
$MTextBox.Font                   = 'Microsoft Sans Serif,7'

$KLabel                          = New-Object system.Windows.Forms.Label
$KLabel.text                     = "K"
$KLabel.AutoSize                 = $true
$KLabel.width                    = 25
$KLabel.height                   = 10
$KLabel.location                 = New-Object System.Drawing.Point(119,422)
$KLabel.Font                     = 'Microsoft Sans Serif,10'

$KTextBox                        = New-Object system.Windows.Forms.TextBox
$KTextBox.multiline              = $false
$KTextBox.width                  = 50
$KTextBox.height                 = 20
$KTextBox.location               = New-Object System.Drawing.Point(139,422)
$KTextBox.Font                   = 'Microsoft Sans Serif,7'

$LLabel                          = New-Object system.Windows.Forms.Label
$LLabel.text                     = "L"
$LLabel.AutoSize                 = $true
$LLabel.width                    = 25
$LLabel.height                   = 10
$LLabel.location                 = New-Object System.Drawing.Point(119,442)
$LLabel.Font                     = 'Microsoft Sans Serif,10'

$LTextBox                        = New-Object system.Windows.Forms.TextBox
$LTextBox.multiline              = $false
$LTextBox.width                  = 50
$LTextBox.height                 = 20
$LTextBox.location               = New-Object System.Drawing.Point(139,442)
$LTextBox.Font                   = 'Microsoft Sans Serif,7'

$NLabel                          = New-Object system.Windows.Forms.Label
$NLabel.text                     = "N"
$NLabel.AutoSize                 = $true
$NLabel.width                    = 25
$NLabel.height                   = 10
$NLabel.location                 = New-Object System.Drawing.Point(119,482)
$NLabel.Font                     = 'Microsoft Sans Serif,10'

$NTextBox                        = New-Object system.Windows.Forms.TextBox
$NTextBox.multiline              = $false
$NTextBox.width                  = 50
$NTextBox.height                 = 20
$NTextBox.location               = New-Object System.Drawing.Point(139,482)
$NTextBox.Font                   = 'Microsoft Sans Serif,7'

$RLabel                          = New-Object system.Windows.Forms.Label
$RLabel.text                     = "R"
$RLabel.AutoSize                 = $true
$RLabel.width                    = 25
$RLabel.height                   = 10
$RLabel.location                 = New-Object System.Drawing.Point(119,562)
$RLabel.Font                     = 'Microsoft Sans Serif,10'

$RTextBox                        = New-Object system.Windows.Forms.TextBox
$RTextBox.multiline              = $false
$RTextBox.width                  = 50
$RTextBox.height                 = 20
$RTextBox.location               = New-Object System.Drawing.Point(139,562)
$RTextBox.Font                   = 'Microsoft Sans Serif,7'

$CreateVMButton                  = New-Object system.Windows.Forms.Button
$CreateVMButton.BackColor        = "#b8e986"
$CreateVMButton.text             = "Create VM"
$CreateVMButton.width            = 312
$CreateVMButton.height           = 75
$CreateVMButton.location         = New-Object System.Drawing.Point(302,494)
$CreateVMButton.Font             = 'Microsoft Sans Serif,10,style=Bold'

$BootISOLabel                    = New-Object system.Windows.Forms.Label
$BootISOLabel.text               = "Boot ISO"
$BootISOLabel.AutoSize           = $true
$BootISOLabel.visible            = $true
$BootISOLabel.width              = 25
$BootISOLabel.height             = 10
$BootISOLabel.location           = New-Object System.Drawing.Point(40,374)
$BootISOLabel.Font               = 'Microsoft Sans Serif,10'

$PasswordTextBox                 = New-Object system.Windows.Forms.MaskedTextBox
$PasswordTextBox.multiline       = $false
$PasswordTextBox.width           = 180
$PasswordTextBox.height          = 20
$PasswordTextBox.location        = New-Object System.Drawing.Point(100,50)
$PasswordTextBox.Font            = 'Microsoft Sans Serif,10'

$DataStoreComboBox               = New-Object system.Windows.Forms.ComboBox
$DataStoreComboBox.text          = "Please select host above first"
$DataStoreComboBox.width         = 370
$DataStoreComboBox.height        = 20
$DataStoreComboBox.location      = New-Object System.Drawing.Point(250,170)
$DataStoreComboBox.Font          = 'Microsoft Sans Serif,10'

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Select Host for VM Creation"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(34,140)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$VMNetworkLabel                  = New-Object system.Windows.Forms.Label
$VMNetworkLabel.text             = "VM Network"
$VMNetworkLabel.AutoSize         = $true
$VMNetworkLabel.width            = 25
$VMNetworkLabel.height           = 10
$VMNetworkLabel.location         = New-Object System.Drawing.Point(305,284)
$VMNetworkLabel.Font             = 'Microsoft Sans Serif,10'

$NetworkComboBox                 = New-Object system.Windows.Forms.ComboBox
$NetworkComboBox.text            = "Please select a host first"
$NetworkComboBox.width           = 225
$NetworkComboBox.height          = 20
$NetworkComboBox.location        = New-Object System.Drawing.Point(392,281)
$NetworkComboBox.Font            = 'Microsoft Sans Serif,10'

$BootISOComboBox                 = New-Object system.Windows.Forms.ComboBox
$BootISOComboBox.width           = 279
$BootISOComboBox.height          = 20
$BootISOComboBox.location        = New-Object System.Drawing.Point(109,374)
$BootISOComboBox.Font            = 'Microsoft Sans Serif,10'

$PowerOnCheckBox                 = New-Object system.Windows.Forms.CheckBox
$PowerOnCheckBox.text            = "Power on VM after Creation?"
$PowerOnCheckBox.AutoSize        = $false
$PowerOnCheckBox.width           = 207
$PowerOnCheckBox.height          = 26
$PowerOnCheckBox.location        = New-Object System.Drawing.Point(412,376)
$PowerOnCheckBox.Font            = 'Microsoft Sans Serif,10'

$PasteButton                     = New-Object system.Windows.Forms.Button
$PasteButton.BackColor           = "#f8e71c"
$PasteButton.text                = "Paste Info From CSI - UnGrouped Report     Use Chrome Please"
$PasteButton.width               = 272
$PasteButton.height              = 53
$PasteButton.location            = New-Object System.Drawing.Point(347,203)
$PasteButton.Font                = 'Microsoft Sans Serif,10'

$OSArchitectureLabel             = New-Object system.Windows.Forms.Label
$OSArchitectureLabel.text        = "OS Architecture"
$OSArchitectureLabel.AutoSize    = $true
$OSArchitectureLabel.width       = 25
$OSArchitectureLabel.height      = 10
$OSArchitectureLabel.location    = New-Object System.Drawing.Point(21,269)
$OSArchitectureLabel.Font        = 'Microsoft Sans Serif,10'

$OSArchitectureLabelComboBox     = New-Object system.Windows.Forms.ComboBox
$OSArchitectureLabelComboBox.text  = "64Bit"
$OSArchitectureLabelComboBox.width  = 100
$OSArchitectureLabelComboBox.height  = 20
@('64Bit','32Bit') | ForEach-Object {[void] $OSArchitectureLabelComboBox.Items.Add($_)}
$OSArchitectureLabelComboBox.location  = New-Object System.Drawing.Point(126,269)
$OSArchitectureLabelComboBox.Font  = 'Microsoft Sans Serif,10'

$OSComboBox                      = New-Object system.Windows.Forms.ComboBox
$OSComboBox.text                 = "Please select a host first"
$OSComboBox.width                = 225
$OSComboBox.height               = 20
$OSComboBox.location             = New-Object System.Drawing.Point(391,310)
$OSComboBox.Font                 = 'Microsoft Sans Serif,10'

$OSLabel                         = New-Object system.Windows.Forms.Label
$OSLabel.text                    = "Operating System"
$OSLabel.AutoSize                = $true
$OSLabel.width                   = 25
$OSLabel.height                  = 10
$OSLabel.location                = New-Object System.Drawing.Point(271,313)
$OSLabel.Font                    = 'Microsoft Sans Serif,10'

$VMNamePrefixLabel               = New-Object system.Windows.Forms.Label
$VMNamePrefixLabel.text          = "VM Name Prefix"
$VMNamePrefixLabel.AutoSize      = $true
$VMNamePrefixLabel.width         = 200
$VMNamePrefixLabel.height        = 10
$VMNamePrefixLabel.location      = New-Object System.Drawing.Point(13,207)
$VMNamePrefixLabel.Font          = 'Microsoft Sans Serif,10'

$VMNamePreFixTextBox             = New-Object system.Windows.Forms.TextBox
$VMNamePreFixTextBox.multiline   = $false
$VMNamePreFixTextBox.width       = 196
$VMNamePreFixTextBox.height      = 20
$VMNamePreFixTextBox.location    = New-Object System.Drawing.Point(127,205)
$VMNamePreFixTextBox.Font        = 'Microsoft Sans Serif,10'

$DrivesToAttachInGBLabel         = New-Object system.Windows.Forms.Label
$DrivesToAttachInGBLabel.text    = "Drives To Attach In GB"
$DrivesToAttachInGBLabel.AutoSize  = $true
$DrivesToAttachInGBLabel.width   = 25
$DrivesToAttachInGBLabel.height  = 10
$DrivesToAttachInGBLabel.location  = New-Object System.Drawing.Point(95,404)
$DrivesToAttachInGBLabel.Font    = 'Microsoft Sans Serif,10'

$HostVer                         = New-Object system.Windows.Forms.Label
$HostVer.text                    = "Select Host"
$HostVer.AutoSize                = $true
$HostVer.width                   = 25
$HostVer.height                  = 10
$HostVer.location                = New-Object System.Drawing.Point(330,599)
$HostVer.Font                    = 'Microsoft Sans Serif,10'

$HostRam                         = New-Object system.Windows.Forms.Label
$HostRam.text                    = "Select Host"
$HostRam.AutoSize                = $true
$HostRam.width                   = 25
$HostRam.height                  = 10
$HostRam.location                = New-Object System.Drawing.Point(110,601)
$HostRam.Font                    = 'Microsoft Sans Serif,10'

$HostRamLabel                    = New-Object system.Windows.Forms.Label
$HostRamLabel.text               = "Host Ram"
$HostRamLabel.AutoSize           = $true
$HostRamLabel.width              = 25
$HostRamLabel.height             = 10
$HostRamLabel.location           = New-Object System.Drawing.Point(37,601)
$HostRamLabel.Font               = 'Microsoft Sans Serif,10'

$HostVerLabel                    = New-Object system.Windows.Forms.Label
$HostVerLabel.text               = "Host Version"
$HostVerLabel.AutoSize           = $true
$HostVerLabel.width              = 25
$HostVerLabel.height             = 10
$HostVerLabel.location           = New-Object System.Drawing.Point(239,599)
$HostVerLabel.Font               = 'Microsoft Sans Serif,10'

$NumCPULabel                     = New-Object system.Windows.Forms.Label
$NumCPULabel.text                = "Number of CPU"
$NumCPULabel.AutoSize            = $true
$NumCPULabel.width               = 25
$NumCPULabel.height              = 10
$NumCPULabel.location            = New-Object System.Drawing.Point(239,627)
$NumCPULabel.Font                = 'Microsoft Sans Serif,10'

$NumCPU                          = New-Object system.Windows.Forms.Label
$NumCPU.text                     = "Select Host"
$NumCPU.AutoSize                 = $true
$NumCPU.width                    = 25
$NumCPU.height                   = 10
$NumCPU.location                 = New-Object System.Drawing.Point(340,627)
$NumCPU.Font                     = 'Microsoft Sans Serif,10'

$HostModelLabel                  = New-Object system.Windows.Forms.Label
$HostModelLabel.text             = "Host Model"
$HostModelLabel.AutoSize         = $true
$HostModelLabel.width            = 25
$HostModelLabel.height           = 10
$HostModelLabel.location         = New-Object System.Drawing.Point(39,632)
$HostModelLabel.Font             = 'Microsoft Sans Serif,10'

$HostModel                       = New-Object system.Windows.Forms.Label
$HostModel.text                  = "Select Host"
$HostModel.AutoSize              = $true
$HostModel.width                 = 25
$HostModel.height                = 10
$HostModel.location              = New-Object System.Drawing.Point(129,632)
$HostModel.Font                  = 'Microsoft Sans Serif,10'

$SetCPUBasedonDrivesButton       = New-Object system.Windows.Forms.Button
$SetCPUBasedonDrivesButton.text  = "Set CPU Based on Drives"
$SetCPUBasedonDrivesButton.width  = 110
$SetCPUBasedonDrivesButton.height  = 48
$SetCPUBasedonDrivesButton.location  = New-Object System.Drawing.Point(427,593)
$SetCPUBasedonDrivesButton.Font  = 'Microsoft Sans Serif,10'

$HWVERLabel2                     = New-Object system.Windows.Forms.Label
$HWVERLabel2.text                = "HWVERLabel2"
$HWVERLabel2.AutoSize            = $true
$HWVERLabel2.width               = 25
$HWVERLabel2.height              = 10
$HWVERLabel2.location            = New-Object System.Drawing.Point(293,664)
$HWVERLabel2.Font                = 'Microsoft Sans Serif,10'

$VMCreator.controls.AddRange(@($VMNameTextBox,$VMNameLabel,$RAMinGBTextBox,$VMRAMinGBLabel,$CPUCountTextBox,$CPUCountLabel,$HardwareVersionComboBox,$HardwareVersionLabel,$VMHostComboBox,$UserNameTextBox,$UsreNameLabel,$PasswordLabel,$ServerTextBox,$ServerLabel,$ConnectButton,$LastResultLabel,$ResultHeadingLabel,$SelectDataStoreLabel,$RunChecks,$XLabel,$XTextBox,$VLabel,$VTextBox,$WLabel,$WTextBox,$ULabel,$UTextBox,$SLabel,$STextBox,$TLabel,$TTextBox,$ZLabel,$ZTextBox,$YLabel,$YTextBox,$HLabel,$HTextBox,$FLabel,$FTextBox,$GLabel,$GTextBox,$ELabel,$ETextBox,$CLabel,$CTextBox,$DLabel,$DTextBox,$JLabel,$JTextBox,$ILabel,$ITextBox,$QLabel,$QTextBox,$OLabel,$OTextBox,$PLabel,$PTextBox,$MLabel,$MTextBox,$KLabel,$KTextBox,$LLabel,$LTextBox,$NLabel,$NTextBox,$RLabel,$RTextBox,$CreateVMButton,$BootISOLabel,$PasswordTextBox,$DataStoreComboBox,$Label1,$VMNetworkLabel,$NetworkComboBox,$BootISOComboBox,$PowerOnCheckBox,$PasteButton,$OSArchitectureLabel,$OSArchitectureLabelComboBox,$OSComboBox,$OSLabel,$VMNamePrefixLabel,$VMNamePreFixTextBox,$DrivesToAttachInGBLabel,$HostVer,$HostRam,$HostRamLabel,$HostVerLabel,$NumCPULabel,$NumCPU,$HostModelLabel,$HostModel,$SetCPUBasedonDrivesButton,$HWVERLabel2))

$ConnectButton.Add_Click({ ConnectNow })
$VMHostComboBox.Add_SelectedValueChanged({ VMHostSelectChanged })
$RunChecks.Add_Click({ RunChecks $global:MaxMem })
$CPUCountTextBox.Add_TextChanged({ remove-letters })
$RAMinGBTextBox.Add_TextChanged({ remove-letters })
$VMNameTextBox.Add_TextChanged({ Remove-Characters })
$CTextBox.Add_TextChanged({ remove-letters })
$XLabel.Add_TextChanged({ remove-letters })
$ZTextBox.Add_TextChanged({ remove-letters })
$YTextBox.Add_TextChanged({ remove-letters })
$XTextBox.Add_TextChanged({ remove-letters })
$WTextBox.Add_TextChanged({ remove-letters })
$VTextBox.Add_TextChanged({ remove-letters })
$UTextBox.Add_TextChanged({ remove-letters })
$TTextBox.Add_TextChanged({ remove-letters })
$STextBox.Add_TextChanged({ remove-letters })
$RTextBox.Add_TextChanged({ remove-letters })
$QTextBox.Add_TextChanged({ remove-letters })
$PTextBox.Add_TextChanged({ remove-letters })
$OTextBox.Add_TextChanged({ remove-letters })
$NTextBox.Add_TextChanged({ remove-letters })
$MTextBox.Add_TextChanged({ remove-letters })
$LTextBox.Add_TextChanged({ remove-letters })
$KTextBox.Add_TextChanged({ remove-letters })
$JTextBox.Add_TextChanged({ remove-letters })
$ITextBox.Add_TextChanged({ remove-letters })
$HTextBox.Add_TextChanged({ remove-letters })
$GTextBox.Add_TextChanged({ remove-letters })
$ETextBox.Add_TextChanged({ remove-letters })
$DTextBox.Add_TextChanged({ remove-letters })
$FTextBox.Add_TextChanged({ remove-letters })
$CreateVMButton.Add_Click({ CreateVM })
$DataStoreComboBox.Add_SelectedValueChanged({ VMDatastoreChanged })
$BootISOComboBox.Add_SelectedValueChanged({ DVDISOSelect })
$PasteButton.Add_Click({ PasteButton_Click })
$OSArchitectureLabelComboBox.Add_SelectedValueChanged({ OSArchitectureSelect })
$NetworkComboBox.Add_SelectedValueChanged({ VMNetworkChanged })
$OSComboBox.Add_SelectedValueChanged({ OSChanged })
$SetCPUBasedonDrivesButton.Add_Click({ SetCPUBasedOnDrivesClick })

function SetCPUBasedOnDrivesClick { }
$global:MaxMem=""
$global:MaxCPU=""
$global:BootISOPath=""
$global:BootISOVer="64"
$PasswordTextBox.PasswordChar = '*'
$global:VMName=""
$global:HostSite=""
$global:vmwareguestid=""
$global:SelectedHost=""
$BootISOComboBox.Text=""


function OSChanged 
    {
    setvmwareguestid
    $OSComboBox.BackColor='white'
    }
    
function VMNetworkChanged
    {
    $NetworkComboBox.BackColor='white'
    }


function sethostsite
    {
    if($VMHostComboBox.text.StartsWith('AKL1','CurrentCultureIgnoreCase')) {$global:HostSite=AKL1}
    elseif ($VMHostComboBox.text.StartsWith('AKL3','CurrentCultureIgnoreCase')) {$global:HostSite=AKL3}
    elseif ($VMHostComboBox.text.StartsWith('AKL9','CurrentCultureIgnoreCase')) {$global:HostSite=AKL9}
    else {$global:HostSite=""}
    }
    
function SetCPUBasedOnDrivesClick
    {
    $DriveCount=0
    if ($CTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($DTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($ETextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($FTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($GTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($HTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($ITextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($JTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($KTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($LTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($MTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($NTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($OTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($PTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($QTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($RTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($STextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($TTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($UTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($VTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($WTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($XTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($YTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    if ($ZTextBox.Text -gt 0) {$DriveCount=$DriveCount+1}
    $CPUCountTextBox.Text=$DriveCount+1
    }




function setvmwareguestid
    {
    if  ($OSComboBox.text -eq "Server 2019") {$global:vmwareguestid = "windows9Server64Guest"}
    elseif  ($OSComboBox.text -eq "Server 2016") {$global:vmwareguestid = "windows9Server64Guest"}
    elseif  ($OSComboBox.text -eq "Server 2012 R2") {$global:vmwareguestid = "windows8Server64Guest"}
    elseif  ($OSComboBox.text -eq "Server 2012") {$global:vmwareguestid = "windows8Server64Guest"}
    elseif  ($OSComboBox.text -eq "Server 2008 R2") {$global:vmwareguestid = "windows7Server64Guest"}
    elseif  ($OSComboBox.text -eq "Server 2008 64Bit") {$global:vmwareguestid = "winLonghorn64Guest"}
    elseif  ($OSComboBox.text -eq "Server 2008 32Bit") {$global:vmwareguestid = "winLonghornGuest"}
    elseif  ($OSComboBox.text -eq "Windows 7 64Bit") {$global:vmwareguestid = "windows7_64Guest"}
    elseif  ($OSComboBox.text -eq "Windows 7 32Bit") {$global:vmwareguestid = "windows7Guest"}
    elseif  ($OSComboBox.text -eq "Windows 10 64Bit") {$global:vmwareguestid = "windows9_64Guest"}
    elseif  ($OSComboBox.text -eq "Windows 10 32Bit") {$global:vmwareguestid = "windows9Guest"}
    elseif  ($OSComboBox.text -eq "Server 2003 64Bit") {$global:vmwareguestid = "winNetEnterpriseGuest"}
    elseif  ($OSComboBox.text -eq "Server 2003 32Bit") {$global:vmwareguestid = "winNetEnterprise64Guest"}
    elseif  ($OSComboBox.text -eq "XP 64Bit") {$global:vmwareguestid = "winXPPro64Guest"}
    elseif  ($OSComboBox.text -eq "XP 32Bit") {$global:vmwareguestid = "winXPProGuest"}
    else {$global:vmwareguestid = "windows8Server64Guest"}
    }

function OSArchitectureSelect
{
if ($OSArchitectureLabelComboBox.Text -eq "64Bit")
    {
    if ($global:BootISOVer -eq "32" ) {$BootISOComboBox.BackColor="Pink"} else {$BootISOComboBox.BackColor="White"}    
    }    
elseif ($OSArchitectureLabelComboBox.Text -eq "32Bit")
    {
    if ($global:BootISOVer -eq "64" ) {$BootISOComboBox.BackColor="Pink"} else {$BootISOComboBox.BackColor="White"}    
    }    
}


function PasteButton_Click
{

  function Get-ClipboardText
  {
	Add-Type -AssemblyName 'PresentationCore'
	Write-Output ([System.Windows.Clipboard]::GetText())
  }
 
    
  $PasteMe = Get-ClipboardText

  $PasteMe=$PasteMe.Split("`n")

  $PasteServerName=$PasteMe[0].Replace("Server Name:  ","")
  $PasteServerCPU=$PasteMe[8]
  $PasteServerRAM=$PasteMe[12]

  $PasteServerDiskC=$PasteMe[15]
  $PasteServerDiskC=$PasteServerDiskC -replace ',',''
  if($PasteServerDiskC -gt 0) {$PasteServerDiskC=(([system.math]::round($PasteServerDiskC/10))*10)+10}
   
  $PasteServerDiskD=$PasteMe[18]
  $PasteServerDiskD=$PasteServerDiskD -replace ',',''
  if($PasteServerDiskD -gt 0) {$PasteServerDiskD=(([system.math]::round($PasteServerDiskD/10))*10)+10}
   
  $PasteServerDiskE=$PasteMe[21]
  $PasteServerDiskE=$PasteServerDiskE-replace ',',''
  if($PasteServerDiskE -gt 0) {$PasteServerDiskE=(([system.math]::round($PasteServerDiskE/10))*10)+10}
  
  $PasteServerDiskF=$PasteMe[24]
  $PasteServerDiskF=$PasteServerDiskF -replace ',',''
  if($PasteServerDiskF -gt 0) {$PasteServerDiskF=(([system.math]::round($PasteServerDiskF/10))*10)+10}
  
  $PasteServerDiskG=$PasteMe[27]
  $PasteServerDiskG=$PasteServerDiskG -replace ',',''
  if($PasteServerDiskG -gt 0) {$PasteServerDiskG=(([system.math]::round($PasteServerDiskG/10))*10)+10}
  
  $PasteServerDiskH=$PasteMe[30]
  $PasteServerDiskH=$PasteServerDiskH -replace ',',''
  if($PasteServerDiskH -gt 0) {$PasteServerDiskH=(([system.math]::round($PasteServerDiskH/10))*10)+10}
 
  $PasteServerDiskI=$PasteMe[33]
  $PasteServerDiskI=$PasteServerDiskI -replace ',',''
  if($PasteServerDiskI -gt 0) {$PasteServerDiskI=(([system.math]::round($PasteServerDiskI/10))*10)+10}
 
  $PasteServerDiskJ=$PasteMe[36]
  $PasteServerDiskJ=$PasteServerDiskJ -replace ',',''
  if($PasteServerDiskJ -gt 0) {$PasteServerDiskJ=(([system.math]::round($PasteServerDiskJ/10))*10)+10}
 
  $PasteServerDiskK=$PasteMe[39]
  $PasteServerDiskK=$PasteServerDiskK -replace ',',''
  if($PasteServerDiskK -gt 0) {$PasteServerDiskK=(([system.math]::round($PasteServerDiskK/10))*10)+10}
 
  $PasteServerDiskL=$PasteMe[42]
  $PasteServerDiskL=$PasteServerDiskL -replace ',',''
  if($PasteServerDiskL -gt 0) {$PasteServerDiskL=(([system.math]::round($PasteServerDiskL/10))*10)+10}
 
  $PasteServerDiskM=$PasteMe[45]
  $PasteServerDiskM=$PasteServerDiskM -replace ',',''
  if($PasteServerDiskM -gt 0) {$PasteServerDiskM=(([system.math]::round($PasteServerDiskM/10))*10)+10}
 
  $PasteServerDiskN=$PasteMe[48]
  $PasteServerDiskN=$PasteServerDiskN -replace ',',''
  if($PasteServerDiskN -gt 0) {$PasteServerDiskN=(([system.math]::round($PasteServerDiskN/10))*10)+10}
 
  $PasteServerDiskO=$PasteMe[51]
  $PasteServerDiskO=$PasteServerDiskO -replace ',',''
  if($PasteServerDiskO -gt 0) {$PasteServerDiskO=(([system.math]::round($PasteServerDiskO/10))*10)+10}
 
  $PasteServerDiskP=$PasteMe[54]
  $PasteServerDiskP=$PasteServerDiskP -replace ',',''
  if($PasteServerDiskP -gt 0) {$PasteServerDiskP=(([system.math]::round($PasteServerDiskP/10))*10)+10}
 
  $PasteServerDiskQ=$PasteMe[57]
  $PasteServerDiskQ=$PasteServerDiskQ -replace ',',''
  if($PasteServerDiskQ -gt 0) {$PasteServerDiskQ=(([system.math]::round($PasteServerDiskQ/10))*10)+10}
 
  $PasteServerDiskR=$PasteMe[60]
  $PasteServerDiskR=$PasteServerDiskR -replace ',',''
  if($PasteServerDiskR -gt 0) {$PasteServerDiskR=(([system.math]::round($PasteServerDiskR/10))*10)+10}
 
  $PasteServerDiskS=$PasteMe[63]
  $PasteServerDiskS=$PasteServerDiskS -replace ',',''
  if($PasteServerDiskS -gt 0) {$PasteServerDiskS=(([system.math]::round($PasteServerDiskS/10))*10)+10}
 
  $PasteServerDiskT=$PasteMe[66]
  $PasteServerDiskT=$PasteServerDiskT -replace ',',''
  if($PasteServerDiskT -gt 0) {$PasteServerDiskT=(([system.math]::round($PasteServerDiskT/10))*10)+10}
 
  $PasteServerDiskU=$PasteMe[69]
  $PasteServerDiskU=$PasteServerDiskU -replace ',',''
  if($PasteServerDiskU -gt 0) {$PasteServerDiskU=(([system.math]::round($PasteServerDiskU/10))*10)+10}
 
  $PasteServerDiskV=$PasteMe[72]
  $PasteServerDiskV=$PasteServerDiskV -replace ',',''
  if($PasteServerDiskV -gt 0) {$PasteServerDiskV=(([system.math]::round($PasteServerDiskV/10))*10)+10}
 
  $PasteServerDiskW=$PasteMe[75]
  $PasteServerDiskW=$PasteServerDiskW -replace ',',''
  if($PasteServerDiskW -gt 0) {$PasteServerDiskW=(([system.math]::round($PasteServerDiskW/10))*10)+10}
 
  $PasteServerDiskX=$PasteMe[78]
  $PasteServerDiskX=$PasteServerDiskX -replace ',',''
  if($PasteServerDiskX -gt 0) {$PasteServerDiskX=(([system.math]::round($PasteServerDiskX/10))*10)+10}
 
  $PasteServerDiskY=$PasteMe[81]
  $PasteServerDiskY=$PasteServerDiskY -replace ',',''
  if($PasteServerDiskY -gt 0) {$PasteServerDiskY=(([system.math]::round($PasteServerDiskY/10))*10)+10}
 
  $PasteServerDiskZ=$PasteMe[84]
  $PasteServerDiskZ=$PasteServerDiskK -replace ',',''
  if($PasteServerDiskZ -gt 0) {$PasteServerDiskZ=(([system.math]::round($PasteServerDiskZ/10))*10)+10}
 
$OSArchitectureLabelComboBox.Text=$PasteMe[7]+"Bit"
$BootISOComboBox.Text="CommVault 1-Touch Ver11 SP13 64Bit"

$VMNameTextBox.Text=$PasteServerName
$CPUCountTextBox.Text=$PasteServerCPU
$RAMinGBTextBox.Text=$PasteServerRAM
$CTextBox.Text=$PasteServerDiskC
$DTextBox.Text=$PasteServerDiskD
$ETextBox.Text=$PasteServerDiskE
$FTextBox.Text=$PasteServerDiskF
$GTextBox.Text=$PasteServerDiskG
$HTextBox.Text=$PasteServerDiskH
$ITextBox.Text=$PasteServerDiskI
$JTextBox.Text=$PasteServerDiskJ
$KTextBox.Text=$PasteServerDiskK
$LTextBox.Text=$PasteServerDiskL
$MTextBox.Text=$PasteServerDiskM
$NTextBox.Text=$PasteServerDiskN
$OTextBox.Text=$PasteServerDiskO
$PTextBox.Text=$PasteServerDiskP
$QTextBox.Text=$PasteServerDiskQ
$RTextBox.Text=$PasteServerDiskR
$STextBox.Text=$PasteServerDiskS
$TTextBox.Text=$PasteServerDiskT
$UTextBox.Text=$PasteServerDiskU
$VTextBox.Text=$PasteServerDiskV
$WTextBox.Text=$PasteServerDiskW
$XTextBox.Text=$PasteServerDisxX
$YTextBox.Text=$PasteServerDiskY
$ZTextBox.Text=$PasteServerDiskZ

}



#Set Tab Index Order
$UserNameTextBox.TabIndex=1
$PasswordTextBox.TabIndex=2
$ServerTextBox.TabIndex=3
$ConnectButton.TabIndex=4 
$VMHostComboBox.TabIndex=5
$DataStoreComboBox.TabIndex=6
$VMNamePreFixTextBox.TabIndex=7
$OSArchitectureLabelComboBox.TabIndex=8
$VMNameTextBox.TabIndex=20
$CPUCountTextBox.TabIndex=30
$RAMinGBTextBox.TabIndex=40
$NetworkComboBox.TabIndex=50
$OSComboBox.TabIndex=60
$HardwareVersionComboBox.TabIndex=90
$BootISOComboBox.TabIndex=100
$CTextBox.TabIndex=202 
$DTextBox.TabIndex=203 
$ETextBox.TabIndex=204 
$FTextBox.TabIndex=205 
$GTextBox.TabIndex=206 
$HTextBox.TabIndex=207 
$ITextBox.TabIndex=208 
$JTextBox.TabIndex=209 
$KTextBox.TabIndex=210 
$LTextBox.TabIndex=211 
$MTextBox.TabIndex=212 
$NTextBox.TabIndex=213 
$OTextBox.TabIndex=214 
$PTextBox.TabIndex=215 
$QTextBox.TabIndex=216 
$RTextBox.TabIndex=217 
$STextBox.TabIndex=218 
$TTextBox.TabIndex=219 
$UTextBox.TabIndex=220 
$VTextBox.TabIndex=221 
$WTextBox.TabIndex=222 
$XTextBox.TabIndex=223 
$YTextBox.TabIndex=224 
$ZTextBox.TabIndex=225 
$RunChecks.TabIndex=300
$CreateVMButton.TabIndex=310


function PopulateDVDISOList
{
    $BootISOComboBox.Items.Clear() >$null 2>&1
    $BootISOComboBox.Items.add("No ISO Attached") >$null 2>&1
    $BootISOComboBox.Items.add("CommVault 1-Touch Ver11 SP13 32Bit") >$null 2>&1
    $BootISOComboBox.Items.add("CommVault 1-Touch Ver11 SP13 64Bit") >$null 2>&1

    $BootISOComboBox.Items.add("ShadowProtect 5.2.7 32Bit") >$null 2>&1
    $BootISOComboBox.Items.add("ShadowProtect 5.2.7 64Bit") >$null 2>&1

}
PopulateDVDISOList

function DVDISOSelect
{
if ($BootISOComboBox.Text -eq "CommVault 1-Touch Ver11 SP13 32Bit")
    {
    $global:BootISOPath="[NZAKL3SREVH21-ISO Share] Backup Applications\CommVault 11\SP13\1-Touch-Windows-x86_SP13_Base.iso"
    if ($OSArchitectureLabelComboBox.Text -eq "64Bit") {$BootISOComboBox.BackColor="Pink"} Else {$BootISOComboBox.BackColor="White"}
    $global:BootISOVer=32
    }
if ($BootISOComboBox.Text -eq "CommVault 1-Touch Ver11 SP13 64Bit")
    {
    $global:BootISOPath="[NZAKL3SREVH21-ISO Share] Backup Applications\CommVault 11\SP13\1-Touch-Windows-x64_SP13_Base.iso"
    if ($OSArchitectureLabelComboBox.Text -eq "32Bit") {$BootISOComboBox.BackColor="Pink"} Else {$BootISOComboBox.BackColor="White"}
    $global:BootISOVer=64
    }

if ($BootISOComboBox.Text -eq "ShadowProtect 5.2.7 32Bit")
    {
    $global:BootISOPath="[NZAKL3SREVH21-ISO Share] Backup Applications\ShadowProtect\ShadowProtect_RE_5.2.7_32bit_Inc_vmxnet_drivers.iso"
    if ($OSArchitectureLabelComboBox.Text -eq "64Bit") {$BootISOComboBox.BackColor="Pink"} Else {$BootISOComboBox.BackColor="White"}
    $global:BootISOVer=32
    }
if ($BootISOComboBox.Text -eq "ShadowProtect 5.2.7 64Bit")
    {
    $global:BootISOPath="[NZAKL3SREVH21-ISO Share] Backup Applications\ShadowProtect\ShadowProtect_RE_5.2.7_64bit_Inc_vmxnet_drivers.iso"
    if ($OSArchitectureLabelComboBox.Text -eq "32Bit") {$BootISOComboBox.BackColor="Pink"} Else {$BootISOComboBox.BackColor="White"}
    $global:BootISOVer=64
    }
}

DVDISOSelect

function CreateVM
{
  $global:VMName=$VMNamePrefixTextBox.Text+$VMNameTextBox.Text
  if ($LastResultLabel.Text -eq "Good to go :)")
  {
  $LastResultLabel.text = "VM Creation Process Started - Please Wait"
  $LastResultLabel.BackColor='LightBlue'
  $VMCrateFailed=$False

$HWVERLabel2.Name=$HWVER
pause
$HWVER=$HardwareVersionComboBox.Name
$HWVERLabel2.Name=$HWVER
pause
$HWVER=$HWVER.Split(' ')
$HWVERLabel2.Name=$HWVER
pause
$HWVER=$HWVER[0]
$HWVERLabel2.Name=$HWVER
pause

  try
    {
    New-VM -name $global:VMName -VMHost $VMHostComboBox.Text -CD -MemoryGB $RAMinGBTextBox.text -NumCPU  $CPUCountTextBox.Text -Version $HWVER -DiskGB $CTextBox.Text -DiskStorageFormat Thin -Datastore $DataStoreComboBox.Text.Substring(0,$DataStoreComboBox.Text.IndexOf(" --")) -NetworkName $NetworkComboBox.Text -GuestId $global:vmwareguestid
    }
  catch
    {
    write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    [System.Windows.MessageBox]::Show($_.Exception.Message)
    $VMCrateFailed=$True
     $LastResultLabel.text = "VM " + $global:VMName + " Failed to Create :("
     $LastResultLabel.BackColor='pink'
    }
  if ( $VMCrateFailed -eq $False)
        {
        if ([int64]$DTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $DTextBox.Text -StorageFormat Thin}
        if ([int64]$ETextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $ETextBox.Text -StorageFormat Thin}
        if ([int64]$FTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $FTextBox.Text -StorageFormat Thin}
        if ([int64]$GTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $GTextBox.Text -StorageFormat Thin}
        if ([int64]$HTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $HTextBox.Text -StorageFormat Thin}
        if ([int64]$ITextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $ITextBox.Text -StorageFormat Thin}
        if ([int64]$JTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $JTextBox.Text -StorageFormat Thin}
        if ([int64]$KTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $KTextBox.Text -StorageFormat Thin}
        if ([int64]$LTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $LTextBox.Text -StorageFormat Thin}
        if ([int64]$MTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $MTextBox.Text -StorageFormat Thin}
        if ([int64]$NTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $NTextBox.Text -StorageFormat Thin}
        if ([int64]$OTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $OTextBox.Text -StorageFormat Thin}
        if ([int64]$PTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $PTextBox.Text -StorageFormat Thin}
        if ([int64]$QTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $QTextBox.Text -StorageFormat Thin}
        if ([int64]$RTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $RTextBox.Text -StorageFormat Thin}
        if ([int64]$STextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $STextBox.Text -StorageFormat Thin}
        if ([int64]$TTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $TTextBox.Text -StorageFormat Thin}
        if ([int64]$UTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $UTextBox.Text -StorageFormat Thin}
        if ([int64]$VTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $VTextBox.Text -StorageFormat Thin}
        if ([int64]$WTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $WTextBox.Text -StorageFormat Thin}
        if ([int64]$XTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $XTextBox.Text -StorageFormat Thin}
        if ([int64]$YTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $YTextBox.Text -StorageFormat Thin}
        if ([int64]$ZTextBox.Text -gt 0) {New-HardDisk -VM $global:VMName -CapacityGB $ZTextBox.Text -StorageFormat Thin}
        get-vm $global:VMName | get-ScsiController | set-ScsiController -Type VirtualLsiLogicSAS
        get-vm $global:VMName | get-CDDrive | set-CDDrive -ISOPath $global:BootISOPath -StartConnected:$True -Confirm:$false
        get-vm $global:VMName | get-NetworkAdapter | Set-NetworkAdapter -Type Vmxnet3 -Confirm:$false
        
if ($global:vmwareguestid -eq "windows7Server64Guest" -or
    $global:vmwareguestid -eq "windows7ServerGuest" -or
    $global:vmwareguestid -eq "winLonghorn64Guest" -or
    $global:vmwareguestid -eq "winLonghornGuest" -or
    $global:vmwareguestid -eq "windows7_64Guest" -or
    $global:vmwareguestid -eq "windows7Guest" -or
    $global:vmwareguestid -eq "winNetEnterpriseGuest" -or
    $global:vmwareguestid -eq "winNetEnterprise64Guest" -or
    $global:vmwareguestid -eq "winXPPro64Guest" -or
    $global:vmwareguestid -eq "winXPProGuest")
  {
  if ($CPUCountTextBox.Text -eq 1) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 2) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 3) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 4) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 5) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 6) {$SocketToUse=2}
  elseif ($CPUCountTextBox.Text -eq 7) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 8) {$SocketToUse=2}
  elseif ($CPUCountTextBox.Text -eq 9) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 10) {$SocketToUse=2}
  elseif ($CPUCountTextBox.Text -eq 11) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 12) {$SocketToUse=2}
  elseif ($CPUCountTextBox.Text -eq 13) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 14) {$SocketToUse=2}
  elseif ($CPUCountTextBox.Text -eq 15) {$SocketToUse=3}
  elseif ($CPUCountTextBox.Text -eq 16) {$SocketToUse=4}
  elseif ($CPUCountTextBox.Text -eq 17) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 18) {$SocketToUse=3}
  elseif ($CPUCountTextBox.Text -eq 19) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 20) {$SocketToUse=4}
  elseif ($CPUCountTextBox.Text -eq 22) {$SocketToUse=2}
  elseif ($CPUCountTextBox.Text -eq 23) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 24) {$SocketToUse=4}
  elseif ($CPUCountTextBox.Text -eq 25) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 27) {$SocketToUse=3}
  elseif ($CPUCountTextBox.Text -eq 28) {$SocketToUse=2}
  elseif ($CPUCountTextBox.Text -eq 29) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 30) {$SocketToUse=3}
  elseif ($CPUCountTextBox.Text -eq 31) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 32) {$SocketToUse=4}
  elseif ($CPUCountTextBox.Text -eq 33) {$SocketToUse=3}
  elseif ($CPUCountTextBox.Text -eq 34) {$SocketToUse=2}
  elseif ($CPUCountTextBox.Text -eq 35) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 36) {$SocketToUse=4}
  elseif ($CPUCountTextBox.Text -eq 37) {$SocketToUse=1}
  elseif ($CPUCountTextBox.Text -eq 38) {$SocketToUse=2}
  elseif ($CPUCountTextBox.Text -eq 39) {$SocketToUse=3}
  elseif ($CPUCountTextBox.Text -eq 40) {$SocketToUse=4}
  else   {$SocketToUse=1}
  $CPS=$CPUCountTextBox.Text/$SocketToUse
  $VMCPUCHANGE=Get-VM -Name $global:VMName
  $VMSpec=New-Object –Type VMware.Vim.VirtualMAchineConfigSpec –Property @{“NumCoresPerSocket” = $CPS}
  $VMCPUCHANGE.ExtensionData.ReconfigVM_Task($VMSpec)
  }
  
$LastResultLabel.text = "VM " + $global:VMName + " created OK :)" ; $LastResultLabel.BackColor="#b8e986"  
        
        
        
        if ($PowerOnCheckBox.Checked -eq $True) {Start-VM $global:VMName}
     }
  }
}


function RunChecks 
{
    #Prepare for checks
    SetMaxSettings
    $global:VMName=$VMNamePreFixTextBox.Text + $VMNameTextBox.Text
    if ($VMNameTextBox.TextLength -ne 0) {$VMExists = Get-VM -name $global:VMName -ErrorAction SilentlyContinue}
    
    #Run Checks
    if ($VMNameTextBox.TextLength -eq 0) {$LastResultLabel.Text = "Please Enter a VM Name" ; $LastResultLabel.BackColor='pink' }
    elseif ($VMHostComboBox.Text -eq "Please connect first to populate list")  {$LastResultLabel.Text = "Please Connect to vCenter of Host" ; $LastResultLabel.BackColor='pink' }
    elseif ($VMExists) {$LastResultLabel.text = "VM with that name already exists" ; $LastResultLabel.BackColor='pink'}
    elseif ($DataStoreComboBox.Text -eq "Please select a Datastore") {$LastResultLabel.Text = "Please select a Datastore"}
    elseif ($NetworkComboBox.Text -eq "") {$LastResultLabel.Text = "Please Select a VM Network"}
    elseif ($NetworkComboBox.Text -eq "Please select a VM Network")  {$LastResultLabel.Text = "Please Select a VM Network"}
    else {$LastResultLabel.Text = "Good to go :)" ; $LastResultLabel.BackColor= "#b8e986" }
}


function VMHostSelectChanged
{
    $VMHostComboBox.BackColor='white'
    PopulateDataStoreList

    $NetworkComboBox.Items.Clear()
    PopulateNetworkList
    $NetworkComboBox.BackColor='pink'
    sethostsite
    $global:SelectedHost=get-vmhost $VMHostComboBox.Text
    $OSComboBox.Text="Please Select a OS"
    $OSComboBox.BackColor='pink'
    PopulateOSList
    $HostRam.Text = [math]::Round($global:SelectedHost.MemoryTotalGB)
    $HostVer.Text = $global:SelectedHost.Version
    $HostModel.Text = $global:SelectedHost.Model
}

function VMDatastoreChanged
{
    $DatastoreComboBox.BackColor='white'
}

function SetMaxSettings ()
{
if ($HardwareVersionComboBox.text -eq "v4")
    {
    $global:MaxMem=64
    $global:MaxCPU=4 
    }
elseif ($HardwareVersionComboBox.text -eq "v7")
    {
    $global:MaxMem=255
    $global:MaxCPU=8
    }
elseif ($HardwareVersionComboBox.text -eq "v8") 
    {
    $global:MaxMem=1011
    $global:MaxCPU=32
    }
elseif ($HardwareVersionComboBox.text -eq "v9")
    {
    $global:MaxMem=1011
    $global:MaxCPU=64
    }
elseif ($HardwareVersionComboBox.text -eq "v10")
    {
    $global:MaxMem=1011
    $global:MaxCPU=64
    }
elseif ($HardwareVersionComboBox.text -eq "v11")
    {
    $global:MaxMem=4080
    $global:MaxCPU=128
    }
elseif ($HardwareVersionComboBox.text -eq "v13")
    {
    $global:MaxMem=6128
    $global:MaxCPU=128
    }
}

function Remove-Characters
{
$VMNameTextBox.Text = $VMNameTextBox.Text -replace '[~!@#$%^&*_+{}:"<>()?/.,`;+ ]',''
$VMNamePrefixTextBox.Text = $VMNamePrefixTextBox.Text -replace '[~!@#$%^&*_+{}:"<>()?/.,`;+ ]',''
}

function remove-letters
{
$NumberOnly = $RAMinGBTextBox,$CPUCountTextBox,$CTextBox,$DTextBox,$ETextBox,$FTextBox,$GTextBox,$HTextBox,$ITextBox,$JTextBox,$KTextBox,$LTextBox,$MTextBox,$NTextBox,$OTextBox,$PTextBox,$QTextBox,$RTextBox,$STextBox,$TTextBox,$UTextBox,$VTextBox,$WTextBox,$XTextBox,$YTextBox,$ZTextBox
Foreach ($i in $NumberOnly)
    {
    # Check if Text contains any non-Digits
        if($i.Text -match '\D'){
            # If so, remove them
            $i.Text = $i.Text -replace '\D'
            # If Text still has a value, move the cursor to the end of the number
            if($i.Text.Length -gt 0){
                $i.Focus()
                $i.SelectionStart = $i.Text.Length
            }
        }
    }
}

function ConnectNow
{
$LastResultLabel.Text = "Please wait, connecting to Host or vCenter"
$ConnectVI = Connect-VIServer -Server $ServerTextBox.Text -user $UserNameTextBox.Text -password $PasswordTextBox.Text -ErrorAction SilentlyContinue -ErrorVariable Err
If ($Err.Count -gt 0)
	{
	$LastResultLabel.Text = "Incorrect user name or password"
	}
Else
    {
	$LastResultLabel.Text = "Success, connected to vCenter or Host"
	$LastResultLabel.BackColor= "#b8e986"
    $Hostlist = Get-VMHost -State Connected| sort-object | select name -Unique
    foreach($VMWHost in $HostList.Name)
        {
        $VMHostComboBox.Items.add($VMWHost)
        }
    $VMHostComboBox.Text = "Please select a host from this dropdown list"
    $VMHostComboBox.BackColor='pink'
    }
    
}

function PopulateDataStoreList
{
    $DataStoreComboBox.Items.Clear()
    $DataStores = Get-Datastore -VMHost $VMHostComboBox.Text | sort-object FreespaceGB | select Name,FreeSpaceGB,CapacityGB
    foreach($Datastore in $DataStores)
        {
        if($Datastore.Name -notlike "*ISO*")
            {
            $DataStoreComboBox.Items.add($Datastore.Name + " -- FreeGB:" + [math]::Round($Datastore.FreeSpaceGB) + " -- SizeGB:" + [math]::Round($Datastore.CapacityGB ))
            }
            
        }
    $DataStoreComboBox.BackColor='pink'
    $DataStoreComboBox.Text="Please select a Datastore"

}

function PopulateNetworkList
{
    $NetworkComboBox.Items.Clear()
    $GetNetworkList = Get-VirtualPortGroup -VMHost $VMHostComboBox.Text | Sort-Object
    $NetworkList = $GetNetworkList.Name
    
    $NetworkList = $NetworkList | where {$_ -notlike '*Kernal*'}
    $NetworkList = $NetworkList | where {$_ -notlike '*Management*'}
    $NetworkList = $NetworkList | where {$_ -notlike '*IMM*'}
    $NetworkList = $NetworkList | where {$_ -notlike '*Kernel*'}

    foreach($NetworkItem in $NetworkList)
        {
        $NetworkComboBox.Items.add($NetworkItem)
        }
    $NetworkComboBox.Text="Please select a VM Network"
}

function PopulateOSList
{
$OSComboBox.Items.Clear()
if ($global:SelectedHost.Version -eq "6.7.0") {$OSList = 'Server 2016','Server 2012 R2','Server 2012','Server 2008 R2','Server 2008 64Bit','Server 2008 32Bit','Windows 7 64Bit','Windows 7 32Bit','Windows 10 64Bit','Windows 10 32Bit','Server 2003 64Bit','Server 2003 32Bit','XP 64Bit','XP 32Bit'}
elseif ($global:SelectedHost.Version -eq "6.5.0") {$OSList = 'Server 2016','Server 2012 R2','Server 2012','Server 2008 R2','Server 2008 64Bit','Server 2008 32Bit','Windows 7 64Bit','Windows 7 32Bit','Windows 10 64Bit','Windows 10 32Bit','Server 2003 64Bit','Server 2003 32Bit','XP 64Bit','XP 32Bit'}
elseif ($global:SelectedHost.Version -eq "6.0.0") {$OSList = 'Server 2012 R2','Server 2012','Server 2008 R2','Server 2008 64Bit','Server 2008 32Bit','Windows 7 64Bit','Windows 7 32Bit','Server 2003 64Bit','Server 2003 32Bit','XP 64Bit','XP 32Bit'}

foreach($OSItem in $OSList)
        {
        $OSComboBox.Items.add($OSItem)
        }
    $OSComboBox.Text="Please select Operating System"
}


#Import VMWare Module
$VMWareImportModuleFailed=$False
try
{
Import-Module VMware.DeployAutomation -ErrorAction Stop
}
catch
{
write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
[System.Windows.MessageBox]::Show($_.Exception.Message)
write-host "Please download and install VMWare PowerCLI 6.5 or above" -ForegroundColor Red
[System.Windows.MessageBox]::Show("Please download and install VMWare PowerCLI 6.5 or above")
$VMWareImportModuleFailed=$True
Break
}
if ($VMWareImportModuleFailed -eq $False) 
    {
$PowerCLIVer=Get-PowerCLIVersion

if ($PowerCLIVer.Major -lt 6) {[System.Windows.MessageBox]::Show("Please download and install VMWare PowerCLI 6.5 or above") ; break}
    elseif ($PowerCLIVer.Major -eq 6)
    {
        if ($PowerCLIVer.Minor -lt 5) {[System.Windows.MessageBox]::Show("Please download and install VMWare PowerCLI 6.5 or above") ; break}
    }

$PowerCLISet = Set-PowerCLIConfiguration -ProxyPolicy NoProxy -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode Multiple -Scope User
    }

SetMaxSettings
setvmwareguestid


[void]$VMCreator.ShowDialog()