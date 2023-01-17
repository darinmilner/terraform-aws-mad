<powershell>

$accesskey = "dfsds"
$secret = "fdsfds"
$awsregion = "us-west-2"

Import-Module AWSPowerShell
# Set-AWSCredential -AccessKey $accesskey -SecretKey $secret -StoreAs default
Set-DefaultAWSRegion -Region $awsregion

Function Write-ToLog {
  Param (
      [String]$logData,
      [String]$logPath = "C:userdata-log.csv"
  )

  $properties = @{
      Date = (Get-Date)
      Data = $logData
  }
  Write-Host "Attempting to write to log"
  New-Object -TypeName psobject -Property $properties | Export-Csv -NoTypeInformation -Append -Path $logPath
}

function Get-BucketName {
    $instanceId =  Get-EC2InstanceMetadata -Category InstanceId
    $bucketNameTag = ((Get-EC2Instance -InstanceId $instanceId).Instances).Tag |
        Where-Object -FilterScript {$_.Key -eq "Bucket-Name"}

    # Gets the bucket name from the tag
    $bucketName = $bucketNameTag.value
    return $bucketName
}

Write-ToLog -logData "Bucket from userdata $BucketName"
Write-ToLog -logData "Environemnt from userdata $Environment"

$bucket = Get-BucketName
Write-Host $bucket

#To get folders inside bucket
$keyPrefix = "psscript/"
# $objects = Get-S3Object -BucketName $bucket -KeyPrefix $keyPrefix
# $localPath = "C:\Test"


# $objects
# #loop through files
# foreach ($object in $objects) {
#         $filename = $object.Key -replace $keyPrefix, ""
#         #change script name after download completes
#         foreach ($file in $fileName) {
#             Write-Host $file
#             $localFilePath = $file
#             $localFilePath = Join-Path $localPath $file
#             Write-Host $localFilePath
#             Copy-S3Object -BucketName $bucket -Key $object.Key  -LocalFile $localFilePath

#             if ($file -like "*win*" -or $file -like "postman") {
#                 # Check if file contains the string win or postman and then unzips it
#                 Expand-Archive "C:\Path-to-ZipFile.zip" -DestinationPath "Path-to-UnZipFile"  #unzip file
#             }
#         }
# }

function Add-AWSPowerShellModule {
    if(Test-Path -Path "C:\ProgramFiles (x86)\AWS Tools\PowerShell\AWSPowerShell.dll"){
           Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell.dll"
      }
    else{
         Import-Module AWSpowerShell
      }
}

Add-AWSPowerShellModule
try {
  powershell.exe c:\Test\userdata.ps1
}
catch {
  Write-Error "Failed to add AWS Powershell module"
  Exit
}

</powershell>