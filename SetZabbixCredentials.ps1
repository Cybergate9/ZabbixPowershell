<# All Zabbix scripts begin with this standard authorisation logic which is:
###############################################################
1) do we have credentials in xml file?
2) if so, good, check it, load it
3) if not, get them via dialog and put them in the zabbixredentials.xml
#>
<# do we have a credentials file? #>
if(! (Test-Path $PSScriptRoot"\zabbixcredentials.xml" -PathType Leaf))
  {
    $creds = Get-Credential $null
    $creds | Export-CliXML -Path $PSScriptRoot\zabbixcredentials.xml
  }


<# Get Credentials and do some basic tests on their validity #>
$loadedcreds = Import-CliXML $PSScriptRoot"\zabbixcredentials.xml"
#$loadedcreds
if(-not $loadedcreds.Username -or -not $loadedcreds.Username){
    Write-Output "Credentials file zabbixredentials.xml is invalid - please delete.."
    exit
}

<# end of standard authorisation logic
##############################################################>
