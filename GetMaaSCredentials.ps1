$creds = Get-Credential $null
$creds | Export-CliXML -Path maascredentials.xml
#$increds = Import-CliXML "maascredentials.xml"./s	