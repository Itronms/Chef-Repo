<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '776,562'
$Form.text                       = "TPLL Deployment"
$Form.TopMost                    = $false

$label                           = New-Object system.Windows.Forms.Label
$label.text                      = "Cluster:"
$label.AutoSize                  = $true
$label.width                     = 25
$label.height                    = 10
$label.location                  = New-Object System.Drawing.Point(21,58)
$label.Font                      = 'Microsoft Sans Serif,10'

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 127
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(106,20)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "VM Name:"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(19,20)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$ComboBox1                       = New-Object system.Windows.Forms.ComboBox
$ComboBox1.text                  = "Select Cluster"
$ComboBox1.width                 = 127
$ComboBox1.height                = 20
@('Production','Non Production') | ForEach-Object {[void] $ComboBox1.Items.Add($_)}
$ComboBox1.location              = New-Object System.Drawing.Point(106,58)
$ComboBox1.Font                  = 'Microsoft Sans Serif,10'

$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 127
$TextBox2.height                 = 20
$TextBox2.location               = New-Object System.Drawing.Point(106,93)
$TextBox2.Font                   = 'Microsoft Sans Serif,10'

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "IP Address:"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(19,94)
$Label2.Font                     = 'Microsoft Sans Serif,10'

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Application:"
$Label3.AutoSize                 = $true
$Label3.width                    = 127
$Label3.height                   = 20
$Label3.location                 = New-Object System.Drawing.Point(292,126)
$Label3.Font                     = 'Microsoft Sans Serif,10'

$ComboBox2                       = New-Object system.Windows.Forms.ComboBox
$ComboBox2.text                  = "Select Application"
$ComboBox2.width                 = 127
$ComboBox2.height                = 20
@('OW-APP','ISM-APP','FND-APP','FND-DB','FCS-APP','OW-DB','ISM-DB','FCS-DB','SQL-Cluster1','SQL-Cluster2') | ForEach-Object {[void] $ComboBox2.Items.Add($_)}
$ComboBox2.location              = New-Object System.Drawing.Point(370,124)
$ComboBox2.Font                  = 'Microsoft Sans Serif,10'

$ComboBox3                       = New-Object system.Windows.Forms.ComboBox
$ComboBox3.text                  = "Select Network"
$ComboBox3.width                 = 127
$ComboBox3.height                = 20
@('APP','DB','DMZ') | ForEach-Object {[void] $ComboBox3.Items.Add($_)}
$ComboBox3.location              = New-Object System.Drawing.Point(372,162)
$ComboBox3.Font                  = 'Microsoft Sans Serif,10'

$Label4                          = New-Object system.Windows.Forms.Label
$Label4.text                     = "Network:"
$Label4.AutoSize                 = $true
$Label4.width                    = 127
$Label4.height                   = 20
$Label4.location                 = New-Object System.Drawing.Point(296,163)
$Label4.Font                     = 'Microsoft Sans Serif,10'

$Label5                          = New-Object system.Windows.Forms.Label
$Label5.text                     = "Customer:"
$Label5.AutoSize                 = $true
$Label5.width                    = 127
$Label5.height                   = 20
$Label5.location                 = New-Object System.Drawing.Point(296,197)
$Label5.Font                     = 'Microsoft Sans Serif,10'

$ComboBox4                       = New-Object system.Windows.Forms.ComboBox
$ComboBox4.text                  = "Select Customer"
$ComboBox4.width                 = 127
$ComboBox4.height                = 20
@('ACR','AKRON','VECT-P','VECT-NP','TECO-P','TECO-NP','WEST-P','WEST-NP','YAZ','DTE-P','DTE-NP','SDGE-NP','SDGE-P','PGE') | ForEach-Object {[void] $ComboBox4.Items.Add($_)}
$ComboBox4.location              = New-Object System.Drawing.Point(372,196)
$ComboBox4.Font                  = 'Microsoft Sans Serif,10'

$Label6                          = New-Object system.Windows.Forms.Label
$Label6.text                     = "Ram in GB:"
$Label6.AutoSize                 = $true
$Label6.width                    = 25
$Label6.height                   = 10
$Label6.location                 = New-Object System.Drawing.Point(292,21)
$Label6.Font                     = 'Microsoft Sans Serif,10'

$Label7                          = New-Object system.Windows.Forms.Label
$Label7.text                     = "CPU Count:"
$Label7.AutoSize                 = $true
$Label7.width                    = 25
$Label7.height                   = 10
$Label7.location                 = New-Object System.Drawing.Point(292,60)
$Label7.Font                     = 'Microsoft Sans Serif,10'

$TextBox3                        = New-Object system.Windows.Forms.TextBox
$TextBox3.multiline              = $false
$TextBox3.width                  = 100
$TextBox3.height                 = 20
$TextBox3.location               = New-Object System.Drawing.Point(377,19)
$TextBox3.Font                   = 'Microsoft Sans Serif,10'

$TextBox4                        = New-Object system.Windows.Forms.TextBox
$TextBox4.multiline              = $false
$TextBox4.width                  = 100
$TextBox4.height                 = 20
$TextBox4.location               = New-Object System.Drawing.Point(377,57)
$TextBox4.Font                   = 'Microsoft Sans Serif,10'

$Mlabe                           = New-Object system.Windows.Forms.Label
$Mlabe.text                      = "Mount Image:"
$Mlabe.AutoSize                  = $true
$Mlabe.width                     = 25
$Mlabe.height                    = 10
$Mlabe.location                  = New-Object System.Drawing.Point(292,93)
$Mlabe.Font                      = 'Microsoft Sans Serif,10'

$ComboBox5                       = New-Object system.Windows.Forms.ComboBox
$ComboBox5.text                  = "Select Image"
$ComboBox5.width                 = 127
$ComboBox5.height                = 20
@('SQL 2012','SQL 2014','SQL 2017','SQL 2016','FN 4.5','Windows 2016','Windows 2012') | ForEach-Object {[void] $ComboBox5.Items.Add($_)}
$ComboBox5.location              = New-Object System.Drawing.Point(381,91)
$ComboBox5.Font                  = 'Microsoft Sans Serif,10'

$Label8                          = New-Object system.Windows.Forms.Label
$Label8.text                     = "C"
$Label8.AutoSize                 = $true
$Label8.width                    = 25
$Label8.height                   = 10
$Label8.location                 = New-Object System.Drawing.Point(27,160)
$Label8.Font                     = 'Microsoft Sans Serif,10'

$TextBox5                        = New-Object system.Windows.Forms.TextBox
$TextBox5.multiline              = $false
$TextBox5.width                  = 32
$TextBox5.height                 = 20
$TextBox5.location               = New-Object System.Drawing.Point(47,154)
$TextBox5.Font                   = 'Microsoft Sans Serif,10'

$Label9                          = New-Object system.Windows.Forms.Label
$Label9.text                     = "D"
$Label9.AutoSize                 = $true
$Label9.width                    = 25
$Label9.height                   = 10
$Label9.location                 = New-Object System.Drawing.Point(27,182)
$Label9.Font                     = 'Microsoft Sans Serif,10'

$TextBox6                        = New-Object system.Windows.Forms.TextBox
$TextBox6.multiline              = $false
$TextBox6.width                  = 32
$TextBox6.height                 = 20
$TextBox6.location               = New-Object System.Drawing.Point(47,177)
$TextBox6.Font                   = 'Microsoft Sans Serif,10'

$Label10                         = New-Object system.Windows.Forms.Label
$Label10.text                    = "Define Drive Size"
$Label10.AutoSize                = $true
$Label10.width                   = 25
$Label10.height                  = 10
$Label10.location                = New-Object System.Drawing.Point(14,128)
$Label10.Font                    = 'Microsoft Sans Serif,10,style=Bold'

$Label11                         = New-Object system.Windows.Forms.Label
$Label11.text                    = "E"
$Label11.AutoSize                = $true
$Label11.width                   = 25
$Label11.height                  = 10
$Label11.location                = New-Object System.Drawing.Point(27,205)
$Label11.Font                    = 'Microsoft Sans Serif,10'

$TextBox7                        = New-Object system.Windows.Forms.TextBox
$TextBox7.multiline              = $false
$TextBox7.width                  = 32
$TextBox7.height                 = 20
$TextBox7.location               = New-Object System.Drawing.Point(47,199)
$TextBox7.Font                   = 'Microsoft Sans Serif,10'

$TextBox8                        = New-Object system.Windows.Forms.TextBox
$TextBox8.multiline              = $false
$TextBox8.width                  = 32
$TextBox8.height                 = 20
$TextBox8.location               = New-Object System.Drawing.Point(47,222)
$TextBox8.Font                   = 'Microsoft Sans Serif,10'

$Label12                         = New-Object system.Windows.Forms.Label
$Label12.text                    = "F"
$Label12.AutoSize                = $true
$Label12.width                   = 25
$Label12.height                  = 10
$Label12.location                = New-Object System.Drawing.Point(27,227)
$Label12.Font                    = 'Microsoft Sans Serif,10'

$TextBox9                        = New-Object system.Windows.Forms.TextBox
$TextBox9.multiline              = $false
$TextBox9.width                  = 32
$TextBox9.height                 = 20
$TextBox9.location               = New-Object System.Drawing.Point(47,244)
$TextBox9.Font                   = 'Microsoft Sans Serif,10'

$TextBox10                       = New-Object system.Windows.Forms.TextBox
$TextBox10.multiline             = $false
$TextBox10.width                 = 32
$TextBox10.height                = 20
$TextBox10.location              = New-Object System.Drawing.Point(47,267)
$TextBox10.Font                  = 'Microsoft Sans Serif,10'

$TextBox11                       = New-Object system.Windows.Forms.TextBox
$TextBox11.multiline             = $false
$TextBox11.width                 = 32
$TextBox11.height                = 20
$TextBox11.location              = New-Object System.Drawing.Point(47,289)
$TextBox11.Font                  = 'Microsoft Sans Serif,10'

$TextBox12                       = New-Object system.Windows.Forms.TextBox
$TextBox12.multiline             = $false
$TextBox12.width                 = 32
$TextBox12.height                = 20
$TextBox12.location              = New-Object System.Drawing.Point(47,312)
$TextBox12.Font                  = 'Microsoft Sans Serif,10'

$Label13                         = New-Object system.Windows.Forms.Label
$Label13.text                    = "G"
$Label13.AutoSize                = $true
$Label13.width                   = 25
$Label13.height                  = 10
$Label13.location                = New-Object System.Drawing.Point(27,249)
$Label13.Font                    = 'Microsoft Sans Serif,10'

$Label14                         = New-Object system.Windows.Forms.Label
$Label14.text                    = "H"
$Label14.AutoSize                = $true
$Label14.width                   = 25
$Label14.height                  = 10
$Label14.location                = New-Object System.Drawing.Point(27,271)
$Label14.Font                    = 'Microsoft Sans Serif,10'

$Label15                         = New-Object system.Windows.Forms.Label
$Label15.text                    = "I"
$Label15.AutoSize                = $true
$Label15.width                   = 25
$Label15.height                  = 10
$Label15.location                = New-Object System.Drawing.Point(28,294)
$Label15.Font                    = 'Microsoft Sans Serif,10'

$Label16                         = New-Object system.Windows.Forms.Label
$Label16.text                    = "J"
$Label16.AutoSize                = $true
$Label16.width                   = 25
$Label16.height                  = 10
$Label16.location                = New-Object System.Drawing.Point(27,316)
$Label16.Font                    = 'Microsoft Sans Serif,10'

$Label17                         = New-Object system.Windows.Forms.Label
$Label17.text                    = "K"
$Label17.AutoSize                = $true
$Label17.width                   = 25
$Label17.height                  = 10
$Label17.location                = New-Object System.Drawing.Point(27,340)
$Label17.Font                    = 'Microsoft Sans Serif,10'

$Label18                         = New-Object system.Windows.Forms.Label
$Label18.text                    = "L"
$Label18.AutoSize                = $true
$Label18.width                   = 25
$Label18.height                  = 10
$Label18.location                = New-Object System.Drawing.Point(27,363)
$Label18.Font                    = 'Microsoft Sans Serif,10'

$Label19                         = New-Object system.Windows.Forms.Label
$Label19.text                    = "M"
$Label19.AutoSize                = $true
$Label19.width                   = 25
$Label19.height                  = 10
$Label19.location                = New-Object System.Drawing.Point(27,386)
$Label19.Font                    = 'Microsoft Sans Serif,10'

$Label20                         = New-Object system.Windows.Forms.Label
$Label20.text                    = "S"
$Label20.AutoSize                = $true
$Label20.width                   = 25
$Label20.height                  = 10
$Label20.location                = New-Object System.Drawing.Point(27,519)
$Label20.Font                    = 'Microsoft Sans Serif,10'

$Label21                         = New-Object system.Windows.Forms.Label
$Label21.text                    = "T"
$Label21.AutoSize                = $true
$Label21.width                   = 25
$Label21.height                  = 10
$Label21.location                = New-Object System.Drawing.Point(95,160)
$Label21.Font                    = 'Microsoft Sans Serif,10'

$Label22                         = New-Object system.Windows.Forms.Label
$Label22.text                    = "U"
$Label22.AutoSize                = $true
$Label22.width                   = 25
$Label22.height                  = 10
$Label22.location                = New-Object System.Drawing.Point(95,183)
$Label22.Font                    = 'Microsoft Sans Serif,10'

$Label23                         = New-Object system.Windows.Forms.Label
$Label23.text                    = "V"
$Label23.AutoSize                = $true
$Label23.width                   = 25
$Label23.height                  = 10
$Label23.location                = New-Object System.Drawing.Point(95,205)
$Label23.Font                    = 'Microsoft Sans Serif,10'

$Label24                         = New-Object system.Windows.Forms.Label
$Label24.text                    = "W"
$Label24.AutoSize                = $true
$Label24.width                   = 25
$Label24.height                  = 10
$Label24.location                = New-Object System.Drawing.Point(95,228)
$Label24.Font                    = 'Microsoft Sans Serif,10'

$TextBox13                       = New-Object system.Windows.Forms.TextBox
$TextBox13.multiline             = $false
$TextBox13.width                 = 32
$TextBox13.height                = 20
$TextBox13.location              = New-Object System.Drawing.Point(47,334)
$TextBox13.Font                  = 'Microsoft Sans Serif,10'

$TextBox14                       = New-Object system.Windows.Forms.TextBox
$TextBox14.multiline             = $false
$TextBox14.width                 = 32
$TextBox14.height                = 20
$TextBox14.location              = New-Object System.Drawing.Point(47,357)
$TextBox14.Font                  = 'Microsoft Sans Serif,10'

$TextBox15                       = New-Object system.Windows.Forms.TextBox
$TextBox15.multiline             = $false
$TextBox15.width                 = 32
$TextBox15.height                = 20
$TextBox15.location              = New-Object System.Drawing.Point(47,379)
$TextBox15.Font                  = 'Microsoft Sans Serif,10'

$TextBox16                       = New-Object system.Windows.Forms.TextBox
$TextBox16.multiline             = $false
$TextBox16.width                 = 32
$TextBox16.height                = 20
$TextBox16.location              = New-Object System.Drawing.Point(49,515)
$TextBox16.Font                  = 'Microsoft Sans Serif,10'

$TextBox17                       = New-Object system.Windows.Forms.TextBox
$TextBox17.multiline             = $false
$TextBox17.width                 = 32
$TextBox17.height                = 20
$TextBox17.location              = New-Object System.Drawing.Point(123,151)
$TextBox17.Font                  = 'Microsoft Sans Serif,10'

$TextBox18                       = New-Object system.Windows.Forms.TextBox
$TextBox18.multiline             = $false
$TextBox18.width                 = 32
$TextBox18.height                = 20
$TextBox18.location              = New-Object System.Drawing.Point(123,174)
$TextBox18.Font                  = 'Microsoft Sans Serif,10'

$TextBox19                       = New-Object system.Windows.Forms.TextBox
$TextBox19.multiline             = $false
$TextBox19.width                 = 32
$TextBox19.height                = 20
$TextBox19.location              = New-Object System.Drawing.Point(123,196)
$TextBox19.Font                  = 'Microsoft Sans Serif,10'

$TextBox20                       = New-Object system.Windows.Forms.TextBox
$TextBox20.multiline             = $false
$TextBox20.width                 = 32
$TextBox20.height                = 20
$TextBox20.location              = New-Object System.Drawing.Point(123,219)
$TextBox20.Font                  = 'Microsoft Sans Serif,10'

$Label25                         = New-Object system.Windows.Forms.Label
$Label25.text                    = "N"
$Label25.AutoSize                = $true
$Label25.width                   = 25
$Label25.height                  = 10
$Label25.location                = New-Object System.Drawing.Point(27,406)
$Label25.Font                    = 'Microsoft Sans Serif,10'

$Label26                         = New-Object system.Windows.Forms.Label
$Label26.text                    = "O"
$Label26.AutoSize                = $true
$Label26.width                   = 25
$Label26.height                  = 10
$Label26.location                = New-Object System.Drawing.Point(26,427)
$Label26.Font                    = 'Microsoft Sans Serif,10'

$Label27                         = New-Object system.Windows.Forms.Label
$Label27.text                    = "P"
$Label27.AutoSize                = $true
$Label27.width                   = 25
$Label27.height                  = 10
$Label27.location                = New-Object System.Drawing.Point(26,450)
$Label27.Font                    = 'Microsoft Sans Serif,10'

$Label28                         = New-Object system.Windows.Forms.Label
$Label28.text                    = "Q"
$Label28.AutoSize                = $true
$Label28.width                   = 25
$Label28.height                  = 10
$Label28.location                = New-Object System.Drawing.Point(26,472)
$Label28.Font                    = 'Microsoft Sans Serif,10'

$Label29                         = New-Object system.Windows.Forms.Label
$Label29.text                    = "R"
$Label29.AutoSize                = $true
$Label29.width                   = 25
$Label29.height                  = 10
$Label29.location                = New-Object System.Drawing.Point(26,495)
$Label29.Font                    = 'Microsoft Sans Serif,10'

$TextBox21                       = New-Object system.Windows.Forms.TextBox
$TextBox21.multiline             = $false
$TextBox21.width                 = 32
$TextBox21.height                = 20
$TextBox21.location              = New-Object System.Drawing.Point(49,401)
$TextBox21.Font                  = 'Microsoft Sans Serif,10'

$TextBox22                       = New-Object system.Windows.Forms.TextBox
$TextBox22.multiline             = $false
$TextBox22.width                 = 32
$TextBox22.height                = 20
$TextBox22.location              = New-Object System.Drawing.Point(49,423)
$TextBox22.Font                  = 'Microsoft Sans Serif,10'

$TextBox23                       = New-Object system.Windows.Forms.TextBox
$TextBox23.multiline             = $false
$TextBox23.width                 = 32
$TextBox23.height                = 20
$TextBox23.location              = New-Object System.Drawing.Point(49,446)
$TextBox23.Font                  = 'Microsoft Sans Serif,10'

$TextBox24                       = New-Object system.Windows.Forms.TextBox
$TextBox24.multiline             = $false
$TextBox24.width                 = 32
$TextBox24.height                = 20
$TextBox24.location              = New-Object System.Drawing.Point(49,468)
$TextBox24.Font                  = 'Microsoft Sans Serif,10'

$TextBox25                       = New-Object system.Windows.Forms.TextBox
$TextBox25.multiline             = $false
$TextBox25.width                 = 32
$TextBox25.height                = 20
$TextBox25.location              = New-Object System.Drawing.Point(49,491)
$TextBox25.Font                  = 'Microsoft Sans Serif,10'

$Label30                         = New-Object system.Windows.Forms.Label
$Label30.text                    = "X"
$Label30.AutoSize                = $true
$Label30.width                   = 25
$Label30.height                  = 10
$Label30.location                = New-Object System.Drawing.Point(95,254)
$Label30.Font                    = 'Microsoft Sans Serif,10'

$TextBox26                       = New-Object system.Windows.Forms.TextBox
$TextBox26.multiline             = $false
$TextBox26.width                 = 32
$TextBox26.height                = 20
$TextBox26.location              = New-Object System.Drawing.Point(123,242)
$TextBox26.Font                  = 'Microsoft Sans Serif,10'

$Label31                         = New-Object system.Windows.Forms.Label
$Label31.text                    = "Y"
$Label31.AutoSize                = $true
$Label31.width                   = 25
$Label31.height                  = 10
$Label31.location                = New-Object System.Drawing.Point(95,276)
$Label31.Font                    = 'Microsoft Sans Serif,10'

$TextBox27                       = New-Object system.Windows.Forms.TextBox
$TextBox27.multiline             = $false
$TextBox27.width                 = 32
$TextBox27.height                = 20
$TextBox27.location              = New-Object System.Drawing.Point(123,264)
$TextBox27.Font                  = 'Microsoft Sans Serif,10'

$Label32                         = New-Object system.Windows.Forms.Label
$Label32.text                    = "Z"
$Label32.AutoSize                = $true
$Label32.width                   = 25
$Label32.height                  = 10
$Label32.location                = New-Object System.Drawing.Point(96,293)
$Label32.Font                    = 'Microsoft Sans Serif,10'

$TextBox28                       = New-Object system.Windows.Forms.TextBox
$TextBox28.multiline             = $false
$TextBox28.width                 = 32
$TextBox28.height                = 20
$TextBox28.location              = New-Object System.Drawing.Point(123,287)
$TextBox28.Font                  = 'Microsoft Sans Serif,10'

$CheckBox1                       = New-Object system.Windows.Forms.CheckBox
$CheckBox1.AutoSize              = $false
$CheckBox1.width                 = 95
$CheckBox1.height                = 20
$CheckBox1.location              = New-Object System.Drawing.Point(293,247)
$CheckBox1.Font                  = 'Microsoft Sans Serif,10'

$Label33                         = New-Object system.Windows.Forms.Label
$Label33.text                    = "Join Domain:"
$Label33.AutoSize                = $true
$Label33.width                   = 25
$Label33.height                  = 10
$Label33.location                = New-Object System.Drawing.Point(206,249)
$Label33.Font                    = 'Microsoft Sans Serif,10'

$Label34                         = New-Object system.Windows.Forms.Label
$Label34.text                    = "Domain Name:"
$Label34.AutoSize                = $true
$Label34.width                   = 25
$Label34.height                  = 10
$Label34.location                = New-Object System.Drawing.Point(342,249)
$Label34.Font                    = 'Microsoft Sans Serif,10'

$TextBox29                       = New-Object system.Windows.Forms.TextBox
$TextBox29.multiline             = $false
$TextBox29.width                 = 128
$TextBox29.height                = 20
$TextBox29.location              = New-Object System.Drawing.Point(438,244)
$TextBox29.Font                  = 'Microsoft Sans Serif,10'

$ToolTip1                        = New-Object system.Windows.Forms.ToolTip
$ToolTip1.ToolTipTitle           = "Check the box to join the VM to a domain"
$ToolTip1.isBalloon              = $true

$ToolTip2                        = New-Object system.Windows.Forms.ToolTip
$ToolTip2.ToolTipTitle           = "Domain"

$ToolTip1.SetToolTip($CheckBox1,'Select this box to join the VM to a Domain.')
$ToolTip2.SetToolTip($TextBox29,'Enter the full domain name so XYZAMI.local')
$Form.controls.AddRange(@($label,$TextBox1,$Label1,$ComboBox1,$TextBox2,$Label2,$Label3,$ComboBox2,$ComboBox3,$Label4,$Label5,$ComboBox4,$Label6,$Label7,$TextBox3,$TextBox4,$Mlabe,$ComboBox5,$Label8,$TextBox5,$Label9,$TextBox6,$Label10,$Label11,$TextBox7,$TextBox8,$Label12,$TextBox9,$TextBox10,$TextBox11,$TextBox12,$Label13,$Label14,$Label15,$Label16,$Label17,$Label18,$Label19,$Label20,$Label21,$Label22,$Label23,$Label24,$TextBox13,$TextBox14,$TextBox15,$TextBox16,$TextBox17,$TextBox18,$TextBox19,$TextBox20,$Label25,$Label26,$Label27,$Label28,$Label29,$TextBox21,$TextBox22,$TextBox23,$TextBox24,$TextBox25,$Label30,$TextBox26,$Label31,$TextBox27,$Label32,$TextBox28,$CheckBox1,$Label33,$Label34,$TextBox29))




#Write your logic code here
<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$TPLL                            = New-Object system.Windows.Forms.Form
$TPLL.ClientSize                 = '914,620'
$TPLL.text                       = "TPLL Deployment"
$TPLL.BackColor                  = "#000000"
$TPLL.TopMost                    = $false

$Deploy                          = New-Object system.Windows.Forms.Button
$Deploy.BackColor                = "#d0021b"
$Deploy.text                     = "Deploy"
$Deploy.width                    = 60
$Deploy.height                   = 30
$Deploy.Anchor                   = 'top,bottom,left'
$Deploy.location                 = New-Object System.Drawing.Point(422,539)
$Deploy.Font                     = 'Microsoft Sans Serif,10,style=Bold'
$Deploy.ForeColor                = "#ffffff"

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.text                   = "Cluster"
$TextBox1.BackColor              = "#000000"
$TextBox1.width                  = 100
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(0,51)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'
$TextBox1.ForeColor              = "#ffffff"

$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.text                   = "Customer"
$TextBox2.BackColor              = "#000000"
$TextBox2.width                  = 100
$TextBox2.height                 = 20
$TextBox2.location               = New-Object System.Drawing.Point(1,89)
$TextBox2.Font                   = 'Microsoft Sans Serif,10'
$TextBox2.ForeColor              = "#ffffff"

$TextBox3                        = New-Object system.Windows.Forms.TextBox
$TextBox3.multiline              = $false
$TextBox3.text                   = "Application"
$TextBox3.BackColor              = "#000000"
$TextBox3.width                  = 100
$TextBox3.height                 = 20
$TextBox3.location               = New-Object System.Drawing.Point(0,127)
$TextBox3.Font                   = 'Microsoft Sans Serif,10'
$TextBox3.ForeColor              = "#ffffff"

$TextBox4                        = New-Object system.Windows.Forms.TextBox
$TextBox4.multiline              = $false
$TextBox4.text                   = "Network"
$TextBox4.BackColor              = "#000000"
$TextBox4.width                  = 100
$TextBox4.height                 = 20
$TextBox4.location               = New-Object System.Drawing.Point(1,169)
$TextBox4.Font                   = 'Microsoft Sans Serif,10'
$TextBox4.ForeColor              = "#ffffff"

$TextBox5                        = New-Object system.Windows.Forms.TextBox
$TextBox5.multiline              = $false
$TextBox5.text                   = "VM Name"
$TextBox5.BackColor              = "#000000"
$TextBox5.width                  = 100
$TextBox5.height                 = 20
$TextBox5.location               = New-Object System.Drawing.Point(0,19)
$TextBox5.Font                   = 'Microsoft Sans Serif,10'
$TextBox5.ForeColor              = "#ffffff"

$ListView1                       = New-Object system.Windows.Forms.ListView
$ListView1.BackColor             = "#000000"
$ListView1.text                  = "1"
$ListView1.width                 = 80
$ListView1.height                = 30
$ListView1.location              = New-Object System.Drawing.Point(303,22)

$ListBox1                        = New-Object system.Windows.Forms.ListBox
$ListBox1.text                   = "1 "
$ListBox1.width                  = 80
$ListBox1.height                 = 30
$ListBox1.enabled                = $true
@('1','2','3') | ForEach-Object {[void] $ListBox1.Items.Add($_)}
$ListBox1.location               = New-Object System.Drawing.Point(298,91)

$TPLL.controls.AddRange(@($Deploy,$TextBox1,$TextBox2,$TextBox3,$TextBox4,$TextBox5,$ListView1,$ListBox1))




#Write your logic code here

[void]$TPLL.ShowDialog()
[void]$Form.ShowDialog()