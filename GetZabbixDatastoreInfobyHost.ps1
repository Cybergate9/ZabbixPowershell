Param (
    [Parameter(Mandatory=$true)][string]$hostid
)
<# 
Author: Shaun Osborne
Docs: https://github.com/Cybergate9/ZabbixPowershell/blob/master/docs/MaaSScriptsDocumentation.md
#>



. $PSScriptRoot\SetZabbixCredentials.ps1

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

if(-not $key.result ){
    Write-Output 'ERROR: ', $result.Content
    exit
}

<# get the api session key out of result, store, and build test status request #>
$params = '{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "hostids": "' + $hostid + '"
    },

    "id": 2,
    "auth": "'+$key.result+'"
}'
$result = Invoke-WebRequest -Uri "http://maas.iocane.com.au/zabbix/api_jsonrpc.php" -Body $params -Method POST -Headers $headers
$content = $result.Content | ConvertFrom-JSON
if( $content.error){
    Write-Output 'ERROR: ', $result
}
if($content.result.status -eq '1'){
     Write-Output 'ERROR: (MaaS monitoring for this host is disbled)', $content.result
     Exit 1
}

<# get the api session key out of result, store, and build next request #>
$params = '{
    "jsonrpc": "2.0",
    "method": "item.get",
    "params": {
        "hostids": "' + $hostid + '",
	    "sortfield":"name",
        "search" : {"key_" : "vmware.hv.datastore.size"}
    },

    "id": 3,
    "auth": "'+$key.result+'"
}'


$result = Invoke-WebRequest -Uri "http://maas.iocane.com.au/zabbix/api_jsonrpc.php" -Body $params -Method POST -Headers $headers
$content = $result.Content | ConvertFrom-JSON
if( $content.error){
    Write-Output 'ERROR: ', $result
}

$entries = $result.Content | ConvertFrom-JSON
#Write-Output $result.Content 
$store=@{}
foreach($entry in $entries.result)
        {
        $array = $entry.key_.Split(',')
        $name = $array[2].TrimEnd(']')
        #Write-Host " HostId:",   $entry.hostid, " Name:", $entry.name,  " Key:" , $entry.key_ , " Units:" , $entry.units, " LastValue:" , $entry.lastvalue
        #Write-Output $name
        if(-not $store.$name){ $store.$name = @{free = '0'; total = '0'; totalGB = '0'; freeGB = '0'; totalTB = '0'; freeTB = '0'; freepc = '0'; usedpc = '0'} }
        if($entry.name -like "Free*" -and $entry.name -notlike "*percentage*"){
            #Write-Output "FREE MATCH"
            $store.$name.free = $entry.lastvalue
            $store.$name.freeGB = [math]::Round($entry.lastvalue/1Gb,2)
            $store.$name.freeTB = [math]::Round($entry.lastvalue/1Tb,4)
         
            }
        if($entry.name -like "Total*"){
            #Write-Output "TOTAL MATCH"
            $store.$name.total = $entry.lastvalue
            $store.$name.totalGB = [math]::Round($entry.lastvalue/1Gb,2)
            $store.$name.totalTB = [math]::Round($entry.lastvalue/1Tb,4)
            }
        }


# $store | ConvertTo-JSON

foreach($key in $store.Keys)
{
            $store[$Key]['usedGB'] = [math]::Round($store[$Key]['totalGB'] - $store[$Key]['freeGB'],2)
            $store[$Key]['usedTB'] = [math]::Round($store[$Key]['totalTB'] - $store[$Key]['freeTB'],4)
            $store[$Key]['used'] = [math]::Round($store[$Key]['total'] - $store[$Key]['free'],2)
            $store[$Key]['usedpc'] = [math]::Round($store[$Key]['used']/$store[$Key]['total'],2)
            $store[$Key]['freepc'] = [math]::Round($store[$Key]['free']/$store[$Key]['total'],2)

}

#Write-Output $store
[PsObject]$output = @()
foreach($key in $store.Keys)
{
 $output += @{dsname = $key; usedpc = $store[$key]['usedpc']; freepc = $store[$key]['freepc'] ; usedGB = $store[$key]['usedGB'] ; freeGB = $store[$key]['freeGB'] ; totalGB = $store[$key]['totalGB'] ; usedTB = $store[$key]['usedTB'] ; freeTB = $store[$key]['freeTB']; totalTB = $store[$key]['totalTB'] } 
}# 
#            Write-Output $key
#            Write-Output [PsObject]@{dsname = $key; usedpc = $store[$key]['usedpc']; freepc = $store[$key]['freepc'] ; usedGB = $store[$key]['usedGB'] ; freeGB = $store[$key]['freeGB'] ; totalGB = $store[$key]['totalGB'] ; usedTB = $store[$key]['usedTB'] ; freeTB = $store[$key]['freeTB']; totalTB = $store[$key]['totalTB']  }      
#
#}

$output | %{[pscustomobject]$_}

