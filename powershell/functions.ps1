function Create-Configuration {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$Name
    )

    begin{
        "creating config file"
    }

    process {
        Write-Output "Creating config file $Name"
    }   
}

$Names | Create-Configuration -Name "test.txt"