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



## Functions

### SetZabbixCredentials

This script will open a login dialog into to which you put your username and password (Zabbix authentication) and then it stores the resultant 'PSCredential object' into zabbixcredentials.xml in the directory where the scripts are run from.

### GetZabbixGroups.ps1

This script will return all the groups in Zabbix

### GetZabbixHost.ps1

This script will return the Zabbix host name for a given hostid
e.g.

~~~~
  host        hostid name
  ----        ------ ----
  ASADLBAAS01 11611  ASADLBAAS01
~~~~




