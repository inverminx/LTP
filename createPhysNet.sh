#!/bin/bash

curl -X POST -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "ten-mng", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,1/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' http://10.52.150.152:8888/aos-api/mit/me/1/vpnet/1

curl -X POST -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "edge-net1", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,1/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' http://10.52.150.152:8888/aos-api/mit/me/1/vpnet/2

curl -X POST -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "edge-net2", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,2/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' http://10.52.150.152:8888/aos-api/mit/me/1/vpnet/3

curl -X POST -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "edge-acc3", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,3/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' http://10.52.150.152:8888/aos-api/mit/me/1/vpnet/4

curl -X POST -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "edge-acc4", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,4/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' http://10.52.150.152:8888/aos-api/mit/me/1/vpnet/5

curl -X POST -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "edge-acc5", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,5/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' http://10.52.150.152:8888/aos-api/mit/me/1/vpnet/6

curl -X POST -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "edge-acc6", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,6/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool"}' http://10.52.150.152:8888/aos-api/mit/me/1/vpnet/7

curl -X POST -H 'Content-Type:application/json+nicknames' -H "X-Auth-Token: your auth token" -d '{"id": "phy-local", "typ":"vlan", "afpp":"/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=nw,7/ctp=1/ctppool=1/fppool", "zfpp": "/me=1/eqh=shelf,1/eqh=slot,1/eq=card/ptp=cl,8/ctp=1/ctppool=1/fppool"}' http://10.52.150.152:8888/aos-api/mit/me/1/vpnet/8
