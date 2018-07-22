#!/bin/bash

echo "we are going to configure the automatic start of nginx..."  
sleep 5  
# 将nginx加入系统服务并开机自行启动  
mv ./nginx.service /usr/lib/systemd/system
chmod 755  /usr/lib/systemd/system/nginx.service
systemctl restart nginx.service
if [ $? -eq 0 ];then  
    echo "The automatic start of nginx is ok."
fi
systemctl daemon-reload
systemctl enable nginx.service

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

echo "we are going to configure the automatic start of php-fpm..." 
sleep 5
# 将php-fpm加入系统服务并开机自行启动 
mv ./php-fpm.service /usr/lib/systemd/system
chmod 755  /usr/lib/systemd/system/php-fpm.service
systemctl restart php-fpm.service
if [ $? -eq 0 ];then
    echo "The automatic start of php-fpm is ok."
fi
systemctl daemon-reload
systemctl enable php-fpm.service
