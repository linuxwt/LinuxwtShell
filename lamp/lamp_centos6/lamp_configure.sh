#!/bin/bash

A="httpd-2.4.25"
B="mysql-5.5.40"
C="php-5.6.30"
D=/usr/local/apache2/htdocs

echo "is going to configure apache..." 
sleep 5
# 安装完成后还需要对apache进行一些的设置  
# 防止启动报错
# 这条添加的方式其实可以使用echo "ServerName localhost:80"，这样在安装其他版本的apachea的时候不容易出错，但是这里我们使用了下面这条是因为我们确认了5.6.30在195行为空
sed -i '195i ServerName localhost:80' /usr/local/apache2/conf/httpd.conf
# 添加80端口INPUT规则链
iptables -I INPUT -p tcp --dport 80 -j ACCEPT 
service iptables save >/dev/null 2>&1
# 添加对php的识别(该sed命令可以在某一行的尾部添加内容)
sed -i 's/index.html.*/& index.php/g' /usr/local/apache2/conf/httpd.conf
# 添加对php支持（该sed命令可以在某一行的下面添加命令，这里是连续添加了两行，注意里面的\n是起换行的作用）  
sed -i "/libphp5.so/a\AddType application/x-httpd-php .php .phtml\nAddType application/x-httpd-php-source .phps" /usr/local/apache2/conf/httpd.conf
# 启动apache并测试apache配置是否正确
/usr/local/apache2/bin/apachectl start
if [ $? -eq 0 ];then
 echo 'the configuration of apache is ok.'
fi

echo "is going to configure mysql..."  
sleep 5
# 配置文件生成  
cp /usr/local/mysql/support-files/my-medium.cnf /etc/my.cnf
# 修改安装目录权限
chown -R mysql:mysql /usr/local/mysql
# 添加3306端口INPUT规则链
iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
service iptables save >/dev/null 2>&1
# 创建系统数据库  
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data 
# 启动mysql并测试mysql配置  
/usr/local/mysql/support-files/mysql.server start
if [ $? -eq 0 ];then
 echo 'the configuration of mysql is ok.'
else
 chmod 777 /tmp -R
fi

echo "is going to configure php..."
sleep 5 
# 配置php.ini  
cp /tmp/$C/php.ini-production /usr/local/php/lib/php.ini
# 同步php.ini到apache
# cp /usr/local/php/lib/php.ini /usr/local/apache2/conf/
# 测试php
if [ ! -f $D/index.php ];then
 echo "<?php echo phpinfo();?>" > $D/index.php
fi  
curl 127.0.0.1/index.php
if [ $? -eq 0 ];then
 echo "the configuration of php is ok."
fi
 
