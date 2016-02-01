#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 newConfigFile novaConfigFile neutronConfigFile"
	exit 1
fi

novaConfigFile=$2
neutronConfigFile=$3
newConfigFile=$1

fixedKey="$(cat $novaConfigFile | grep "^fixed_key" | awk -F '=' {'print $2'})"
rabbitPassword="$(cat $novaConfigFile | grep "^rabbit_password" | awk -F '=' {'print $2'})"
neutronAdminPassword="$(cat $novaConfigFile | grep "^neutron_admin_password" | awk -F '=' {'print $2'})"
integrationBridge="$(cat $novaConfigFile | grep "^linuxnet_ovs_integration_bridge" | awk -F '=' {'print $2'})"
neutronRegionName="$(cat $novaConfigFile | grep "^neutron_region_name" | awk -F '=' {'print $2'})"
glanceApiServerHostPort="$(cat $novaConfigFile | grep "^glance_api_servers" | awk -F '=' {'print $2'})"
memcachedServerHostPort="$(cat $novaConfigFile | grep "^memcached_servers" | awk -F '=' {'print $2'})"
rabbitHostPort="$(cat $novaConfigFile | grep "^rabbit_hosts" | awk -F '=' {'print $2'})"
ctrlApiNetworkAddress="$(echo $rabbitHostPort | awk -F ':' {'print $1'})"
mgmtNetworkAddress="$(cat $novaConfigFile | grep "^vncserver_proxyclient_address" | awk -F '=' {'print $2'})"
neutronAdminAuthUrlPort="$(cat $neutronConfigFile | grep "^auth_port" | awk -F '=' {'print $2'})"
novaPassword="$(cat $novaConfigFile | grep "^connection=" | awk -F ':' {'print $3'} | awk -F '@' {'print $1'})"
neutronUrlPort="$(cat $neutronConfigFile | grep "^bind_port" | awk -F '=' {'print $2'})"


echo "{{isVerbose}} True" > $newConfigFile
echo "{{isDebug}} True" >>$newConfigFile
echo "{{host}}" >> $newConfigFile
echo "{{ntpServer}}" >> $newConfigFile
echo "{{controllerExternalAddress}}" >> $newConfigFile
echo "{{mgmtNetworkAddress}}"  >> $newConfigFile
echo "{{ctrlMgmtNetworkAddress}} $ctrlApiNetworkAddress" >> $newConfigFile
echo "{{ctrlApiNetworkAddress}} $ctrlApiNetworkAddress" >> $newConfigFile
echo "{{rabbitHostPort}} $rabbitHostPort" >> $newConfigFile
echo "{{memcachedServerHostPort}} $memcachedServerHostPort" >> $newConfigFile
echo "{{glanceApiServerHostPort}} $glanceApiServerHostPort" >> $newConfigFile
echo "{{neutronAdminAuthUrlPort}} $neutronAdminAuthUrlPort" >> $newConfigFile
echo "{{neutronRegionName}} $neutronRegionName" >> $newConfigFile
echo "{{neutronAdminPassword}} $neutronAdminPassword" >> $newConfigFile
echo "{{novaPassword}} $novaPassword" >> $newConfigFile
echo "{{fixedKey}} $fixedKey" >> $newConfigFile
echo "{{rabbitPassword}} $rabbitPassword" >> $newConfigFile
echo "{{neutronUrlPort}} $neutronUrlPort" >> $newConfigFile
echo "{{integrationBridge}} $integrationBridge" >> $newConfigFile
echo "{{serverPort}} 9022" >> $newConfigFile
echo "{{aosAppsPort}} 8888" >> $newConfigFile
echo "{{nidUser}} \"root\"" >> $newConfigFile
echo "{{serverUser}} \"root\"" >> $newConfigFile
echo "{{nidPassword}} \"ChgMeNOW\"" >> $newConfigFile
echo "{{serverPassword}}" >> $newConfigFile
echo "{{vimVlan}}" >> $newConfigFile
echo "{{vimTunnelPort}} \"network-1-1-1-1\"" >> $newConfigFile
echo "{{vimTunnelCIR}} 500000000" >> $newConfigFile
echo "{{vimTunnelEIR}} 0" >> $newConfigFile
echo "{{cpuCoreSetting}} 4-15" >> $newConfigFile
