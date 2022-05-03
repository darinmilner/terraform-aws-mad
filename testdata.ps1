Set-Content -Path c:\temp2\test.txt -Value Test

$Timer = [System.Timers.Timer]::new(15000) # Value in miliseconds

# register for an event -- runs when timer ticks
Register-ObjectEvent -InputObject $Timer -EventName Elapsed -Action {
  Get-ChildItem -Path c:\temp2\* | Remove_Item -Whatif
}

$Timer.Start()

# Pauses until event is triggered
Wait-Event SourceIdentifier IdThatDoesNotEvent  


