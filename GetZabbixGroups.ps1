<# 
Author: Shaun Osborne
Docs: https://github.com/Cybergate9/ZabbixPowershell/blob/master/docs/MaaSScriptsDocumentation.md
#>


<# All Zabbix scripts begin with this standard authorisation logic which is:
###############################################################
1) do we have credentials in xml file?
2) if so, good, check it, load it
3) if not, get them via dialog and put them in the zabbixredentials.xml
#>
<# do we have a credentials file? #>
if(! (Test-Path "zabbizcredentials.xml" -PathType Leaf))
  {
    $creds = Get-Credential $null
    $creds | Export-CliXML -Path zabbizcredentials.xml
  }


<# Get Credentials and do some basic tests on their validity #>
$loadedcreds = Import-CliXML "maascredentials.xml"
if(-not $loadedcreds.Username -or -not $loadedcreds.Username){
    Write-Output "Credentials file zabbixredentials.xml is invalid - please delete.."
    exit
}

<# end of standard authorisation logic
##############################################################>

<# build login call
#>
$params = '{
    "jsonrpc" : "2.0",
    "method": "user.login",
    "params": {
        "user": "' + $loadedcreds.UserName + '",
        "password": "' + $loadedcreds.GetNetworkCredential().Password + '"
    },
    "id": 1,
    "auth": null
}'
$headers=@{"Content-Type"="application/json"}
#Write-Output $params

$result = Invoke-WebRequest -Uri "http://maas.iocane.com.au/zabbix/api_jsonrpc.php" -Body $params -Method POST -Headers $headers
$key = $result.Content | ConvertFrom-JSON

if(-not $key.result){
    Write-Output 'ERROR: ' + [string]::$result.Content.error
    exit
}
#Write-Output $key | ConvertTo-JSON

<# get the api session key out of result, store, and build next request 
#>
$params = '{
    "jsonrpc": "2.0",
    "method": "hostgroup.get",
    "params": {
        "output": "extend"
    },
    "id": 2,
    "auth": "'+$key.result+'"
}'

#Write-Output $params

$result = Invoke-WebRequest -Uri "http://maas.iocane.com.au/zabbix/api_jsonrpc.php" -Body $params -Method POST -Headers $headers
$reply = $result.Content | ConvertFrom-JSON
if($reply.result -eq ""){
    Write-Output 'ERROR: ' + [string]::$result.Content.error
    exit
}

$entries = $result.Content | ConvertFrom-JSON
foreach($entry in $entries.result)
{
Write-Host "Groupid: ", $entry.groupid, " Group Name: " , $entry.name 
}
