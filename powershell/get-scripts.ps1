<powershell>
function Add-AWSPowerShellModule {
      if(Test-Path -Path "C:\ProgramFiles (x86)\AWS Tools\PowerShell\AWSPowerShell.dll"){
             Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell.dll"
        }
      else{
           Import-Module AWSpowerShell
        }
}

# Does not seem to be needed when running on Windows EC2
Add-AWSPowerShellModule
try {
    powershell.exe c:\Test\udata.ps1
}
catch {
    Write-Error "Failed to add AWS Powershell module"
    Exit
}

$bucket = Test

#To get folders inside bucket
$keyPrefix = "psscripts/"
$objects = Get-S3Object - BucketName -$bucket -KeyPrefix $keyPrefix
$localPath = "C:\Test"


$objects
#loop through files
foreach ($object in $objects) {
         $filename = $object.Key
        #change script name after download completes
        foreach ($file in $fileName) {
            Write-Host $file
            $localFilePath = $file
            $localFilePath = Join-Path $localPath $file
            Write-Host $localFilePath
            Copy-S3Object -BucketName $bucket -Key $object.Key  -LocalFile $localFilePath
       }
}

</powershell>