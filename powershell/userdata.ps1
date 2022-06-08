# The log file for EC2Launch is C:\ProgramData\Amazon\EC2-Windows\Launch\Log\UserdataExecution.log.

# The C:\ProgramData folder might be hidden. To view the folder, you must show hidden files and folders.

<powershell>
$file = $env:SystemRoot + "\Temp\" + (Get-Date).ToString("MM-dd-yy-hh-mm")
New-Item $file -ItemType file
</powershell>
<persist>true</persist>
# By default, the user data scripts are run one time when you launch the instance. To run the user data scripts every time you reboot or start the instance, add <persist>true</persist> to the user data.

<powershell>
#Function to store log data
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    [pscustomobject]@{
        Time = (Get-Date -f g)
        Message = $Message
    } | Export-Csv -Path "c:\UserDataLog\UserDataLogFile.log" -Append -NoTypeInformation
 }
#Read input variables
[string]$ServerName = "${ServerName}"
$Environment = "${Environment}"
$System      = "${System}"

#Create log file location
if (-not(Test-Path "C:\UserDataLog"))
{
    New-Item -ItemType directory -Path "C:\UserDataLog"
    Write-Log -Message "Created folder to store log file."
} else {
    Write-Log -Message "Folder already exists."
}
#Userdata location
Write-Log -Message "Userdata script is stored at : $PSScriptRoot"
Write-Output "Server name = ${ServerName}"

#Check Computer ServerName
if ($env:COMPUTERNAME -eq $ServerName)
{
    Write-Log -Message "The name of the machine is correct: $env:COMPUTERNAME"
} else {
    Write-Log -Message "The name of the machine is incorrect and needs to change from $env:COMPUTERNAME to $ServerName."
    Rename-Computer -NewName $ServerName -Restart -Force
    Write-Log -Message "The machine will be renamed and restarted."
}
#Check Windows feature 
if ((Get-WindowsFeature Web-Server).installed -ne 'True')
{
    Write-Log -Message "Windows feature is not installed and will be installed."
    Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature
} else
{
    Write-Log -Message "Windows feature is already installed."
}
</powershell>
<persist>true</persist>