#!/bin/bash

PIDS=$(ps -ef|egrep 'aos(Core|Fw)'|awk '{print $2}')
for pid in ${PIDS}; do
  kill ${pid}
done

sleep 1

# force kill
PIDS=$(ps -ef|egrep 'aos(Core|Fw)'|awk '{print $2}')
for pid in ${PIDS}; do
  kill -9 ${pid}
done

PIDS=$(ps -ef|egrep 'aos(Domain|Fw)'|awk '{print $2}')
for pid in ${PIDS}; do
  kill ${pid}
done

  sleep 1

# force kill
  PIDS=$(ps -ef|egrep 'aos(Domain|Fw)'|awk '{print $2}')
for pid in ${PIDS}; do
    kill -9 ${pid}
done

# kill python
PYTHON=$(pgrep 'python2.7')
if [ "x${PYTHON}" != "x" ]; then
  kill ${PYTHON}
fi

/opt/adva/aos/bin/nidc.sh stop
pkill -9 nidc

# kill ntpd
#NTPD=$(pgrep 'ntpd')
#if [ "x${NTPD}" != "x" ]; then
#  kill ${NTPD}
#fi

rm -rf /tmp/aos*
rm -rf /tmp/fd*
pkill ovs*

exit 0
