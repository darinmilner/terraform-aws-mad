<powershell>
Function Write-ToLog {
    Param (
        [String]$logData,
        [String]$logPath = "C:\UserdataLog.csv"
    )

    $properties = @{
        Date = (Get-Date)
        Data = $logData
    }
    Write-Host "Attempting to write to log"
    New-Object -TypeName psobject -Property $properties | Export-Csv -NoTypeInformation -Append -Path $logPath
}

Write-ToLog -logData "Bucket from userdata $BucketName"
Write-ToLog -logData "Environemnt from userdata $Environment"

Import-Module AWSPowerShell.NetCore
$instanceId = Invoke-RestMethod -UseBasicParsing -Uri "169.254.169.254/latest/meta-data/instance-id"

Write-ToLog -logData "This instance's id is $instanceId"

$tags = Get-EC2Tag -Region $region -Filter @{
    Name = "resource-id"
    Values = $instanceId
}

$tags | Export-Csv -Path "C:\EC2Tags.csv" -NoTypeInformation

#Install SSM Agent
[System.Net.ServicePointManager]::SecurityProtocol = 'TLS12'
$progressPreference = 'silentlyContinue'
Invoke-WebRequest `
    https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe `
    -OutFile $env:USERPROFILE\Desktop\SSMAgent_latest.exe

Start-Process `
    -FilePath $env:USERPROFILE\Desktop\SSMAgent_latest.exe `
    -ArgumentList "/S"

rm -Force $env:USERPROFILE\Desktop\SSMAgent_latest.exe

</powershell>