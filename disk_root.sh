#!/bin/bash

# 以根目录已使用空间占百分比来定时删除占用空间较大的日志文件
Usage_rootdir=$(df -h | head -n 2 | tr -s " " | awk -F " " '{print $5}' | grep -v Use)
num=${Usage_rootdir//%/}
logdir="/var/log/network"

if [ ${Usage_rootdir} -gt ${num} ];then
    find ${logdir} -type f -name *.log -atime +60 -exec rm -Rf {} \;
fi

exit 0
