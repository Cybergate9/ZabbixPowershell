Param (
    [Parameter(Mandatory=$true)][string]$hostid

)
<# 
Author: Shaun Osborne
Docs: https://github.com/Cybergate9/ZabbixPowershell/blob/master/docs/MaaSScriptsDocumentation.md
#>


<# do standard credentials lookup, or login #>
. $PSScriptRoot\SetZabbixCredentials.ps1

$hostname = . $PSScriptRoot\GetZabbixHost.ps1 $hostid | Select -Expand name
 
<# build login call #>
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

<# get the api session key out of result, store, and build next request #>
$params = '{
    "jsonrpc": "2.0",
    "method": "graph.get",
    "params": {
        "output": "extend",
        "hostids" : "'+ $hostid + '",
        "expandExpression" : true
    },
    "id": 2,
    "auth": "'+$key.result+'"
}'


$result = Invoke-WebRequest -Uri "http://maas.iocane.com.au/zabbix/api_jsonrpc.php" -Body $params -Method POST -Headers $headers
$content = $result.Content | ConvertFrom-JSON
if( $content.error){
    Write-Output 'ERROR: ', $result
}

$entries = $result.Content | ConvertFrom-JSON
$entries = $content.result

[PsObject]$output = @()
foreach($ent in $entries)
    {
      $output += @{graphid = $ent.graphid; name = $ent.name ;host = $hostname;}
    }


$output  | %{[pscustomobject]$_}