#!/bin/bash

# 将nginx php-fpm mysql 加入系统服务并使其开机自动启动
echo "we are going to add nginx into system service..."
sleep 5
# 复制脚本到/etc/init.d/下
cp ./nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on 
service nginx restart
if [ $? -eq 0 ];then
	echo "nginx system service is ok."
else
	exit -1
fi


echo "we are going to add php-fpm service into system..."
sleep 5
# 复制脚本到/etc/init.d/下
cp ./php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
service php-fpm restart
if [ $? -eq 0 ];then
	echo "php-fpm system service is ok."
else
	exit -1
fi


echo "we are going to add mysql service into system..."
sleep 5
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql  
chmod +x /etc/init.d/mysql
chkconfig --add mysql 
chkconfig mysql on 
service mysql restart
if [ $? -eq 0 ];then
        echo "The automatic start of mysql is ok."
else
	eit -1
fi

