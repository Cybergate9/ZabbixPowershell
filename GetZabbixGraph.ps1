Param (
    [Parameter(Mandatory=$true)][string]$Graphid,
    [Parameter(Mandatory=$false)][string]$Filename=$Graphid,
    [Parameter(Mandatory=$false)][string]$From='now-1y/y',
    [Parameter(Mandatory=$false)][string]$To='now-1y/y',
    [Parameter(Mandatory=$false)][string]$Width=800,
    [Parameter(Mandatory=$false)][string]$DeviceType='ESX'    
 )

<# 
Author: Shaun Osborne
Docs: https://github.com/Cybergate9/ZabbixPowershell/blob/master/docs/MaaSScriptsDocumentation.md
#>

<# do standard credentials load, or login dialog->store #>
. $PSScriptRoot\SetZabbixCredentials.ps1

$zabbixLoginUrl = "http://maas.iocane.com.au/zabbix/index.php?login=1"
$zabbixGraphUrl = "http://maas.iocane.com.au/zabbix/chart2.php"
Add-Type -AssemblyName System.Web
$zabbixTo = [System.Web.HttpUtility]::UrlEncode($To)
$zabbixFrom = [System.Web.HttpUtility]::UrlEncode($From)
$zabbixWidth = [System.Web.HttpUtility]::UrlEncode($Width)

$zabbixGraphArgs = "from=" + $zabbixFrom + '&to=' + $zabbixTo + "&profileIdx=web.graphs.filter&width=" + $zabbixWidth
$zabbixGraphIDs = '&graphid='+$graphid+'&profileIdx2=' + $graphid
$userName = $loadedcreds.UserName
$userPwd = $loadedcreds.GetNetworkCredential().Password

$loginPostData =@{ name=$userName; password=$userPwd; enter="Sign In"}


$login = Invoke-WebRequest -Uri $zabbixLoginUrl -Method Post -Body $loginPostData -SessionVariable sessionZabbix

#let's see if we have a cookie set
if ($sessionZabbix.Cookies.Count -eq 0) 
    {
    Write-Host "ERROR: fail to connect to MaaS"
    break
    }
else 
    {
    Write-Host "INFO: Zabbix replied to initial request"
    }

$sessionZabbix.Cookies.SetCookies($zabbixGraphUrl, $sessionZabbix.Cookies.GetCookieHeader($zabbixLoginUrl))
#$sessionZabbix | ConvertTo-JSON

$outfile = $Filename + '.png'
$path = pwd
$fulloutfile = $path.Path + '\' + $Filename + '.png'
$jpgfile = $path.Path + '\' + $Filename + '.jpg'

#now let's retrieve the graph ID using the previously established session
$result = Invoke-WebRequest -Passthru -Uri ($zabbixGraphUrl+'?'+$zabbixGraphArgs+$zabbixGraphIDs) -WebSession $sessionZabbix -Outfile $outfile

<# if theres an error say so, and delete output file #>
if($result -like "*You are not logged in*")
  {
    Write-Output "ERROR: You are not logged in" 
    Write-Output $result.RawContent 
    del $outfile
  }
else {
      # convert to JPG and remove png (there were issues here - it wouldn't release the png so have left out for now)
      <#Add-Type -AssemblyName system.drawing
      $imageFormat = "System.Drawing.Imaging.ImageFormat" -as [type]
      $image = [drawing.image]::FromFile($fulloutfile, 1)
      $image.Save($jpgfile, $imageFormat::jpeg)
      del $outfile #>
      Write-Output "INFO: Success, GraphID $Graphid"
      Write-Output "saved to $jpgfile"

  }  



