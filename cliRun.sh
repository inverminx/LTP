#!/bin/bash

function template {
	templateFile=$1
	targetFile=${1}.expect
	>$targetFile
	cp -r $templateFile $targetFile
	while read configLine; do
		key=$(echo "$configLine"|awk {'print $1'})
		value=$(echo "$configLine"|awk {'print $2'}|sed -r s/\"//g|sed -e 's/[\/&]/\\&/g')
		sed -i "s/$key/$value/g" $targetFile
	done<config.ini
}

function info {
	echo "$(date +'%d-%m-%Y %H:%M:%S')|INFO|$$|$1"
}	

function runScript {
	/usr/bin/expect -f "$1"
}

function templateAndRun {
	template $1
	runScript ${1}.expect
}

function waitForNID {
	until nc -vzw 2 $1 22; do sleep 2; done

}

if [[ $1 == "" ]];then
	echo "usage $0 cli_file"
	exit
fi

host=$(cat config.ini |grep "{{host}}"|awk {'print $2'})

templateAndRun $1

