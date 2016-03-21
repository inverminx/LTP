#!/bin/bash

ulimit -c unlimited
#echo "/tmp/core.%e.%p" > /proc/sys/kernel/core_pattern

#BASE_DIR=/opt/adva
AOS_HOME=`pwd`
export AOS_HOME

LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${AOS_HOME}/lib:/targ/arch/x86_64-vm-linux-gnu/modes/eos/usr/lib:/targ/arch/x86_64-nfv-linux-gnu/modes/default/usr/lib64
export LD_LIBRARY_PATH

modprobe tipc
ipcrm -M 1

rm -rf /dev/shm/*
rm -rf /var/opt/adva/aos/db
rm -rf /var/db/*
rm -rf /opt/adva/var/db/
mkdir -p /opt/adva/var/db/
mkdir -p /var/opt/adva/aos/db
mkdir -p /var/opt/adva/log
mkdir -p /var/opt/adva/aos/db/aplfw


echo "Deleting All virtual machines..."
for instance in $(virsh list --all|grep -v state|grep -v "\-\-\-"|awk {'print $2'});do virsh undefine $instance;done
echo "Cleaning logs..."
>/var/tmp/serverLog.log


SIRM=${AOS_HOME}/bin/aosCoreSirm
${SIRM} -c ${AOS_HOME}/etc/core-apps/sirm/sirmConfigurationFile.json -p ${AOS_HOME} | tee -a /var/tmp/serverLog.log 2>&1 &
#${SIRM} -c ${AOS_HOME}/sirm_no_apl.json > output.txt 2>&1
