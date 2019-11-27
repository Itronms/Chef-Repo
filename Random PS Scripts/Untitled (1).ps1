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