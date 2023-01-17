<powershell>
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

Write-ToLog -logData "Bucket from userdata $BucketName"
Write-ToLog -logData "Environemnt from userdata $Environment"

</powershell>