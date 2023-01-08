Set-Location -Path "E:Scripts"
$accesskey = "dfsds"
$secret = "fdsfds"
$awsregion = "us-west-2"

Import-Module AWSPowerShell
Set-AWSCredential -AccessKey $accesskey -SecretKey $secret -StoreAs default
Set-DefaultAWSRegion -Region $awsregion

$bucketlist = Get-S3Bucket | Where-Object -FilterScript { (Get-S3BucketLocation -BucketName $_.BucketName).value -eq $awsregion }

foreach ($bucket in $bucketlist.BucketName) {
    New-Item -Name $bucket -Type Directory
    Set-Location $bucket
    $items = Get-S3Object -BucketName $bucket
    foreach ($item in $items.key) {
        Read-S3Object -BucketName $bucket -Key $item -File $item
    }
    Set-Location ".."
}