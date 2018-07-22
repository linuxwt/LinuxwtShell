#!/bin/bash

A="nginx-1.8.1"  
B="mysql-5.5.40"  
C="php-5.6.30"  
D="/usr/local/Nginx/html"



# 配置nginx
echo "we are going to configure nginx..."  
sleep 5  
# 安装完nginx后需要进行一些配置
# 添加80端口INPUT规则链
firewall-cmd --permanent --zone=public --add-port=80/tcp
systemctl restart firewalld.service
# 添加libpcre.so.1
# ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1  
# 添加对php的识别
sed -i 's/index.html/& index.php/g' /usr/local/Nginx/conf/nginx.conf  
# 添加对php的支持
sed -i '65,71s/scripts/usr\/local\/Nginx\/html/g' /usr/local/Nginx/conf/nginx.conf  
sed -i '65,71s/#//g' /usr/local/Nginx/conf/nginx.conf  
# 启动nginx看nginx是否配置正i确
/usr/local/Nginx/sbin/nginx
if [ $? -eq 0 ];then  
    echo "nginx configuration is ok."
else  
    exit -1
fi  
echo


# 配置mysql
echo "is going to configure mysql..."  
sleep 5  
# 配置文件生成
cp /usr/local/mysql/support-files/my-medium.cnf /etc/my.cnf  
# 修改安装目录权限
chown -R mysql:mysql /usr/local/mysql  
# 添加3306端口INPUT规则链
firewall-cmd --permanent --zone=public --add-port=3306/tcp
systemctl restart firewalld.service
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
# php、php-fpm配置
# php.ini配置
cp /tmp/$C/php.ini-production /usr/local/php/lib/php.ini  
# 启动php-fpm  
cd /usr/local/php/etc  
cp php-fpm.conf.default php-fpm.conf  
/usr/local/php/sbin/php-fpm
if [ $? -eq 0 ];then  
    echo "php-fpm configuration is ok."
else  
    exit -1
fi  
# 测试php
if [ ! -f $D/index.php ];then  
 echo "<?php echo phpinfo();?>" > $D/index.php
fi  
curl 127.0.0.1/index.php  
if [ $? -eq 0 ];then  
 echo "the configuration of php is ok."
fi  
