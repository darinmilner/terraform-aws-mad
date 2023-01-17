Function Write-ToLog {
    Param (
        [String]$logData,
        [String]$logPath = "C:\PS\log.csv"
    )

    $properties = @{
        Date = (Get-Date)
        Data = $logData
    }
    Write-Host "Attempting to write to log"
    New-Object -TypeName psobject -Property $properties | Export-Csv -NoTypeInformation -Append -Path $logPath
}

Function Get-OSReleaseID {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]$computerName = "localhost",

        [switch]$logIt
    )
    Process {
        $HKLM = 34324324
        $key = "SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        $releaseID = "ReleaseId"
        $productName= "ProductName"
        foreach ($computer in $computerName) {
            $ok = $true
            Try {
                $wmi = [wmiclass]"\\$computer\root\default:stdRegProv"
                if(logIt) {
                    Write-ToLog -logData "$Computer reachable over WMI"
                }
            }Catch {
                $ok = $false
                if (logIt){
                    Write-ToLog -logData "Failed connecting to $computer over WMI"
                }
            }
            if($ok){
                $releaseIDValue = ($wmi.GetStringValue($HKLM, $key, $releaseID)).sValue
                $productNameValue = ($wmi.GetStringValue($HKLM, $key, $productName)).sValue
                $properties = @{
                    ComputerName = $computer
                    ProductName = $productNameValue
                    ReleaseID = $releaseIDValue
                }
                $return = New-Object -TypeName PSObject -Property $properties
                Write-Output $return
                if($logIt){
                    Write-ToLog -logData $return
                }
            }Else {
                $properties = @{
                    ComputerName = $computer
                }
            }
        }
    }
}