#!/bin/bash

function isExpectExists {

which expect
status=$?
if [[ "$status" != "0" ]]; then
	echo "Expect is not installed! quitting..."
	exit 1
fi


}
function template {
	changesCounter=0
	templateFile=$1
	targetFile=${1}.expect
	info "Templating $templateFile"
	>$targetFile
	cp -r $templateFile $targetFile
	paramsCount=$(grep -o '{{' $templateFile | wc -l)
	info "Found $paramsCount parameters on $templateFile"
	if [[ "$paramsCount" == "0" ]];then info "Nothing to change";return;fi
	while read configLine; do
		key=$(echo "$configLine"|awk {'print $1'})
		value=$(echo "$configLine"|awk {'print $2'}|sed -r s/\"//g|sed -e 's/[\/&]/\\&/g')
		if [[ "$(grep $key $targetFile>>/dev/null;echo $?)" == "0" ]];then (( changesCounter++ ));fi
		sed -i "s/$key/$value/g" $targetFile
	done<${configFile}
	paramsLeft=$(grep -o '}}' $targetFile | wc -l)
	let paramsChanged=paramsCount-paramsLeft
	info "$paramsChanged parameters has been changed successfully"
}

function info {
	echo "$(date +'%d-%m-%Y %H:%M:%S')|INFO|$$|$1" | tee $logFile
}	

function runScript {
	/usr/bin/expect -f "$1"
}

function templateAndRun {
	template $1
	runScript ${1}.expect
}

function waitForNID {
	until nc -vzw 2 $host 22 >> $logFile 2>&1; do sleep 2; info "waiting for NID $host to be accessible on port 22"; done

}
function waitForServer {
	until nc -vzw 2 $host $serverPort >> $logFile 2>&1; do sleep 2; info "waiting for server $host to be accessible on port $serverPort"; done
}
function waitForAosApps {
until curl -s -X GET -H 'Content-Type:application/json+nicknames' -H 'X-Auth-Token: your auth token'  http://${host}:${aosAppsPort}/aos-api/mit/me/1/ |grep 'Galaxy far away' >>/dev/null 2>&1; do sleep 2; info 'Waiting for AOS Applications startup';done
}

function configureRestAPI {
curlCommand=$1
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X  $curlCommand -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "nid-acc3", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,3/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/1); echo -e "vpnet 1 $curlCommand command respone Code [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X  $curlCommand -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "nid-acc4", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,4/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/2); echo -e "vpnet 2 $curlCommand command respone Code [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X  $curlCommand -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "nid-acc5", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,5/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/3); echo -e "vpnet 3 $curlCommand command respone Code [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X  $curlCommand -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "nid-acc6", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,6/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/4); echo -e "vpnet 4 $curlCommand command respone Code [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X  $curlCommand -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "nid-net1", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,1/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/5); echo -e "vpnet 5 $curlCommand command respone Code [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X  $curlCommand -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "nid-net2", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,2/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/6); echo -e "vpnet 6 $curlCommand command respone Code [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X  $curlCommand -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "phy-local", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/7); echo -e "vpnet 7 $curlCommand command respone Code [$exitCode]"


exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token"  http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/1); echo -e "Respone Code for vpnet 1 GET [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token"  http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/2); echo -e "Respone Code for vpnet 2 GET [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token"  http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/3); echo -e "Respone Code for vpnet 3 GET [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token"  http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/4); echo -e "Respone Code for vpnet 4 GET [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token"  http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/5); echo -e "Respone Code for vpnet 5 GET [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token"  http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/6); echo -e "Respone Code for vpnet 6 GET [$exitCode]"
exitCode=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token"  http://${host}:${aosAppsPort}/aos-api/mit/me/1/vpnet/7); echo -e "Respone Code for vpnet 7 GET [$exitCode]"
}

function copyConfigFiles {

info "Copying templated configuration files to server..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort nova.conf.template.expect ${host}:/etc/nova/nova.conf
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort neutron.conf.template.expect ${host}:/etc/neutron/neutron.conf
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort ml2_conf.ini.template.expect ${host}:/etc/neutron/plugins/ml2/ml2_conf.ini

info "Done."
}

logFile="ltp.log"
if [[ $1 == "" ]];then 
	configFile=config.ini
else
	configFile=$1
fi
if [ ! -f "$configFile" ];then
	echo "Configuration file $configFile does not exist!"
	exit 1
fi

host=$(cat ${configFile} |grep "{{host}}"|awk {'print $2'})
serverPort=$(cat ${configFile} |grep "{{serverPort}}"|awk {'print $2'})
aosAppsPort=$(cat ${configFile} |grep "{{aosAppsPort}}"|awk {'print $2'})
info "Starting Low Touch Provisioning for proNID(vm)"
isExpectExists

info "Testing connection to NID on [$host]..."
waitForNID
#info "Testing connection to server..."
#waitForServer
#templateAndRun cli_restartServer
info "Applying default-db on NID"
templateAndRun cli_defaultDB

info "Waiting for NID startup..."
waitForNID
info "Seding Hardware reboot for server"
templateAndRun cli_serverHardwareReset
info "Test SSH connectivity for server..."
waitForServer

info "Starting NID configuration..."
templateAndRun cli_nidConfiguration
info "NID Configuration completed."
info "Checking of server is ready to accept configuration..."
waitForServer
info "Server is ready!"
info "Starting Server interfaces configuration..."
templateAndRun cli_serverNetworkInterfacesConfiguration
info "Continue server configuration ...."
templateAndRun cli_serverConfiguration
info "Server configuration completed."
info "waiting for AOS Application startup..."
waitForAosApps
info "AOS Apps are online!"
info "Configuration via rest-api [CREATE]..."
configureRestAPI POST
template nova.conf.template
template neutron.conf.template
template ml2_conf.ini.template
copyConfigFiles
templateAndRun cli_startAgents
info "Clearing .expect files ..."
rm -f *.expect
info "*************************************"
info "              Finished!"
info "*************************************"
