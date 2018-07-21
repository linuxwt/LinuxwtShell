#!/bin/bash

echo "we are going to install mongo.so"  
sleep 5  
# 安装mongo扩展  
cd /tmp  
tar zvxf mongo-1.6.12.tgz  
cd mongo-1.6.12  
/usr/local/php/bin/phpize 
./configure --with-php-config=/usr/local/php/bin/php-config 
make  
make install

echo "we are going to add mongo.so"  
sleep 5  
# 获取扩展文件的存放目录
pronn=`find /usr/local/php -name mongo.so`  
dirextensions=`dirname $pronn`  
# 向php.ini文件添加扩展mongo.so  
sed -i "/php_shmop.dll/a\extension=$dirextensions/mongo.so" /usr/local/php/lib/php.ini


echo "we are going to install mongodb.so"  
sleep 5  
# 安装mongodb扩展(适用于5.x,7.x)
cd /tmp  
cd /usr/local/php/bin  
/usr/local/php/bin/pecl install mongodb
if [ $? -ne 0 ];then  
    echo "maybe you should connect vpn and install again"
fi

echo "we are going to add mongodb.so"  
sleep 5  
# 向php.ini文件添加扩展mongodb.so
sed -i "/php_shmop.dll/a\extension=$dirextensions/mongodb.so" /usr/local/php/lib/php.ini




# 同步php.ini到apache
cp /usr/local/php/lib/php.ini /usr/local/apache2/conf/  
# 重启httpd时扩展生效
systemctl restart httpd.service
