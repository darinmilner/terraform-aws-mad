$computerName = "www.google.com"
if(Test-NetConnection -ComputerName $computerName -InformationLevel Quiet -WarningAction silentlyContinue) {
    Write-Host "$computerName is ONLINE." -ForegroundColor Green
} Else {
    Write-Host "$computerName is OFFLINE." -ForegroundColor Red 
}


---------------------------------

$menu = @"
**********************************
Make a selection

p = Display processes consuming the most memory
o = Display processes by manufacturer
s = Display running services
h = Display installed hotfixes
x = Exit

**********************************
"@

do {
    cmd /c color 71
    $selection = Read-Host -Prompt $menu 
    Clear-Host 
    Switch ($selection) {
        p {  
            Get-Process | Sort-Object WS -Descending | Select-Object -First 10 | Format-Table
            pause 
        }
        o {  
            Get-Process | Sort-Object Company | Format-Table -GroupBy Company 
            pause 
        }
        s {  
            Get-Service | Where-Object Status -eq Running | Format-Table
            pause 
        }
        h {
            Get-Hotfix | Format-Table HotfixID, InstalledOn -AutoSize
            pause
        }
        Default {
            Write-Host "Please choose a valid option" -ForegroundColor DarkGray -BackgroundColor Red 
        }
    }
} until ($selection -eq "x")
Switch ($PSVersion.PSEdition) {
    "core" {cmd /c color 07}
    "Desktop" {cmd /c color 56}
    Default {cmd /c color 56}
}

Clear-Host

---------------------------------
$computer = "AWSCLI"

$role = "unknown role"
$location = "unknown location"

Switch -Wildcard ($computer) {
    "*CLI*" { $role = "Client";break}
    "*SRV*" { $role = "Server"}
    "*DC*"  { $role = "Domain Controller"}
    "*AWS*" { $location = "AWS" }
    "*AZ*"  {$location = "Azure"}
    Default {
        "$computer is not a valid name"
    }
}

Write-Host "$computer is a $role in $location"


# ForEach
$users = Get-ADUser -filter {department -eq "Research"}
ForEach ($user in $users) {
   $firstName = $user.GivenName 
   $lastName = $user.surname 
   "$firstName.$lastName@adatun.com"
}

For($i = 1; $i -le 254; $i++) {
    # exclude 200 to 225
    if ($i -in 200..225) {
        Continue 
    }
    "172.16.0.$i"
}

Get-Date 
[datetime]$stop = "15:45:15"
do {
    Write-Host "*" -ForegroundColor Green -NoNewline
    Sleep 1
} Until ((Get-Date) -ge $stop)

while ((Get-Date) -le $stop) {
    Write-Host "*" -ForegroundColor Green -NoNewline
    Sleep 1
}


$userName = Read-Host "Enter your username"
Write-Host "You entered $userName"

$creds = Get-Credential -Message "Enter your credentials" -UserName "Administrator"
$cimSession = New-CimSession -ComputerName Test123 -Credential $creds
Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $cimSession

Search-ADAccount -AccountInactive -TimeSpan "180" | Out-GridView -PassThru | Disable-ADAccount

<#
    Script to see when a computer last booted up
#>
param(
    [string]$computerName = "localhost"
)
Get-CimInstance  -ComputerName $computerName -ClassName Win32_OperatingSystem | Select PSComputerName, LastBootUpTime 