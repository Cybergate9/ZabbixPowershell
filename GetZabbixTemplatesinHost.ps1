Param (
    [Parameter(Mandatory=$true)][string]$hostid

)

<# do standard credentials load, or login dialog->store #>
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
 "method": "template.get",
    "params": {

        "hostids" : "' + $hostid + '",
        "selectTemplates": "name",
        "selectParentTemplates": ["name","templateid"],
        "selectTemplates": ["name","templateid"]
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
    foreach($tem in $ent.parentTemplates)
        {
         $linkedtemplates += $tem.name + ', '
        }
    foreach($tem in $ent.templates)
        {
         $linkedtemplates += $tem.name + ', '
        }
    $linkedtemplates = $linkedtemplates -replace ",\s$"
    $output += @{host = $hostname; id = $ent.templateid; name = $ent.name; linkedtemplates = $linkedtemplates}
}


$output  | %{[pscustomobject]$_}
