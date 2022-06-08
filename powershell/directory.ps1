Import-Module ADDSDeployment 
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "WinThreshold"
    -DomainName "test.com" -DomainNetbiosName "TEST" -ForestMode "WinThreshold" -InstallDns:$true 
    -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false  -SysvolPath "C:\Windows\SYSVOL" -Force:$true 

# Active Directory module
Search-ADAccount -AccountDisabled 
Search-ADAccount -AccountInactive
Search-ADAccount -AccountInactive -DateTime "1/1/2022"
Search-ADAccount -PasswordExpried
Search-ADAccount -PasswordNeverExpires 

Get-ADUser -Filter *

Get-Process | Measure
Get-Process | Measure -Property WS -Sum -Average -Maximum -Minimum
Get-ADUser -Filter *  | Measure-Object
Get-ADUser -Filter {department -like "*i*"}
Get-ADUser -Filter * | Format-Table Name,GivenName,Surname,Enabled | Export-CSV C:\PS\users.csv
# object.properties
Get-ADUser Lara -Properties * | Get-Member 
Get-ADUser Administrator -pro memberOf | Select -ExpandProperty memberOf

$lara = Get-ADUser Lara -Properties * 
$lara.carLicense 

"Server1", "Server2" | Test-NetConnection 
Get-Content .\computers.txt | Test-NetConnection

Import-CSV .\computers.csv | Get-Member

Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4 
(Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4).IPAddress 
Test-Connection -ComputerName (Get-Content .\computer.txt)

Get-Process | Sort-Object ID -Descending -Unique 
Get-Process | Sort-Object @{Expression="ProcessName";Descending=$false}
Get-Process | Sort-Object @{Expression="ProcessName";Descending=$false} | Select -first 5
Get-Process | Sort-Object @{Expression="ProcessName";Descending=$false}, @{Expression="ID", Descending=$true} | Select -Index 10,11,12

342432425214/1mb 

Get-Process | Sort -Descending WS | Select -First 5 ProcessName,WS
Get-Process | Sort -Descending WS | Select -First 5 ProcessName, @{Label="WS(MB)";Expression={"test"}}

WS (Working Set Value)
$_ iterator variable 
Get-Process | Sort -Descending WS | Select -First 5 ProcessName, @{Label="WS(MB)";Expression={$_.WS/1mb}}
Get-Service | Where-Object Status -eq Running 
Get-Service | Where-Object {$_.Status -eq "Running" -and $_.Name -like "win*"}

Get-ADUser -Fitler {department -like "IT*"}
1..5
Get-Hotfix | ForEach-Object HotfixID
1..5 | ForEach-Object {$_}
1..5 | ForEach-Object {Write-Host "Doubling $_"; $_ * 2}

Get-ADUser -Filter * -SearchBase "OU=Marketing,DC=Adatum,DC=Com" | Format-Table | Out-File C:\PS\marketing.txt 
Get-ADUser -Filter * -SearchBase "OU=Marketing,DC=Adatum,DC=Com" | Export-CSV marketing.csv -NoTypeInformation
Get-ADUser -Filter * -SearchBase "OU=Marketing,DC=Adatum,DC=Com" | Select Name,enabled | Export-CSV marketing.csv -NoTypeInformation
Get-ADUser -Filter * -SearchBase "OU=Marketing,DC=Adatum,DC=Com" -Properties memberOf | Select Name,enabled, memberOf | Export-CLIXML marketing.xml 
Get-ADUser -Filter * -SearchBase "OU=Marketing,DC=Adatum,DC=Com" -Properties memberOf | Select Name,enabled, memberOf | ConvertTo-HTML

Get-PSProvider
Get-PSDrive 
Get-Alias -Definition Remove-Item 

# Maps to a drive on a remote server
New-PSDrive -Name X -PSProvider FileSystem -Root \\LONDSVR1\C$ -Persist 
Remove-PSDrive X 

# see if remote desktop is enabled
Get-ItemPropertyValue "HKLM:\System|CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections
Set-ItemProperty "HKLM:\System|CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0  #remove deny ts connections
dir -Recursive -ExpriringInDays 90   # find expiring certificates in cert directory
Get-Command -Module PKI  

Get-WmiObject -list -Namespace root

Get-WmiObject Win32_LogicalDisk 
Get-WmiObject Win32_LogicalDisk -ComputerName server 
Get-CimInstance Win32_Share 

Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3 AND FreeSpace>10000000"

Get-WmiObject -query "Select * From Win32_LogicalDisk"
Get-WmiObject -query "Select * From Win32_LogicalDisk Where DriveType=3"

Get-WmiObject -query "Select * From Win32_Service Where Name = 'audiosrv'"
Get-WmiObject -query "Select * From Win32_Service Where Name LIKE '%audio%'"
Get-WmiObject -query "Select * From Win32_Service Where NOT Name LIKE '%audio%'"
Get-WmiObject -query "Select * From Win32_Service Where Name LIKE '[af]%'"  # a and f
Get-WmiObject -query "Select * From Win32_Service Where Name LIKE '[a-f]%'"  # range a through f
Get-WmiObject -query "Select * From Win32_Service Where Name LIKE '[^a-f]%'"  # not a through f
Get-WmiObject -query "Select * From Win32_Service Where Name LIKE '[^a-f]%' AND state='Stopped'"
Get-WmiObject -query "Select * From Win32_Service Where Name LIKE '[^a-f]%' AND state='Stopped' AND StartMode='Disabled'"

$session = New-CimSession -ComputerName Server1
Get-CimInstance -query "Select * From Win32_LogicalDisk" -CimSession $session 

$value = "String"
"This is a $value"
"The value of `$Value is $Value"

$users = Get-ADUser -Filter * 
$users.count 
"There are $($users.count) users."
$users.surname 

# variables
[string]$computerName = "abc123"
$computerName.GetType()
$num = 33.44
$num.GetType()
$num | Get-Member 
$num -as [int]

[datetime] "1/1/2022"
[string[]]$computers = "srv1"
$computers += "srv2"

$nic = Get-WmiObject Win32_NetworkAdapter -Filter "PhysicalAdapter=$true"
$string.Insert(5, "short")
$string.Substring(10,7)
$string.Remove(5,5)
$string.Replace("s", '$$$')

$ip = "127.268.0.10"
$ip.Split(".")

(Get-Content .\computers.txt).Trim() | Test-NetConnection
$date = Get-Date 
$date.DayOfWeek
$date.AddDays(90)
$date.ToLongDateString()

Get-ADUser -Filter * -Properties whenCreated | Sort-Object -Property whenCreated -Descending | 
    Select-Object -Property Name, @{n="Account Age(Days)"; e={(New-TimeSpan -Start $_.whenCreated)}}

computerList = Get-AdComputer -Filter * 
$computerList[0]
$computerList.count 

$numbers = 1..10
$numbers[0..4]
$numbers += 11 
[string[]]$computers = "server1"
[array]

$array = @{}
$computers -contains "server1"
"server1" -in $computers 
"server1" -notin $computers 
"SERVER1" -cin $computers 