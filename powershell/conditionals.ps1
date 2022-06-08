$filepath = "C:\Example\test.txt"

Test-Path -Path $filepath 

if(Test-Path -Path $filepath){
    $Data = Write-Output "File exists"
    if ($Data.Count -lt 10){
        Write-Output "Less than 10 words"
    } elif ($Data.count -lt 20) {
        Write-Output "Less than 20 words"
    } else {
        Write-Output "20 or more words"
    }
} else {
    Write-Output "File Does Not exist."
}

$First=$Data[0]

switch ($First) {
    "A" { 
        Write-Output "A"
        break
     }
     "B" {
         Write-Output "B"
         break
     }
     "C" {
         Write-Output "C"
         break
     }
    Default {
        Write-Output "Non of the above values"
        break 
    }
}

# set array of names
$Names = [System.Collections.ArrayList]@("Test","Test1")
$current = $Names[0]
Get-Content -Path "C:\data\Names\$current\config.txt"
Get-Content -Path "C:\data\Names\$($Names[0])\config.txt"

foreach($Name in $Names) {
    Get-Content -Path "C:\data\Names\$Name\config.txt" 
    Write-Output "Restart Computer and then continue."
}

# built in cmdlet for object
$Names | ForEach-Object -Process {
    Get-Content -Path "C:\data\Names\$_\config.txt" 
}

$Names.ForEach({
    Get-Content -Path "C:\data\Names\$_\config.txt" 
})

Write-Output "More after if statement"
##########################################
# change registry
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TerminalServer\WinStations\RDP-Tcp" -name "PortNumber"

Set-ItemProperty - Path  "HKLM:\SYSTEM\CurrentControlSet\Control\TerminalServer\WinStations\RDP-Tcp" -name "PortNumber" -value "3390"

# Add a new key to store information that persists accross reboots
New-Item -Path "HKCU:\MyKey"

# add registry entries using NewItemProperty 
New-ItemProperty -Path "HKCU:\MyKey" -Name "Property1" -Value "Value1"

Get-ItemProperty -Path "HKCU:\MyKey"

# https://argonsys.com/microsoft-cloud/library/how-to-update-or-add-a-registry-key-value-with-powershell/
# Set variables to indicate value and key to set
$RegistryPath = 'HKCU:SoftwareCommunityBlogScripts'
$Name         = 'Version'
$Value        = '42'
# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 

# Sample script to update and reboot
set-executionpolicy -scope CurrentUser -executionPolicy Bypass -Force
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateupdateSearcher()
$Updates = @($UpdateSearcher.Search("IsHidden=0 and IsInstalled=0").Updates)
if ($Updates.Count -gt 0)
{
    # Pending updates 
    $Updates | Select-Object Title
    $scriptPath = "$PSScriptRoot\checkWinUpdates.ps1";
    Write-Host ("Script path is " + $scriptPath);
    # register schedule task so that the script runs at reboot
    Register-ScheduledTask -TaskName "simpleupdatetask" -Trigger (New-ScheduledTaskTrigger -AtLogon) -Action (New-ScheduledTaskAction -Execute "${Env:WinDir}\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument ("-Command `"& '" + $scriptPath + "'`"")) -RunLevel Highest -Force; 

    Install-PackageProvider NuGet -Force
    Import-PackageProvider NuGet -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
   
 #  update and reboot if necessary
    Install-Module PSWindowsUpdate
    Get-Command –module PSWindowsUpdate
    Add-WUServiceManager -ServiceID sampleserviceid -Confirm:$false
    Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot
}
else
{
    # remove script from running at startup
    Unregister-ScheduledTask -TaskName "smpleupdatetask" -Confirm:$false
}