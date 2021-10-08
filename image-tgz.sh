#!/bin/bash
##批量打包镜像未tgz文件##
##1.txt##
#
#calico/node
#calico/pod2daemon-flexvol
#calico/cni
#calico/kube-controllers
#coredns/coredns
#registry.aliyuncs.com/google_containers/pause
#tutum/dnsutils

##2.txt
#
#v3.19.3
#v3.19.3
#v3.19.3
#v3.19.3
#1.8.4
#3.2
#latest

paste -d ':' 1.txt 2.txt > 3.txt
for i in $(cat 3.txt);do docker save $i | gzip > $(echo $i | awk -F ':' '{print $1}' | awk -F '/' '{print $2}').tgz;done

