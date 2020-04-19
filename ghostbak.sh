#!/bin/bash

######备份博客全部代码######
bak () {
    cd ghostbak
    zip -r ghost_$(date +%Y%m%d).zip ../ghost
}

if [ -d "$PWD/ghostbak" ];then
    bak
else
    mkdir ghostbak
    bak
fi

######传送压缩文件到目标服务器#######
/usr/bin/expect << EOF
set timeout 200
spawn scp  -o StrictHostKeyChecking=no ./ghost_$(date +%Y%m%d).zip  $ip:/root/ghostbak
expect "password"
send "${password}\r"
set timeout 200
expect eof
exit
EOF

###删除备份目录中超过7天的文件#####
find ./ -mtime +7 -name "*.zip" -exec rm -Rf {} \;

##删除远程备份目录中超过七天的文件####
set timeout 200
spawn ssh $ip -o StrictHostKeyChecking=no "find /root/ghostbak -mtime +7 -name \"*.zip\" -exec rm -Rf {} \;"
expect "password"
send "${password}\r"
set timeout 200
expect eof
exit
EOF
