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

Function Get-PwnedPassword {
    Param (
        [Parameter(Mandatory=$true)]
        [string]$string
    )
    $stringBuilder = New-Object System.Text.StringBuilder
    $byteArray = [System.Security.Cryptography.HashAlgorithm]::Create("SHA1").ComputeHash([System.Text.Encoding])::UTF8.G
    foreach ($byte in $byteArray) {
        [Void]$stringBuilder.Append($byte.ToString("x2"))
    }
    $hash = $stringBuilder.ToString()
    $prefix = $hash.Substring(0,5)
    $suffix = $hash.Substring(5,35)

    $results = Invoke-RestMethod -Uri https://api.pwnedpasswords.com/range/$prefix
    # results are single long string.  Need to break out individual hashes
    $results = ($results | Select-String "(\w{35}:\d{1,})" -AllMatches).Matches.Value
    $unmatched = $true
    foreach ($entry in $results) {
        $entry = $entry.split(":")
        if($entry[0] -eq $suffix){
            Write-Host "$($entry[1]) Matches"
            $unmatched = $false
            break
        }
    }
    if($unmatched){}
}