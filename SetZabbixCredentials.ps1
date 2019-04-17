<# All Zabbix scripts begin with this standard authorisation logic which is:
###############################################################
1) do we have credentials in xml file?
2) if so, good, check it, load it
3) if not, get them via dialog and put them in the zabbixredentials.xml
#>
<# do we have a credentials file? #>
$credspath = $ENV:APPDATA
$credsfile = '\.zabbixcreds.xml'
if(! (Test-Path $credspath$credsfile -PathType Leaf))
  {
    $creds = Get-Credential $null
    $creds | Export-CliXML -Path $credspath$credsfile
  }


<# Get Credentials and do some basic tests on their validity #>
$loadedcreds = Import-CliXML $credspath$credsfile
#$loadedcreds
if(-not $loadedcreds.Username -or -not $loadedcreds.Username){
    Write-Output "Credentials file:' $credspath$credsfile 'is invalid - please delete.."
    exit
}

<# end of standard authorisation logic
##############################################################>
