#!/bin/bash

# 单点登录检查，该脚本需要加入crond进行自检
a=$(netstat -ntlp|grep 9982 | awk '{print $4}' | wc -l) 
# b=${a: -4:4}

if ((a == 1));then
    echo "sso have started."
else
    cd /data/gooalgene/dbs/soybean_all_module
    nohup java -jar sso.jar
fi
