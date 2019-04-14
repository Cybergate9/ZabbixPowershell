# this just opens a dialog, gathers login details and store the PSCredentials object to xml file in the current directory
$creds = Get-Credential $null
$creds | Export-CliXML -Path maascredentials.xml
	