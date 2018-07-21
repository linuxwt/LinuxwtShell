#!/bin/bash

echo "we are going to configure the automatic start of apache..."
sleep 5
# 将apache加入系统服务并开机自行启动  
cp /usr/local/apache2/bin/apachectl /etc/init.d/httpd
chmod 755 /etc/init.d/httpd 
sed -i "/sh/a\#chkconfig: 2345 10 90\n#description: Activates/Deactivates Apache Web Server" /etc/init.d/httpd
chkconfig --add httpd 
chkconfig httpd on 
service httpd restart 
if [ $? -eq 0 ];then
	echo "The automatic start of apache is ok."
fi

echo "we are going to configure the start of mysql..."
sleep 5  
# 将mysql加入系统服务并开机自行启动
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql  
chmod 755 /etc/init.d/mysql
chkconfig --add mysql 
chkconfig mysql on 
service mysql restart
if [ $? -eq 0 ];then
        echo "The automatic start of mysql is ok."
fi


