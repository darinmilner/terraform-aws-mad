$un = "admin123"
$pw = "securepassword"
$spw = $pw | ConvertTo-SecureString -AsPlainText -Force 

$plainCred = New-Object System.Management.Automation.PSCredential -ArgumentList $un, $spw 

Connect-msolService -Credential $plainCred 
Get-msolUser


$credentials = Get-Credential 
# Import from text file
mkdir "C:\safe"

$fileName = "C:\safe\secret.txt"
$credentials | Export-Clixml -Path $fileName

#import
$credPath = "C:\safe\secret.txt"
$fileCreds | Import-Clixml -Path $fileName