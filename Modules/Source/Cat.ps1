function Get-Cat {
    $result = Invoke-Request -Uri https://catfact.ninja/fact -ContentOnly | ConvertFrom-Json 

    Write-Output "MEOW...."
    return $result.fact 
}

Get-Cat