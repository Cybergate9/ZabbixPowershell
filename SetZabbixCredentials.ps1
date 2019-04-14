# this just opens a dialog, gathers login details and stores the PSCredentials object to xml file in the current directory
# all subsequent calls to 'GetZabbixXYZ' scripts will use these stroed credentials
$creds = Get-Credential $null
$creds | Export-CliXML -Path zabbixcredentials.xml
	