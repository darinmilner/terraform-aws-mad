Get-ADUser -Filter {department -eq "IT"} -Properties department | Export-CSV C:\PS\IT_Users.csv -IncludeTypeInformation

Import-Csv C:\PS\IT_Users.csv

Get-ADUser -Filter {department -eq "IT"} -Properties department, memberOf | Export-Clixml  C:\PS\IT_Users.xml
Import-Clixml  C:\PS\IT_Users.xml

# Get all items in regedit
Get-ChildItem -Path hkcu:\ -Recurse

New-Item -Path hkcu:\software
Get-ChildItem -Path HKCU:\Software -Recurse | Where-Object -FilterScript {($_.SubKeyCount -le 1) -and ($._ValueCount -eq 4)}