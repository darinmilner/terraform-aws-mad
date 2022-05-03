function rebootSystem {
    param(
        [Parameter(Mandatory)]$Computer, 
        [Parameter(Mandatory)]$userCreds 
    )
    try {
        Restart-Computer -Credential $userCreds -ComputerName $Computer -Wait -Force -ErrorAction Stop 
        $props = [ordered]@{
            name = $Computer 
            result = "Success"
        }
    }
    catch {
        $props = [ordered]@{
            name = $Computer
            result = "Faied $($_.exception.message)"
        }
    }

    return (new-object psobject -property $props)
}

$CWD = Split-Path -parent $MyInvocation.MyCommand.Definition  # current dir of script
$Computers = Get-Content "$CWD\servers.txt"
$domainCreds = Get-Credential 

foreach ($Computer in $Computers) {
    <# $Computer is the current item #>
    Write-Output "Starting Reboot on $Computer"
    start-job -ScriptBlock ${function:rebootSystem} -ArgumentList $Computer,$domainCreds | Out-Null
}

while (get-job | where State -eq "Running") {
    $Jobcount = (get-job ! where State -eq "Running").count 
    Write-Output "We are waiting on $jobcount reboots. sleep 10 seconds"
    Start-Sleep -Seconds 10 
}

$logfile = "CWD\reboot-$(get-date -Format 'yyyy-MM-dd-hh-mm-ss').log"
$endresult = get-job | Receive-Job -Force -Wait 


foreach ($result in $endresult) {
    "$(result.name), $(result.result)" | Out-File $logfile -Append 
}
#####################################

# disable bitlocker
Invoke-Command -ComputerName Win02 -ScriptBlock {
    Suspend-BitLocker -MountPoint C: -RebootCount 1
}