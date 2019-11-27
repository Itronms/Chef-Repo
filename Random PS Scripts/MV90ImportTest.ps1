#Pulls Date for Functions
$DateStr = (Get-Date).ToString("yyyyMMdd")

#First Function Recurse search of Source Directory. Specifies Parent Path of Import so it only takes files from directories like C:\SourceDir\Import Parameters include -Include wild card search for PDF and HHF in this case to move to reader folder on the MV90 Server
#Function Renames all files it moves with $_.Directory.Parent- (so if file was pulled from DTE\Import it appends DTE to the front of it) to ease Archiving post MV90 Import. $_.PSIContainer searches for files only.
#Uses Test-Path to make sure during the move there are no duplicate files. If there are no duplicates it immediately renames and moves the file. IF there are duplicates it will perform +=1.
function MV90Reader ($SourceDir,$DestinationDir)
{
	Get-ChildItem $SourceDir -Recurse -Include *.pdf, *.hhf | Where-Object { $_.PSIsContainer -eq $false -and $_.PSParentPath -like "*Import*"} | ForEach-Object ($_) {
		$SourceFile = $_.FullName
		$DestinationFile = $DestinationDir +  $_.Directory.Parent +  $_.extension
		if (Test-Path $DestinationFile) {
			$i = 0
            
			while (Test-Path $DestinationFile) {
				$i += 1
				$DestinationFile = $DestinationDir +  $_.Directory.Parent + $i + $_.extension
			}
		} else {
			Move-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
		}
		Move-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
	}
}

#Same as MV90Reader function but this is for .mde files.
function MV90MDE ($SourceDir,$DestinationDir)
{
	Get-ChildItem $SourceDir -Recurse -Filter *.mde | Where-Object { $_.PSIsContainer -eq $false -and $_.PSParentPath -like "*Import*" } | ForEach-Object ($_) {
		$SourceFile = $_.FullName
		$DestinationFile = $DestinationDir +  $_.Directory.Parent + $_.extension                                                    
		if (Test-Path $DestinationFile) {
			$i = 0
            $DateStr = (Get-Date).ToString("yyyyMMdd")
			while (Test-Path $DestinationFile) {
				$i += 1
				$DestinationFile = $DestinationDir +  $_.Directory.Parent + $i + $_.extension
			}
		} else {
			Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
		}
		Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
	}
}

#Works similar to the MV90 functions but this will archive the files based on the customer code names from the above files. It will search both Reader and Import folder on the source directory. It will Also rename with yyyymmd. Same exact function will
#be needed for each customer the include will be different based on customer code so adding any in the future will just be copying and pasting this function and change xxx with customer code.
function Custxxx ($SourceDir,$DestinationDir)
{
	Get-ChildItem $SourceDir -Recurse -Include *xxx* | Where-Object { $_.PSIsContainer -eq $false -and $_.PSParentPath -like "*Import*" -or $_.PSParentPath -like "*Reader*" } | ForEach-Object ($_) {
		$SourceFile = $_.FullName
		$DestinationFile = $DestinationDir + $_.BaseName + $Datestr + $_.extension
		if (Test-Path $DestinationFile) {
			$i = 0
            
			while (Test-Path $DestinationFile) {
				$i += 1
				$DestinationFile = $DestinationDir + $_.BaseName + $DateStr + $i + $_.extension
			}
		} else {
			Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
		}
		Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
	}
}

function Custyyy ($SourceDir,$DestinationDir)
{
	Get-ChildItem $SourceDir -Recurse -Include *yyy* | Where-Object { $_.PSIsContainer -eq $false -and $_.PSParentPath -like "*Import*" -or $_.PSParentPath -like "*Reader*" } | ForEach-Object ($_) {
		$SourceFile = $_.FullName
		$DestinationFile = $DestinationDir + $_.BaseName + $Datestr + $_.extension
		if (Test-Path $DestinationFile) {
			$i = 0
            
			while (Test-Path $DestinationFile) {
				$i += 1
				$DestinationFile = $DestinationDir +  $_.BaseName + $DateStr + $i + $_.extension
			}
		} else {
			Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
		}
		Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
	}
}

#This is for Generic MDE files in the export folder. You will copy this for another customer if they dont have a custom file extension and replease -Pattern with the keyword on the report. In DTE's case GRATIOT appeared in both so I went with that.
#This will search all .mde files and do a get-content saving it to a variable. If the variable is not empty it assumes its a DTE file renames it and moves it to archive. Same function will be run again but with a move-item to move it over to the FTP.
#Customers with a special file extension we will just -Filter for it and do the same thing. We have added $Archive drive to the function to do a final move to the archive after a copy is done to the export folder.

function DTEEXPORT ($SourceDir,$DestinationDir,$ArchiveDir)
{
	Get-ChildItem $SourceDir -Recurse -Include *.mde | Where-Object { $_.PSIsContainer -eq $false -and $_.PSParentPath -like "*Export*"} | ForEach-Object ($_) {
		$SourceFile = $_.FullName
        $SEL = Select-String -Path $SourceFile -Pattern "GRATIOT" 
		$DestinationFile = $DestinationDir + "DTE" + "-" + $DateStr +  $_.extension
        $ArchiveFile = $ArchiveDir + "DTE" + "-" + $DateStr +  $_.extension 

        if ($SEL -ne $null){    
		if (Test-Path $DestinationFile) {
			$i = 0 
			while (Test-Path $DestinationFile) {
				$i += 1
				$DestinationFile = $DestinationDir + "DTE" + "-" + $DateStr + $i + $_.extension
                $ArchiveFile = $ArchiveDir + "DTE" + "-" + $DateStr + $i + $_.extension
			}
		} else {
			Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
            Move-Item -Path $SourceFile -Destination $ArchiveFile -Verbose -Force
		}
		Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
        Move-Item -Path $SourceFile -Destination $ArchiveFile -Verbose -Force
       
	}
}
}

#Custom File Extension Function. Replace -include .mde with custom file extension. Replace "DTE" with customer code.

function ENELExport ($SourceDir,$DestinationDir)
{
	Get-ChildItem $SourceDir -Recurse -Include *.enel | Where-Object { $_.PSIsContainer -eq $false -and $_.PSParentPath -like "*Export*"} | ForEach-Object ($_) {
		$SourceFile = $_.FullName
		$DestinationFile = $DestinationDir + "ENEL" + "-" + $DateStr +  $_.extension
        $ArchiveFile = $ArchiveDir + "ENEL" + "-" + $DateStr +  $_.extension 
           
		if (Test-Path $DestinationFile) {
			$i = 0 
			while (Test-Path $DestinationFile) {
				$i += 1
				$DestinationFile = $DestinationDir + "ENEL" + "-" + $DateStr + $i + $_.extension
                $ArchiveFile = $ArchiveDir + "ENEL" + "-" + $DateStr + $i + $_.extension
			}
		} else {
			Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
            Move-Item -Path $SourceFile -Destination $ArchiveFile -Verbose -Force
		}
		Copy-Item -Path $SourceFile -Destination $DestinationFile -Verbose -Force
        Move-Item -Path $SourceFile -Destination $ArchiveFile -Verbose -Force
       
	}
}



#Runs the functions update Source and Destination as needed. 4>> creates the logs using the get-date variable to be emailed at a later date.
MV90Reader -SourceDir "C:\SFTP\" -DestinationDir "C:\MV90\Reader"4>>C:\Temp\ImportLog$DateStr.txt -Append 
MV90MDE -SourceDir "C:\SFTP\" -DestinationDir "C:\MV90\Import\"4>>C:\Temp\ImportLog$DateStr.txt -Append

#Waiting for MV90 to Import the files before archiving function. I suggest 30 or 45 minutes?
Start-Sleep 1800

#Customer Import Archiving functions. Add as needed.
Custxxx -SourceDir "C:\MV90\" -DestinationDir "C:\Archive\"4>>C:\Temp\ImportLog$DateStr.txt -Append 
Custyyy -SourceDir "C:\MV90\" -DestinationDir "C:\Archive\"4>>C:\Temp\ImportLog$DateStr.txt -Append 

#Customer Export functions. Add As needed. You may want export as a seperate script.
DTEEXPORT -SourceDir "C:\Temp\" -DestinationDir "C:\Test\DTE\" -ArchiveDir "C:\Test\Archive\"4>>C:\Temp\ExporttLog$DateStr.txt -Append 
XXXExport -SourceDir "C:\Temp\" -DestinationDir "C:\Test\DTE\" -ArchiveDir "C:\Test\Archive\"4>>C:\Temp\ExporttLog$DateStr.txt -Append 
