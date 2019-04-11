# MaaSScripts Documentation

## Introduction

These tools access the live MaaS (Zabbix) environment via its API to perform various useful functions.
The design philosophy is that each script: 
  * does one thing
  * returns 'powershell objects' as output
  * has at least 'pipeable' output (some have pipeable inputs too)

### Authoristation and Credentials

All access to Zabbix is using your own credentials.
You must log into Zabbix to use any of the scripts.
ALl the scripts will prompt for login, if you are not logged in, and store your credentials in an encrypted PSCredential object xml file
There is a specific script you can use, if you wish, to set your credentials and then all subsequent called scripts will use thos stored/set credentials (see Functions-SetMaaSCredentials)



## Functions

### SetMaasCredentials

This script will open a login dialog into to which you put your username and password (Zabbix authenticate in ARGH) and then it stores the resultant PSCredential object into MaaSCredentials.xml




