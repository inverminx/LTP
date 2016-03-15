#!/bin/bash
startTime=$(date +%s)
supportedAosVersions="0.8 0.9 1.0"
function getTime {
info "Script run-time = [$(($(date +%s)-$startTime))] sec"
}

function getAttr {
key=$1
value=$(cat ${configFile} |grep "{{$key}}"|awk {'print $2'})
if [[ "$value" == "" ]];then exit 1;fi
echo $value
}

function isAosVersionValid {
if [[ $1 != *"$supportedAosVersions"* ]]; then
	echo "### AOS VERSION = $1 is configured ###"
else 
  echo "AOS version $1 is not supported by this LTP script."
  echo "Supported versions are [$supportedAosVersions] only"
  exit 1
fi
}

function isExpectExists {
which expect >/dev/null 2>&1
status=$?
if [[ "$status" != "0" ]]; then
	echo "Expect is not installed! quitting..."
	getTime
	exit 1
fi
}

function template {
	info "Removing empty lines from config file [$configFile] ..."
	sed -i '/^$/d' $configFile
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
#Modified for AOS0.9
until [[ $(curl -k -s -o /dev/null -w "%{http_code}" -X GET -H 'Content-Type:application/json; ext=nn' -H 'X-Auth-Token: your auth token'  https://${host}:${aosAppsPort}/aos-api/mit/me/1/) == "401" ]]; do sleep 2; info 'Waiting for AOS Applications startup';done
}

function getToken {
# This section is related to AOS 0.9 only !

token=$(curl -k --silent -i -X POST -H "Content-Type:application/json; ext=nn" -d '{"in":{"pswd":"CHGME.1","un":"admin"}}' "https://${host}:${aosAppsPort}/aos-api?actn=lgin"| grep -o "X-Auth-Token:.*" | sed -e "s/X-Auth-Token:\s//g")
if [[ "$token" == "" ]];then
	info "Error getting token, quitting..."
	getTime
	exit 1
fi


}


function createPhysNets {
info "Creating PhysNets - AOS version $aosVersion mode"
case $aosVersion in
0.8)
	baseURI="http://${host}:${aosAppsPort}/aos-api"
	header="Content-Type:application/json+nicknames"
	until curl -s -X GET -H "$header" -H 'X-Auth-Token: your auth token'  http://${host}:${aosAppsPort}/aos-api/mit/me/1/ |grep 'Galaxy far away' >>/dev/null 2>&1; do sleep 2; info 'Waiting for AOS Applications startup';done
	;;
0.9)
	baseURI="https://${host}:${aosAppsPort}/aos-api"
	header="Content-Type:application/json+nicknames"
	token=$(curl -k --silent -i -X POST -H "$header" -d '{"in":{"pswd":"CHGME.1","un":"admin"}}' "${baseURI}?actn=lgin"| grep -o "X-Auth-Token:.*" | sed -e "s/X-Auth-Token:\s//g")
	until [[ $(curl -k -s -o /dev/null -w "%{http_code}" -X GET -H "$header" -H 'X-Auth-Token: $token'  ${baseURI}/mit/me/1/) == "401" ]]; do sleep 2; info 'Waiting for AOS Applications startup';done
  ;;
1.0)
	baseURI="https://${host}:${aosAppsPort}/aos-api"
	header="Content-Type:application/json; ext=nn"
	token=$(curl -k --silent -i -X POST -H "$header" -d '{"in":{"pswd":"CHGME.1","un":"admin"}}' "${baseURI}?actn=lgin"| grep -o "X-Auth-Token:.*" | sed -e "s/X-Auth-Token:\s//g")
	until [[ $(curl -k -s -o /dev/null -w "%{http_code}" -X GET -H "$header" -H 'X-Auth-Token: $token'  ${baseURI}/mit/me/1/) == "401" ]]; do sleep 2; info 'Waiting for AOS Applications startup';done
	;;
esac







curl -k -s -o /dev/null -w "%{http_code}"  -X POST -H "$header" -H "X-Auth-Token: $token" -d '{"id": "'${nidNet1}'", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,1/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' $baseURI/mit/me/1/vpnet/1
curl -k -s -o /dev/null -w "%{http_code}"  -X POST -H "$header" -H "X-Auth-Token: $token" -d '{"id": "'${nidNet2}'", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,2/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' $baseURI/mit/me/1/vpnet/2
curl -k -s -o /dev/null -w "%{http_code}"  -X POST -H "$header" -H "X-Auth-Token: $token" -d '{"id": "'${nidAcc3}'", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,3/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' $baseURI/mit/me/1/vpnet/3
curl -k -s -o /dev/null -w "%{http_code}"  -X POST -H "$header" -H "X-Auth-Token: $token" -d '{"id": "'${nidAcc4}'", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,4/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' $baseURI/mit/me/1/vpnet/4
curl -k -s -o /dev/null -w "%{http_code}"  -X POST -H "$header" -H "X-Auth-Token: $token" -d '{"id": "'${nidAcc5}'", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,5/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' $baseURI/mit/me/1/vpnet/5
curl -k -s -o /dev/null -w "%{http_code}"  -X POST -H "$header" -H "X-Auth-Token: $token" -d '{"id": "'${nidAcc6}'", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,6/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' $baseURI/mit/me/1/vpnet/6
curl -k -s -o /dev/null -w "%{http_code}"  -X POST -H "$header" -H "X-Auth-Token: $token" -d '{"id": "phy-local", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' $baseURI/mit/me/1/vpnet/7

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
scp -rp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort nova.conf.template.expect ${host}:/etc/nova/nova.conf
scp -rp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort neutron.conf.template.expect ${host}:/etc/neutron/neutron.conf
scp -rp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort ml2_conf.ini.template.expect ${host}:/etc/neutron/plugins/ml2/ml2_conf.ini

info "Done."
}

function copyAgentFiles {

info "Copying nova and neutron start scripts to server..."
scp -rp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort neutron-adva-agent ${host}:/opt/adva/aos/bin
scp -rp o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort nova-adva-compute ${host}:/opt/adva/aos/bin

info "Done."
}

function copyAosStartScripts {

info "Copying AOS and neutron start scripts to server..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort start.sh ${host}:/opt/adva/aos
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort stop.sh ${host}:/opt/adva/aos
info "Done."
}

function copyNtpConfigFile {
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $serverPort ntp.conf ${host}:/var/lib/ntp/ntp.conf
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
	getTime
	exit 1
fi

if [[ $2 == "skip" ]]; then
	skip="TRUE"
else
	skip="FALSE"
fi

## Extracting keys from from configuration file ##

key=aosVersion;aosVersion=$(getAttr $key);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=host;host=$(getAttr $key);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=ntpServer;ntpServer=$(getAttr $key);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=vimVlan;vimVlan=$(getAttr vimVlan);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=serverPort;serverPort=$(getAttr serverPort);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=aosAppsPort;aosAppsPort=$(getAttr aosAppsPort);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=physicalNet1Network;nidNet1=$(getAttr physicalNet1Network);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=physicalNet2Network;nidNet2=$(getAttr physicalNet2Network);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=physicalAcc3Network;nidAcc3=$(getAttr physicalAcc3Network);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=physicalAcc4Network;nidAcc4=$(getAttr physicalAcc4Network);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=physicalAcc5Network;nidAcc5=$(getAttr physicalAcc5Network);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=physicalAcc6Network;nidAcc6=$(getAttr physicalAcc6Network);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi
key=ntpServer;ntpServer=$(getAttr ntpServer);if [ $? -ne 0 ]; then info "Error extracting key {{$key}} from configuration file $configFile - Quitting !!";exit 1;fi

info "Starting Low Touch Provisioning for proNID(vm)"
isExpectExists
isAosVersionValid $aosVersion
info "Testing connection to NID on [$host]..."
waitForNID
#info "Testing connection to server..."
#waitForServer
#templateAndRun cli_restartServer
info "Applying default-db on NID"

if [[ "$skip" == "TRUE" ]]; then
	 info "Skipping default DB on the NID..."
	 info "Rebooting server..."
	 templateAndRun cli_serverHardwareReset
else 
	templateAndRun cli_defaultDB
fi
info "Waiting for NID startup..."
waitForNID
#info "Seding Hardware reboot for server"
#templateAndRun cli_serverHardwareReset
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
info "Copying start scripts..."
copyAosStartScripts
info "Continue server configuration ...."
templateAndRun cli_serverConfiguration
info "Server configuration completed."
#info "waiting for AOS Application startup..."
#waitForAosApps
#info "AOS Apps are online!"
#info "Configuration via rest-api [CREATE]..."
#configureRestAPI POST
#info "Getting Token for rest-api"
#getToken
info "Creating physical networks..."
createPhysNets
template nova.conf.template
template neutron.conf.template
template ml2_conf.ini.template
copyConfigFiles
copyAgentFiles
copyNtpConfigFile
templateAndRun cli_startAgents
info "Clearing .expect files ..."
rm -f *.expect
getTime
info "*************************************"
info "              Finished!"
info "*************************************"
