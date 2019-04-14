Param (
    [Parameter(Mandatory=$true)][string]$hostid

)
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
    "method": "trigger.get",
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
    # ugly regex stack to clean zabbix expanded trigger expressions output to make them
    # a little more human friendly
    $newdesc = $ent.description -replace "\{HOST.NAME\}\:\s", ""    
    $newdesc = $newdesc -replace "\{HOST.NAME\}\s", ""   
    $newexpr = $ent.expression -replace "[{,][0-9]{3,}\-[0-9]{3,}\-[0-9]{3,}\-[0-9]{3,}\-[0-9abcdef]{3,}"
    $newexpr = $newexpr -replace "https\:.*\/sdk"
    $newexpr = $newexpr -replace ":vmware", "vmware"
    $newexpr = $newexpr -replace "pfree", "% free"
    $newexpr = $newexpr -replace "(\[[A-Z]:)\,", '$1].'
    $newexpr = $newexpr -replace "\[\,", "-"
    $newexpr = $newexpr -replace "\.\[", "."
    $newexpr = $newexpr -replace "}([><=])", ' $1 '
    $newexpr = $newexpr -replace "\{"
    $newexpr = $newexpr -replace "\}"
    #remove newline from comments as they muck up csv output if used
    $newcomment = $ent.comments -replace "[\r\n]", ' '

    $output += @{host = $hostname; id = $ent.triggerid; expr = $newexpr ; comments = $newcomment; description = $newdesc; priority = $ent.priority}
}


$output  | %{[pscustomobject]$_}