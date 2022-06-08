$bucket = "examplebucket"
# folder inside of bucket
$objects = Get-S3Object -BucketNme $bucket -KeyPrefix "Folder1/subfolder1"
$bucket -KeyPrefix "Folder1/Subfolder1/"
# location to download scripts
$localPath = "C:LocalFileName"

# loop to loop through all files
foreach ($object in $objects) {
    $fileName = $object.Key.Substring(19)
    # changes script name after downloading
    foreach ($file in $fileName) {
        $localFileName = ("NEW" + $file)
        $localFilePath = Join-Path $localPath $localFileName 
        Copy-S3Object -BucketName $bucket -Key $object.Key -LocalFile $localFilePath
    }
}