<#
.SYNOPSIS
Copy-PhotoRecFilesbyExtension copies all files from the PhotoRec folders to new folders named by file extension.
.DESCRIPTION
Copy-PhotoRecFilesbyExtension uses the file extensions to create folders and then copy in the folder all the files founds with the same extension.
If a file with the same name is found in another folder it's renamed adding (1)...(2) and so on and then copied, to keep all the versions as default.
To keep only one version set the parameter OverWriteDuplicated to $True.
IMPORTANT: *** THIS SCRIPT IS PROVIDED WITHOUT WARRANTY, USE AT YOUR OWN RISK ***
.PARAMETER RootPhotoRec
The Root folder used by PhotoRec to store recovered files
.PARAMETER RootDestFolder
The Root folder where new folders and files will be created and copied.
.PARAMETER OverWriteDuplicated
To Overwrite any recurring file with the same name in the same destination folder. Only the last copied is keep.
By default OverWriteDuplicated is set to False.
.PARAMETER CustomFileFilter
Is possible to set a filter to reorganize only a type of file. The filter must start with a * such as *jpg
.EXAMPLE
Copy-PhotoRecFilesbyExtension -RootPhotoRecFolder G:\PhotoRec\* -RootDestinationFolder H:\PhotoOrderedbyExtension
.EXAMPLE
Copy-PhotoRecFilesbyExtension -RootPhotoRecFolder G:\PhotoRec\* -RootDestinationFolder H:\PhotoOrderedbyExtension -OverWriteDuplicated $True

Any file found in the destination folder with the same name is overwritten
.EXAMPLE
Copy-PhotoRecFilesbyExtension -RootPhotoRecFolder G:\PhotoRec\* -RootDestinationFolder H:\PhotoOrderedbyExtension -CustomFileFilter *mp3

In this example only MP3 files will be copied from the source folder to the destination. By default any file type is copied and reorganized.
.EXAMPLE
Copy-PhotoRecFilesbyExtension -RootPhotoRecFolder G:\PhotoRec\* -RootDestinationFolder H:\PhotoOrderedbyExtension -CustomFileFilter "*mp4","*avi"

In this example only MP4 and AVI files will be copied from the source folder to the destination. Enclose with double quote and separate with a comma any extension required; don't forget the *. 
.LINK
http://www.powershellacademy.it/scripts
.NOTES
Written by: Luca Conte

Find me on:
* Website:	http://lucaconte.it
* Twitter:  http://twitter.com/desmox796
* Memrise:  http://www.memrise.com/user/desmox/courses/teaching/
* MyBlog:   http://desmox796.wordpress.com

IMPORTANT: *** THIS SCRIPT IS PROVIDED WITHOUT WARRANTY, USE AT YOUR OWN RISK *** 

License:
The MIT License (MIT)

Copyright (c) 2016 Luca Conte

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#>

[CmdletBinding()]
param (
[Parameter(Mandatory=$True,HelpMessage="Enter the Source PhotoRec Source Folder")]
[String]$RootPhotoRec,
[Parameter(Mandatory=$True,HelpMessage="Enter the Destination Folder where your data will be reorganized")]
[String]$RootDestFolder,
[bool]$OverWriteDuplicated=$False,
[String[]]$CustomFileFilter="*"
)


Clear-Host
#How many PhotoRec folders have to be analyzed?
$NrFolderToAnalyze=(Get-ChildItem -Path $RootPhotoRec  -Directory).Count
# Write-Host "Found $NrFolderToAnalyze folder to Analyze!"
$FolderCounter=0

Get-ChildItem -Path $RootPhotoRec -Directory | foreach {
    $FolderSource = $_.FullName
    $FolderCounter++
    $PercProgress=[int]($FolderCounter/$NrFolderToAnalyze*100)
    Write-Progress -id 1 -Activity "Working on PhotoRec folders..." -CurrentOperation "($PercProgress%) [$FolderCounter of $NrFolderToAnalyze] Copying from $FolderSource ..." -Status "Please wait." -PercentComplete ($PercProgress) #Show folder Progress 
    

    
    # Write-Host "Found $NrFileToAnalyze files to analyze"
    $PathToAnalyze=$_.FullName

    
if (!($PathToAnalyze.EndsWith("\*"))){

    $PathToAnalyze+="\*"
}
    
    $FileCounter=0
    $FilesToAnalyze = Get-ChildItem -Path $PathToAnalyze -File -Include $CustomFileFilter
    $NrFileToAnalyze= $FilesToAnalyze.Count

    # Get-ChildItem -Path $PathToAnalyze -File -Include $CustomFileFilter 
    
    $FilesToAnalyze | foreach {
    
    
    $fileSource = $_.FullName    # G:\_photorec\recup_dir.10\f109643736.jpg

    $fileName = (Get-Item $fileSource).BaseName  #f109643736
    $fileExt = (Get-Item $fileSource).Extension  #.jpg

    $FolderDest = Join-Path -Path $RootdestFolder -ChildPath $fileExt   # G:\_PhotoRecOrg\.jpg

    $fileDest = Join-Path -Path $FolderDest -ChildPath $fileName$fileExt # G:\_PhotoRecOrg\.jpg\f109643736.jpg

    if(!(Test-Path -Path $FolderDest )) # Setup a new folder if missing
    {
        new-item -ItemType Directory -Path $FolderDest
        Write-Host #Echo 
    } 

    $trigger = $false
    $counter = 1

    if (!($OverWriteDuplicated)) {
        Do {

            If (!(Test-Path -Path $fileDest)) {  # G:\_PhotoRecOrg\.jpg\f109643736.jpg  check if a file with the same name NOT exist in the destination folder

                $trigger = $true

            } Else { # Otherwise rename the source file as (1) ... (2) and so on to keep all the versions 

                $fileNameNew = "$fileName{0}" -f "("+$counter+")" # f109643736(1)
                $fileDest = Join-Path -Path $FolderDest -ChildPath "$fileNameNew$fileExt" # G:\_PhotoRecOrg\.jpg\f109643736(1).jpg
                $counter++
            }

        } Until ($trigger)

    }

    $FileCounter++
    $PercFileProgress=[int]($FileCounter/$NrFileToAnalyze*100)
    Write-Progress -id 2 -ParentId 1 -Activity "Working on $CustomFileFilter Files (Overwrite =$OverWriteDuplicated)..." -CurrentOperation "($PercFileProgress%) [$FileCounter of $NrFileToAnalyze] - Copying file $Filename to $FolderDest" -Status "Please wait." -PercentComplete ($PercFileProgress) # progress of the file copy
    
    Copy-Item -Path $fileSource -Destination $fileDest # Copy
}

}
 

