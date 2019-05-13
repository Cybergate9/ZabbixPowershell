Param (
    [Parameter(Mandatory=$true)][string]$hostid,
    [Parameter(Mandatory=$false)][string]$WithContent      
 )

<# do standard credentials load, or login dialog->store #>
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

$result = Invoke-WebRequest -Uri "http://maas.iocane.com.au/zabbix/api_jsonrpc.php" -Body $params -Method POST -Headers $headers
$key = $result.Content | ConvertFrom-JSON

if(-not $key.result){
    Write-Output 'ERROR: ' + [string]::$result.Content.error
    exit
}

<# get the api session key out of result, store, and build next request #>
$params = '{
    "jsonrpc": "2.0",
    "method": "item.get",
    "params": {
        "output": "extend",
        "hostids" : "'+ $hostid + '",
        "output" : "extend",
   	    "sortfield":"name"
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
        if($ent.name -match "\$[0-9]") # re-jig some descriptions to make them more readable
            {
                $ent.key_ -match ".*\[(?<braced>.*)\].*" | out-null
                $pieces = $Matches.braced.Split(",")
                $ent.name -match "(?<dolnum>[0-9])" | out-null
                $newdesc = $pieces[[int]$Matches.dolnum-1]
                $olddesc = $ent.name -replace "\s\$[0-9]", ""
                $newdesc = "$olddesc $newdesc"
            }
    if($WithContent) # if WIthContent requested out the whole entry into content property else just do name, key, delay, description
        {        
         $output += @{name = $ent.name; key = $ent.key_ ; delay = $ent.delay; description = $newdesc; content = $ent}
      }
    else {
         $output += @{name = $ent.name; key = $ent.key_ ; delay = $ent.delay; description = $newdesc} 
      }
    }


$output  | %{[pscustomobject]$_}

