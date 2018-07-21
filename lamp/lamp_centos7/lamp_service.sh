#!/bin/bash

echo "we are going to configure the automatic start of apache..."  
sleep 5  
# 将apache加入系统服务并开机自行启动  
mv ./httpd.service /usr/lib/systemd/system
chmod 755  /usr/lib/systemd/system/httpd.service
systemctl restart httpd.service
if [ $? -eq 0 ];then  
    echo "The automatic start of apache is ok."
fi
systemctl daemon-reload
systemctl enable httpd.service

echo "we are going to configure the start of mysql..."  
sleep 5  
# 将mysql加入系统服务并开机自行启动
mv ./mysql.service /usr/lib/systemd/system
chmod +x /usr/lib/systemd/system/mysql.service
systemctl restart mysql.service
if [ $? -eq 0 ];then  
        echo "The automatic start of mysql is ok."
fi  
systemctl daemon-reload
systemctl enable mysql.service
