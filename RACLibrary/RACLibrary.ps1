#####################################################################################
#
# Dell DRAC Common Functions Library
#
# Written by Ben Short
# http://practicaladmin.wordpress.com
#
# Uses RACADM Tool (Dell DRAC Tools). Get it from Third Party Utils on 
# my Website http://practicaladmin.wordpress.com/powershell-scripts/
#
# Include in other PS Scripts by using: 
#                 . "path\to\RACLibrary.ps1"
#
# Script Tested on Windows 7 Machine running Powershell 2.0
#
# 2013-11-18 1.1 
#    Mod - username and password added as parameters to functions get-RACConfig, 
#          set-RACConfigFromFile, set-RACConfig - modification added by Wojciech Sciesinski, wojciech@sciesinski.net
# 2012-02-28 1.01 Bugfix
#    Mod - Fixed Untrusted Certificate Error witg get-RACConfig & set-RACConfig
# 2012-01-23 1.0 Initial Release
# 
#
#####################################################################################
# Variables that need to be set for script to work

#Path to RACADM Executable
$racadmpath = "C:\Program Files (x86)\Dell\SysMgt\rac5"

# Username and Password for DRAC Account with configure access. Suggested that this
# be set in the script you which to use with, or configured as script command line
# arguments for security.

$username = "root"
$pass = "calvin"

#####################################################################################

#function Parse-RACGetOutput ($RACOutput)
# Code-reuse for the parsing output of rac-getconfig. Generally not used as
# a function call for user-scripts.

function Parse-RACGetOutput ($RACOutput) {
	$arrayobj = @()
	foreach ($line in $RACoutput) {
		if ($line -ne "") {
			$line = $line.Trim("# ")
			$result = $line.Split("=")
			$object = New-Object system.Object
			$object | add-member -MemberType NoteProperty -Name Property -value $result[0]
			$object | add-member -MemberType NoteProperty -Name DRACValue -value $result[1]
			$arrayobj += $object
			}
		}
	return $arrayobj
	}

# function get-RACConfig ([string]$hostname, [string]$RACConfigGroup, [int]$RACIndex, [string]$username, [string]$pass) 
# Gets the DRAC Config from the specified RAc Configuration Group and returns as an Object
# If $RACIndex (optional) is specified, will return Configuration from Specific Config Index Number

function get-RACConfig ([string]$hostname, [string]$RACConfigGroup, [int]$RACIndex, [string]$username, [string]$pass) {
	if ($RACIndex) {
		$output = & $racadmpath\racadm.exe -r $hostname -u $username -p $pass getconfig -g $RACConfigGroup -i $RACIndex |select -Skip 2
		}
	else {
		$output = & $racadmpath\racadm.exe -r $hostname -u $username -p $pass getconfig -g $RACConfigGroup |select -Skip 2 -ErrorAction
		}


	$result = Parse-RACGetOutput ($output)
	return $result

	}

# function set-RACConfigFromFile ([string]$hostname, [string]$RACConfigFile) 
# Sets the DRAC Configuration based on Configuration file $RACConfigFile
# Output of command returned as an Array of objects

function set-RACConfigFromFile ([string]$hostname, [string]$RACConfigFile, [string]$username, [string]$pass) {
	$arrayobj = @()
	$output = & $racadmpath\racadm.exe -r $hostname -u $username -p $pass config "-f" $RACConfigFile
	$output = $output -notmatch "    " |select -Skip 1
	
	foreach ($line in $output)	{
		$object = New-Object system.Object
		if ($line -eq "") {
			continue
			}
		if ($line -match "Verifying:" -or $line -match "Configuring:") {
			$result = $line.Split(": ")
			$object | add-member -MemberType NoteProperty -Name Servername -value $hostname
			$object | add-member -MemberType NoteProperty -Name Action -value $result[0]
			$object | add-member -MemberType NoteProperty -Name Element -value $result[2]
			$arrayobj += $object
			}
		else {
			$object | add-member -MemberType NoteProperty -Name Servername -value $hostname
			$object | add-member -MemberType NoteProperty -Name Action -value $line
			$arrayobj += $object
			}
		}
	return $arrayobj
	}

# function set-RACConfig ([string]$hostname, [string]$RACConfigGroup, [string]$RACConfigObject, [string]$RACConfigValue, [int]$RACIndex) 
# Sets the DRAC Configuration Object based on Config Group, Object and Value supplied.
# If $RACIndex (Optional) is set, Configuration will be applied to the particular index number.
# This is the major function of the library, and many other functions rely on it.

function set-RACConfig ([string]$hostname, [string]$RACConfigGroup, [string]$RACConfigObject, [string]$RACConfigValue, [int]$RACIndex, [string]$username, [string]$pass) {
	if ($RACIndex) {
		$output = & $racadmpath\racadm.exe -r $hostname -u $username -p $pass config -g $RACConfigGroup -o $RACConfigObject $RACConfigValue -i $RACIndex |select -Skip 2
		}
	else {
		$output = & $racadmpath\racadm.exe -r $hostname -u $username -p $pass Config -g $RACConfigGroup -o $RACConfigObject $RACConfigValue |select -Skip 2
		}
	$arrayobj = @()
	foreach ($line in $output) {
		if ($line -ne "") {
			$object = New-Object system.Object
			$object | add-member -MemberType NoteProperty -Name ServerName -value $hostname
			$object | add-member -MemberType NoteProperty -Name ConfigGroup -value $RACConfigGroup
			$object | add-member -MemberType NoteProperty -Name ConfigObject -value $RACConfigObject
			$object | add-member -MemberType NoteProperty -Name ConfigValue -value $RACConfigValue
			$object | add-member -MemberType NoteProperty -Name Result -value $line
			$arrayobj += $object
			}
		}
	return $arrayobj	
	}

# function set-RACNetworkIPv4 ([string]$hostname,[string]$RACIP, [string]$RACNetmask,[string]$RACGateway) 
# Configure basic IPv4 Settings for DRAC, including IP, Netmask and IP Gateway

function set-RACNetworkIPv4 ([string]$hostname,[string]$RACIP, [string]$RACNetmask,[string]$RACGateway) {
	$arrayobj = @()
	$setResultIP = set-RACConfig $hostname "cfgLanNetworking" "cfgNicIpAddress" $RACIP
	$setResultNetMask = set-RACConfig $hostname "cfgLanNetworking" "cfgNicNetmask" $RACNetMask
	$setResultGateway = set-RACConfig $hostname "cfgLanNetworking" "cfgNicgateway" $RACGateway
	$setResultDHCP = set-RACConfig $hostname "cfgLanNetworking" "cfgNicUseDHCP" "0"
	$setResultDNS1 = set-RACConfig $hostname "cfgLanNetworking" "cfgDNSServer1" $RACDNS1
	$setResultDNS2 = set-RACConfig $hostname "cfgLanNetworking" "cfgDNSServer1" $RACDNS2
	$arrayobj = ($setResultIP , $setResultNetMask , $setResultGateway , $setResultDHCP , $setResultDNS1 , $setResultDNS2)
	return $arrayobj
	}
	
# function set-RACNetworkDNS([string]$hostname,[string]$RACDNS1, [string]$RACDNS2,[string]$RACDNSName,[string]$RACDNSDomain) {
# Configure DNS Settings for DRAC interface

function set-RACNetworkDNS([string]$hostname,[string]$RACDNS1, [string]$RACDNS2,[string]$RACDNSName,[string]$RACDNSDomain) {
	$arrayobj = @()
	$setResultDHCP = set-RACConfig $hostname "cfgLanNetworking" "cfgDNSDomainNamefromDHCP" 0
	$setResultDNS1 = set-RACConfig $hostname "cfgLanNetworking" "cfgDNSServer1" $RACDNS1
	$setResultDNS2 = set-RACConfig $hostname "cfgLanNetworking" "cfgDNSServer2" $RACDNS2
	$setResultDNSName = set-RACConfig $hostname "cfgLanNetworking" "cfgDNSRACName" $RACDNSName
	$setResultDNSDomain = set-RACConfig $hostname "cfgLanNetworking" "cfgDNSDomainName" $RACDNSDomain
	$arrayobj = ($setResultDHCP , $setResultDNS1 , $setResultDNS2, $setResultDNSName, $setResultDNSDomain)
	return $arrayobj
	}

# function set-RACNetworkVLAN ([string]$hostname, [int]$RACVLANEnable, [int]$RACVLANID, [int]$RACVLANPri) 
# Configure VLAN Settinsg for DRAC Interface

function set-RACNetworkVLAN ([string]$hostname, [int]$RACVLANEnable, [int]$RACVLANID, [int]$RACVLANPri) {
	$arrayobj = @()
	$setResultVLANEnable = set-RACConfig $hostname "cfgLanNetworking" "cfgNicVlanEnable" $RACVLANEnable
	$setResultVLANID = set-RACConfig $hostname "cfgLanNetworking" "cfgNicVLANID" $RACVLANID
	$setResultVLANPri = set-RACConfig $hostname "cfgLanNetworking" "cfgNicVlanPriorty" $RACVLANPri
	$arrayobj = ($setResultVLANEnable, $setResultVLANID, $setResultVLANPri)
	return $arrayobj
	}

# function set-RACSyslog([string]$hostname,[int]$RACSysLogEnable, [string]$RACSyslogLServer1,[string]$RACSyslogLServer2,[string]$RACSyslogLServer3,[int]$RACSyslogPort) 
# Configure Syslog Settings for DRAC Interface

function set-RACSyslog([string]$hostname,[int]$RACSysLogEnable, [string]$RACSyslogLServer1,[string]$RACSyslogLServer2,[string]$RACSyslogLServer3,[int]$RACSyslogPort) {
	$arrayobj = @()
	$result1 = set-RACConfig $hostname "cfgremoteHosts" "cfgRhostsSyslogEnable" $RACSysLogEnable
	$result2 = set-RACConfig $hostname "cfgremoteHosts" "cfgRhostsSyslogServer1" $RACSyslogLServer1
	$result3 = set-RACConfig $hostname "cfgremoteHosts" "cfgRhostsSyslogServer2" $RACSyslogLServer2
	$result4 = set-RACConfig $hostname "cfgremoteHosts" "cfgRhostsSyslogServer3" $RACSyslogLServer3
	$result5 = set-RACConfig $hostname "cfgremoteHosts" "cfgRhostsSyslogPort" $RACSyslogPort
	$arrayobj = ($result1, $result2, $result3, $result4, $result5)
	return $arrayobj
	}
	
# function set-RACTftp([string]$hostname,[int]$RACTftpEnable, [string]$RACTftpIP,[string]$RACTftpPath) 
# Configure TFTP Settings for DRAC Interface

function set-RACTftp([string]$hostname,[int]$RACTftpEnable, [string]$RACTftpIP,[string]$RACTftpPath) {
	$arrayobj = @()
	$result1 = set-RACConfig $hostname "cfgremoteHosts" "cfgRhostsFwUpdateTftpEnable" $RACTftpEnable
	$result2 = set-RACConfig $hostname "cfgremoteHosts" "cfgRhostsFwUpdateIpAddr" $RACTftpIP
	$result3 = set-RACConfig $hostname "cfgremoteHosts" "cfgRhostsFwUpdatePath" $RACTftpPath
	$arrayobj = ($result1, $result2, $result3)
	return $arrayobj
	}

# function set-RACEmailAlert([string]$hostname,[int]$RACEmailIndex, [int]$RACEmailAlertEnabled,[string]$RACEmailAlertAddress,[string]$RACEMailAlertCustomMsg) 
# Configure RAC Email Alert Settings. Index required

function set-RACEmailAlert([string]$hostname,[int]$RACEmailIndex, [int]$RACEmailAlertEnabled,[string]$RACEmailAlertAddress,[string]$RACEMailAlertCustomMsg) {
	$arrayobj = @()
	$result1 = set-RACConfig $hostname "cfgEmailAlert" "cfgEmailAlertEnable" $RACEmailAlertEnabled -RACIndex $RACEmailIndex
	$result2 = set-RACConfig $hostname "cfgEmailAlert" "cfgEmailAlertAddress" $RACEmailAlertAddress -RACIndex $RACEmailIndex
	if ($RACEMailAlertCustomMsg) {
		$result3 = set-RACConfig $hostname "cfgEmailAlert" "cfgEmailAlertCustomMsg" $RACEMailAlertCustomMsg -RACIndex $RACEmailIndex
		$arrayobj = ($result1, $result2, $result3)
		}
	else {
		$arrayobj = ($result1, $result2)
		}
	return $arrayobj
	}

# function set-RACSNMP([string]$hostname,[int]$RACSNMPEnable, [string]$RACSNMPCommunity) 
# Configure SNMP Settings for DRAC

function set-RACSNMP([string]$hostname,[int]$RACSNMPEnable, [string]$RACSNMPCommunity) {
	$arrayobj = @()
	$result1 = set-RACConfig $hostname "cfgOobSnmp" "cfgOobSnmpAgentEnable" $RACSNMPEnable
	$result2 = set-RACConfig $hostname "cfgOobSnmp" "cfgOobSnmpAgentCommunity" $RACSNMPCommunity
	$arrayobj = ($result1, $result2)
	return $arrayobj
	}

# function set-RACSSLInfo([string]$hostname,[int]$RACSSLIndex,[int]$RACSSLKeySize, [string]$RACSSLCN,[string]$RACSSLOrgName,[string]$RACSSLOU,[string]$RACSSLLocality, [string]$RACSSLState, [string]$RACSSLCountry, [string]$RACSSLEmail) 
# Configure the SSL Certificate information for DRAC Interface

function set-RACSSLInfo([string]$hostname,[int]$RACSSLIndex,[int]$RACSSLKeySize, [string]$RACSSLCN,[string]$RACSSLOrgName,[string]$RACSSLOU,[string]$RACSSLLocality, [string]$RACSSLState, [string]$RACSSLCountry, [string]$RACSSLEmail) {
	$arrayobj = @()
	$result2 = set-RACConfig $hostname "cfgracsecuritydata" "cfgRacSecCsrKeySize" $RACSSLKeySize -RACIndex $RACSSLIndex
	$result3 = set-RACConfig $hostname "cfgracsecuritydata" "cfgRacSecCsrCommonName" $RACSSLCN -RACIndex $RACSSLIndex
	$result4 = set-RACConfig $hostname "cfgracsecuritydata" "cfgRacSecCsrOrganizationName" $RACSSLOrgName -RACIndex $RACSSLIndex
	$result5 = set-RACConfig $hostname "cfgracsecuritydata" "cfgRacSecCsrOrganizationUnit" $RACSSLOU -RACIndex $RACSSLIndex
	$result6 = set-RACConfig $hostname "cfgracsecuritydata" "cfgRacSecCsrLocalityName" $RACSSLLocality -RACIndex $RACSSLIndex
	$result7 = set-RACConfig $hostname "cfgracsecuritydata" "cfgRacSecCsrStateName" $RACSSLState -RACIndex $RACSSLIndex
	$result8 = set-RACConfig $hostname "cfgracsecuritydata" "cfgRacSecCsrCountryCode" $RACSSLCountry -RACIndex $RACSSLIndex
	$result9 = set-RACConfig $hostname "cfgracsecuritydata" "cfgRacSecCsrEmailAddr" $RACSSLEmail -RACIndex $RACSSLIndex
	$arrayobj = ($result1, $result2, $result3, $result4, $result5, $result6, $result7, $result8, $result9)
	return $arrayobj
	}

# function Test-RACAlerts ([string]$hostname,[int]$RACAlertIndex)
# Test the Email and SNMP Alert functionality of the DRAC and return results as an object
function Test-RACAlerts ([string]$hostname,[int]$RACAlertIndex) {
	$arrayobj = @()
	$object1 = New-Object System.Object
	$object2 = New-Object System.Object
	$result1 = & $racadmpath\racadm.exe -r $hostname -u $username -p $pass testemail -i $RACAlertIndex |select -Skip 2 
	$result1 = [string]::Join(" ",$result1)
	$result2 = & $racadmpath\racadm.exe -r $hostname -u $username -p $pass testtrap -i $RACAlertIndex  | select -Skip 2
	$result2 = [string]::Join(" ",$result2)
	$object1 | add-member -MemberType NoteProperty -Name Servername -value $hostname
	$object1 | add-member -MemberType NoteProperty -Name AlertFunction -value "EMAIL"
	$object1 | add-member -MemberType NoteProperty -Name ActionResult -value $result1
	$object2 | add-member -MemberType NoteProperty -Name Servername -value $hostname
	$object2 | add-member -MemberType NoteProperty -Name AlertFunction -value "SNMPTrap"
	$object2 | add-member -MemberType NoteProperty -Name ActionResult -value $result2
	$arrayobj = ($object1, $object2)
	return $arrayobj
	}

# Ping-RAC ($RACHostname)
# Perform basic Ping test to make sure you can access the RAC
# Returns True or False (Boolean) depending on Success/Failure

function Ping-RAC ([string]$RACHostName) {
	$ping  = new-object System.Net.NetworkInformation.Ping
	try { 
		$Reply = $ping.send($RAChostname,500)
		}
	catch { 
		return $false
		}
	if ($Reply.Status -eq "Success") {
		return $true
		}
	}