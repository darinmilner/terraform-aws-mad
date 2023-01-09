# Get EC2 Instance
Get-EC2Instance

(Get-EC2Instance -InstanceId "i-instanceId").Instances
(Get-EC2Instance).Instances | FL  # Lists the instance's properties

((Get-EC2Instance).Instances).Tag  # Get instance Tags

((Get-EC2Instance).Instances).Tag |
 Where-Object -FilterScript {$_.Key -eq "Name"}   # Name key and Value

# filter for a value of a tag by its keyname
$instanceName = (((Get-EC2Instance -InstanceId "i-instanceId").Instances).Tag |
 Where-Object -FilterScript {$_.Key -eq "Name"}).Value

# Get EC2 tag keys using Get-EC2InstanceMetadata
$tagKeys = Get-EC2InstanceMetadata -Path /tags/instance
Get-EC2InstanceMetadata -Path /tags/instance/tagkeyname  # get tags values

foreach ($key in $tagsKeys) {
    $values = Get-EC2InstanceMetadata -Path /tags/instance/$key
}

Write-Host $tagKeys
Write-Host $values

# Create names for alarms
$alarmName = $instanceName + "-CPU-PEAKED"
$alarmName

# S3 commands
$remoteFiles = Get-S3Object -BucketName "bucketname" -Key "folder/file"

# Data Returned
# ETag         : "ce562e08d8098926a3862fc6e7905199"
# BucketName   : psgitbackup
# Key          : PSDropbox/.git/hooks/applypatch-msg.sample
# LastModified : 4/25/2019 11:11:11 AM
# Owner        : Amazon.S3.Model.Owner
# Size         : 478
# StorageClass : STANDARD

# Number of objects in the bucket
(Get-S3Object -BucketName "bucketname").count
# Another way to get number of objects in the bucket
$numOfRemoteFiles = $remoteFiles.Length
Write-Verbose -Message  "Found $numOfRemoteFiles files in the bucket." -Verbose

# Get all objects in the S3
Get-S3Object -BucketName "bucketname" -Delimiter "/"
