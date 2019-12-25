#!/bin/bash

# 安装ntp服务
yum -y install ntp ntpdate
ntpdate ntp1.aliyun.com
ntpdate ntp2.aliyun.com

# 这里获取主机网络段，假设这里是24位网络号，子网掩码是255.255.255.0
netcard=$(ls /etc/sysconfig/network-scripts/ | grep ifcfg | grep -v lo)
card=${netcard//ifcfg-/}
ip_net=$(ip addr | grep $card | grep inet | awk '{print $2}')
ip=${ip_net//\/24/}
a=$(echo $ip | awk -F '.' '{print $1}')
b=$(echo $ip | awk -F '.' '{print $2}')
c=$(echo $ip | awk -F '.' '{print $3}')
net="$a.$b.$c.0"

# 备份ntp配置文件
[ -f "/etc/ntp.conf" ] && mv /etc/ntp.conf /etc/ntp.confbak

# 配置ntp.conf
cat <<EOF>> /etc/ntp.conf
restrict default nomodify notrap noquery
 
restrict 127.0.0.1
restrict $net mask 255.255.255.0 nomodify    
#只允许$net网段的客户机进行时间同步。如果允许任何IP的客户机都可以进行时间同步，就修改为"restrict default nomodify"
 
server ntp1.aliyun.com
server ntp2.aliyun.com
server time1.aliyun.com
server time2.aliyun.com

server time-a.nist.gov
server time-b.nist.gov
 
server  127.127.1.0     
# local clock
fudge   127.127.1.0 stratum 10
 
driftfile /var/lib/ntp/drift
broadcastdelay  0.008
keys            /etc/ntp/keys
EOF

# 启动服务
systemctl restart ntpd
systemctl enable ntpd
systemctl daemon-reload

# 加入计划任务
cat <<EOF>> /etc/crontab
0 0,6,12,18 * * * /usr/sbin/ntpdate ntp1.aliyun.com; /sbin/hwclock -w
EOF
systemctl restart crond
