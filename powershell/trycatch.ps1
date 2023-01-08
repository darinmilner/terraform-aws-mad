$computers = "SVR1", "SRV99", "DC1"

try {
    Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computers | Select-Object PSComputerName, LastBootupTime
}catch {
   Write-Warning "This won't run"
}

# throws error if any computer fails
try {
    Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computers -ErrorAction Stop |
        Select-Object PSComputerName, LastBootupTime
}catch {
   Write-Warning "Any failure comes here"
}

# for each
ForEach ($computer in $computers){
    try {
        Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computers -ErrorAction Stop |
            Select-Object PSComputerName, LastBootupTime
    }catch {
       Write-Warning "Error on $computer"
    }
}
