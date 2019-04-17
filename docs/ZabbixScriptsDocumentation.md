# MaaS (Zabbix) Scripts Documentation

## Introduction

These tools access the live MaaS (Zabbix) environment via its API to perform various useful functions.
The design philosophy is that each script: 
  * does one thing
  * returns 'powershell objects' as output
  * has at least 'pipeable' output (some have pipeable inputs too)

This allows the scripts to be combined in various useful ways to extract information from Zabbix (mostly for reporting)

### Authoristation and Credentials

All access to Zabbix is using your own credentials.
You must log into Zabbix to use any of the scripts.
All the scripts will prompt for login, if you are not logged in, and store your credentials in an encrypted 'PSCredential object' xml file
There is a specific script you can use, if you wish, to set your credentials explicity and then all subsequent called scripts will use thos stored/set credentials (see Functions-SetMaaSCredentials)

### Document conventions

[] = optionals


## Functions

### SetZabbixCredentials

This script will open a login dialog into to which you put your username and password (Zabbix authentication) and then it stores the resultant 'PSCredential object' into zabbixcredentials.xml in the directory where the scripts are run from.

### GetZabbixGroups.ps1

This script will return all the groups in Zabbix

### GetZabbixHost.ps1

This script will return the Zabbix host name for a given hostid
e.g.

.\GetZabbixHost.ps1 [-hostid] 11161

~~~~
  host        hostid name
  ----        ------ ----
  ASADLBAAS01 11611  ASADLBAAS01
~~~~

### GetZabbixHostsinGroup.ps1

This script will return all hosts for a given groupid

e.g.
./GetZabbixHostsinGroup [-groupid] 58

~~~~

name                host                                 hostid groupid
----                ----                                 ------ -------
CH-FW-M1-A          CH-FW-M1-A                           11529  58
CH-FW-M1-B          CH-FW-M1-B                           11530  58
CH-FW-M2-A          CH-FW-M2-A                           11527  58
CH-FW-M2-B          CH-FW-M2-B                           11528  58
CH-VICM1-ESX01      00000000-0000-1101-0000-0000000003df 11161  58
CH-VICM1-ESX02      00000000-0000-1101-0000-0000000003bf 11164  58
CH-VICM1-ESX03      00000000-0000-1101-0000-0000000003cf 11165  58
CH-VICM1-ESX04      00000000-0000-1101-0000-0000000003af 11166  58
~~~~

### GetZabbixGraph.ps1

This script will return a jpeg image for a given graphid

e.g.
./GetZabbixGraph.ps1 [-Graphid] 55432 [-Filename <filename>] [-From <string>] [-To <string>] [=Width=<nnn>] [-DeviceType <string>]

~~~~~
INFO: Zabbix replied to initial request
INFO: Success, GraphID 55432
saved to C:\Users\osbornes\Dropbox\Work-Iocane\docs+scripts\MaaS\55432.jpg
~~~~~

### GetZabbixGraphsinHost.ps1

This script will return all the graphs for a given hostid

e.g.
./GetZabbixGraphsinHost.ps1 [-hostid] 11161

~~~~~
graphid host           name
------- ----           ----
32815   CH-VICM1-ESX01 Traffic on interface Device vmnic3 at 09:00.0 nenic (64-bit)
32811   CH-VICM1-ESX01 Traffic on interface Virtual interface: vmk3 on vswitch vSwitch2 portgroup: vMotion-12
32821   CH-VICM1-ESX01 Traffic on interface Traditional Virtual VMware switch: iScsiBootvSwitch (64-bit)
32827   CH-VICM1-ESX01 Traffic on interface Virtual interface: vmk3 on vswitch vSwitch2 portgroup: vMotion-12 (64-bit)
32824   CH-VICM1-ESX01 Traffic on interface Virtual interface: vmk0 on vswitch vSwitch0 portgroup: Management Networ...
32825   CH-VICM1-ESX01 Traffic on interface Virtual interface: vmk1 on vswitch iScsiBootvSwitch portgroup: iScsiBoot...
32814   CH-VICM1-ESX01 Traffic on interface Device vmnic2 at 08:00.0 nenic (64-bit)
~~~~~

### GetZabbixTemplatesinHost.ps1

This script will return all the templates for a given hostid

e.g.
./GetZabbixTemplatesinHost.ps1 [-hostid] 11161

~~~~~
host           name                              id    linkedtemplates
----           ----                              --    ---------------
CH-VICM1-ESX01 Iocane-Template-VMware-Hypervisor 10091 Iocane-Template SNMP Interfaces, Iocane-Template SNMP Generic...
~~~~~

### GetZabbixItemsinHost.ps1

This script will return all the items for a given hostid

e.g.
./GetZabbixItemsinHost.ps1 [-hostid] 11161

~~~~~
delay key
----- ---
1h    ifAdminStatus[Virtual interface: vmk1 on vswitch iScsiBootvSwitch portgroup: iScsiBootPG-A]
1h    ifAdminStatus[Virtual interface: vmk2 on vswitch iScsiBootvSwitch portgroup: iScsiBootPG-B]
1h    ifAdminStatus[Virtual interface: vmk3 on vswitch vSwitch2 portgroup: vMotion-12]
1h    ifAdminStatus[Device vmnic6 at 16:00.0 nenic]
1h    ifAdminStatus[Device vmnic5 at 15:00.0 nenic]
1h    ifAdminStatus[Device vmnic4 at 14:00.0 nenic]
~~~~~

### GetZabbixTriggersinHost.ps1

This script will return all the graphs for a given hostid

e.g.
./GetZabbixTriggersinHost.ps1 [-hostid] 11161 [-rawexpressions| Format-Table


~~~~~
id     host description                                                              expr                                                                      priority comments
--     ---- -----------                                                              ----                                                                      -------- --------
137314      Free disk space is less than 2% on datastore CH-VIC-T2-DATASTORE04       vmware.hv.datastore.size-CH-VIC-T2-DATASTORE04,% free].min(120m) < 2      5
137246      Free disk space is less than 10% on datastore CH-VIC-ESX01-LOCAL         vmware.hv.datastore.size-CH-VIC-ESX01-LOCAL,% free].min(120m) > 5         3
137276      Free disk space is less than 10% on datastore CH-VIC-RIS-T2SN-NR-01      vmware.hv.datastore.size-CH-VIC-RIS-T2SN-NR-01,% free].min(120m) > 5      3
137300      Free disk space is less than 5% on datastore CH-VIC-PACSDATA-T2SN-NR-11  vmware.hv.datastore.size-CH-VIC-PACSDATA-T2SN-NR-11,% free].min(120m) > 2 4
137336      Free disk space is less than 2% on datastore CH-VIC-PACSINF-T2SN-NR-01   vmware.hv.datastore.size-CH-VIC-PACSINF-T2SN-NR-01,% free].min(120m) < 2  5
137326      Free disk space is less than 2% on datastore CH-VIC-T2-DATASTORE16       vmware.hv.datastore.size-CH-VIC-T2-DATASTORE16,% free].min(120m) < 2      5
137254      Free disk space is less than 10% on datastore CH-VIC-T2-DATASTORE06      vmware.hv.datastore.size-CH-VIC-T2-DATASTORE06,% free].min(120m) > 5      3
137256      Free disk space is less than 10% on datastore CH-VIC-T2-DATASTORE08      vmware.hv.datastore.size-CH-VIC-T2-DATASTORE08,% free].min(120m) > 5      3
137295      Free disk space is less than 5% on datastore CH-VIC-T2-DATASTORE16       vmware.hv.datastore.size-CH-VIC-T2-DATASTORE16,% free].min(120m) > 2      4
137270      Free disk space is less than 10% on datastore CH-VIC-PACSDATA-T2SN-NR-12 vmware.hv.datastore.size-CH-VIC-PACSDATA-T2SN-NR-12,% free].min(120m) > 5 3
~~~~~

### GetZabbixDatastoreInfobyHost.ps1

This script will return all the datastore metrics for a given **ESX** hostid
(the script isn't really useful for running against non ESX hosts..)

e.g.
./GetZabbixDatastoreInfobyHost.ps1 [-hostid] 11161 | Format-Table

~~~~
  usedGB usedpc freepc   freeGB dsname                      freeTB  totalGB totalTB  usedTB
  ------ ------ ------   ------ ------                      ------  ------- -------  ------
    2.55   0.00      1  24573.2 CH-VIC-PACSDATA-T2SN-NR-15 23.9973 24575.75 23.9998  0.0025
 20482.6   0.83   0.17  4093.15 CH-VIC-T2-DATASTORE07       3.9972 24575.75 23.9998 20.0026
     2.6   0.00      1 25597.15 CH-VIC-TEMP-T2SN-NR-01     24.9972 25599.75 24.9998  0.0026
11484.12   0.37   0.63 19235.63 CH-VIC-PACSINF-T2SN-NR-02  18.7848 30719.75 29.9998  11.215
22114.64   0.90    0.1  2461.11 CH-VIC-PACSDATA-T2SN-NR-11  2.4034 24575.75 23.9998 21.5964
 4011.74   0.39   0.61  6228.01 CH-VIC-T2-DATASTORE13        6.082 10239.75  9.9998  3.9178
 20482.6   0.83   0.17  4093.15 CH-VIC-T2-DATASTORE09       3.9972 24575.75 23.9998 20.0026
 20482.6   0.83   0.17  4093.15 CH-VIC-T2-DATASTORE04       3.9972 24575.75 23.9998 20.0026
~~~~

### DrawDatastoreGraph.ps1

This script takes the input from GetZabbixDatastoreInfobyHost.ps1 and creates a jpg image representing a stacked bar chart for all the datastore in the ESX host.
(just like GetZabbixDatastoreInfobyHost.ps1, thisscript isn't really useful for running against non ESX hosts and their datastores..)

The default image name will be Hostnamemetrics.jpg byut can be altered using parameter below ($Hostname+$Filename)

e.g.  

.\GetZabbixDatastoreInfobyHost.ps1 11161  | .\DrawDatastoreGraph.ps1

Optional parameters:


    [Parameter(Mandatory=$false)] $Data,
    [Parameter(Mandatory=$false)] $Filename = 'metrics',
    [Parameter(Mandatory=$false)] $ChartTitle = 'Datastores Used & Free Percentages',
    [Parameter(Mandatory=$false)] $ChartWidth = 1000,
    [Parameter(Mandatory=$false)] $ChartHeight = 780,
    [Parameter(Mandatory=$false)] $ChartType = 'StackedBar100',
    [Parameter(Mandatory=$false)] $ChartLabels = 'Values',
    [Parameter(Mandatory=$false)] $ChartLabelsUnits = 'GB',
    [Parameter(Mandatory=$false)] $HostName = 'Hostname',
    [Parameter(Mandatory=$false)] $ToScreen = 'false'




