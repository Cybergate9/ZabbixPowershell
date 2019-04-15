<# 
Author: Shaun Osborne
Docs: https://github.com/Cybergate9/ZabbixPowershell/blob/master/docs/MaaSScriptsDocumentation.md
#>


<# do standard credentials load, or login dialog->store #>
. $PSScriptRoot\SetZabbixCredentials.ps1

<# build login call#>
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
