#!/bin/bash

fixedKey="$(cat $2 | grep "^fixed_key" | awk -F '=' {'print $2'})"
rabbitPassword="$(cat $2 | grep "^rabbit_password" | awk -F '=' {'print $2'})"
neutronAdminPassword="$(cat $2 | grep "^neutron_admin_password" | awk -F '=' {'print $2'})"
integrationBridge="$(cat $2 | grep "^linuxnet_ovs_integration_bridge" | awk -F '=' {'print $2'})"
neutronRegionName="$(cat $2 | grep "^neutron_region_name" | awk -F '=' {'print $2'})"
glanceApiServerHostPort="$(cat $2 | grep "^glance_api_servers" | awk -F '=' {'print $2'})"
memcachedServerHostPort="$(cat $2 | grep "^memcached_servers" | awk -F '=' {'print $2'})"
rabbitHostPort="$(cat $2 | grep "^rabbit_hosts" | awk -F '=' {'print $2'})"
ctrlApiNetworkAddress="$(echo $rabbitHostPort | awk -F ':' {'print $1'})"
mgmtNetworkAddress="$(cat $2 | grep "^vncserver_proxyclient_address" | awk -F '=' {'print $2'})"
neutronAdminAuthUrlPort="$(cat $3 | grep "^auth_port" | awk -F '=' {'print $2'})"
novaPassword="$(cat $2 | grep "^connection=" | awk -F ':' {'print $3'} | awk -F '@' {'print $1'})"
neutronUrlPort="$(cat $3 | grep "^bind_port" | awk -F '=' {'print $2'})"


echo "{{isVerbose}} True" > $1
echo "{{host}}" >> $1
echo "{{ntpServer}}" >> $1
echo "{{controllerExternalAddress}}" >> $1
echo "{{mgmtNetworkAddress}} $mgmtNetworkAddress" >> $1
echo "{{ctrlMgmtNetworkAddress}} $ctrlApiNetworkAddress" >> $1
echo "{{ctrlApiNetworkAddress}} $ctrlApiNetworkAddress" >> $1
echo "{{rabbitHostPort}} $rabbitHostPort" >> $1
echo "{{memcachedServerHostPort}} $memcachedServerHostPort" >> $1
echo "{{glanceApiServerHostPort}} $glanceApiServerHostPort" >> $1
echo "{{neutronAdminAuthUrlPort}} $neutronAdminAuthUrlPort" >> $1
echo "{{neutronRegionName}} $neutronRegionName" >> $1
echo "{{neutronAdminPassword}} $neutronAdminPassword" >> $1
echo "{{novaPassword}} $novaPassword" >> $1
echo "{{fixedKey}} $fixedKey" >> $1
echo "{{rabbitPassword}} $rabbitPassword" >> $1
echo "{{neutronUrlPort}} $neutronUrlPort" >> $1
echo "{{integrationBridge}} $integrationBridge" >> $1
echo "{{serverPort}} 9022" >> $1
echo "{{aosAppsPort}} 8888" >> $1
echo "{{nidUser}} \"root\"" >> $1
echo "{{serverUser}} \"root\"" >> $1
echo "{{nidPassword}} \"ChgMeNOW\"" >> $1
echo "{{serverPassword}}" >> $1
echo "{{vimVlan}}" >> $1
echo "{{vimTunnelPort}} \"network-1-1-1-1\"" >> $1
echo "{{vimTunnelCIR}} 500000000" >> $1
echo "{{vimTunnelEIR}} 0" >> $1

