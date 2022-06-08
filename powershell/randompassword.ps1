function New-RandomPassword {
    param (
        [Parameter()]
        [int]$MinPasswordLength = 25,
        [Parameter()]
        [int]$MaxPasswordLength = 30,
        [Parameter()]
        [int]$NonAlphaChars = 1,
        [Parameter()]
        [Switch]$ConvertToSecureString
    )

    Add-Type -AssemblyName "System.Web"
    $length = Get-Random -Minimum $MinPasswordLength -Maximum $MaxPasswordLength
    $password = [System.Web.Security.Membership]::GeneratePassword($length, $NonAlphaChars)
    $password

    if ($ConvertToSecureString.IsPresent) {
        ConvertTo-SecureString -String $password -AsPlainText -Force 
    } else {
        $password
    }
}

New-RandomPassword -MinPasswordLength 30 -MaxPasswordLength 40 -NonAlphaChars 2 -ConvertToSecureString 