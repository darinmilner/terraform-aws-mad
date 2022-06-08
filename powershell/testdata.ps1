Set-Content -Path c:\temp2\test.txt -Value Test

$Timer = [System.Timers.Timer]::new(15000) # Value in miliseconds

# register for an event -- runs when timer ticks
Register-ObjectEvent -InputObject $Timer -EventName Elapsed -Action {
  Get-ChildItem -Path c:\temp2\* | Remove_Item -Whatif
}

$Timer.Start()

# Pauses until event is triggered
Wait-Event SourceIdentifier IdThatDoesNotEvent  

Restart-Computer -ComputerName MyServer -Wait -For Powershell 
Write-Host "DONE!"

Test-ComputerSecureChannel -Repair 

Resolve-DnsName www.microsoft.com  

Test-NetConnection -Port 80

Get-DnsClientServerAddress

5 -ne 9
if (5 -ne 9) {
  Write-Host "5 is not 9"
}

5 -eq 9
5 -gt 4
7 -lt 6 
"Test" -like "Something"
"Test" -notlike "Te*"
"Test" -clike "TEST"

