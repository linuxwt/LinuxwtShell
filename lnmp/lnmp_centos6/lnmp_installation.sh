#!/bin/bash

# 安装依赖环境  
yum -y install gcc  
yum -y install gcc-c++ 
yum -y install openssl  
yum -y install openssl-devel
yum -y install libxml2 libxml2-devel 
yum -y install bzip2 bzip2-devel 
yum -y install libcurl libcurl-devel 
yum -y install libjpeg libjpeg-devel 
yum -y install libpng libpng-devel 
yum -y install libXpm libXpm-devel 
yum -y install freetype freetype-devel 
yum -y install openssl opsenssl-devel 

cd /tmp
tar zvxf pcre-8.38.tar.gz 
cd pcre-8.38 
./configure 
make
make install
cd ..

tar zvxf zlib-1.2.11.tar.gz 
cd zlib-1.2.11 
./configure 
make 
make install
cd ..

tar zvxf cmake-3.7.1.tar.gz 
cd cmake-3.7.1 
./configure 
make 
make install
cd ..

tar zvxf ncurses-6.0.tar.gz 
cd ncurses-6.0 
./configure 
make
make install
cd ..

tar zvxf bison-2.3.tar.gz 
cd bison-2.3 
./configure 
make
make install
cd ..

tar zvxf libmcrypt-2.5.7.tar.gz 
cd libmcrypt-2.5.7 
./configure 
make
make install
cd ..

# 为了以后方便更换版本，设定下面几个变量
A="nginx-1.8.1"
B="mysql-5.5.40"
C="php-5.6.30"

# 安装nginx mysql php 这三个应用  
# 安装nginx
echo "we are going to install nginx ..."
sleep 5
groupadd www
useradd -g www www
tar zvxf $A.tar.gz
cd $A
./configure --user=www --group=www --prefix=/usr/local/Nginx --with-poll_module --with-http_stub_status_module 
make 
make install  
if [ $? -eq 0 ];then
	echo "nginx is installed successfully."
fi
cd ..

# 安装mysql
echo "we are going to install mysql..."
sleep 5
groupadd mysql
useradd -g mysql mysql
tar zvxf $B.tar.gz
cd $B
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql/  -DMYSQL_DATADIR=/usr/local/mysql/data  -DWITH_INNOBASE_STORAGE_ENGINE=1  -DMYSQL_TCP_PORT=3306  -DMYSQL_UNIX_ADDR=/usr/local/mysql/data/mysql.sock  -DMYSQL_USER=mysql  -DWITH_DEBUG=0  
make 
make install
cd ..

# 安装php
echo "we are going to install php..."
sleep 5
tar zvxf $C.tar.gz   
cd $C
./configure --prefix=/usr/local/php --with-libxml-dir=/usr/include/libxml2  --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-gd --enable-gd-native-ttf --with-zlib --with-mcrypt --with-pdo-mysql=/usr/local/mysql --enable-shmop --enable-soap --enable-sockets --enable-wddx --enable-zip --with-xmlrpc --enable-fpm --enable-mbstring --with-zlib-dir --with-bz2 --with-curl --enable-exif --enable-ftp --with-jpeg-dir=/usr/lib --with-png-dir=/usr/lib --with-freetype-dir=/usr/lib/  --with-xpm-dir=/usr --with-fpm-user=www --with-fpm-group=www --with-openssl --with-curl --enable-opcache
make 
make install
echo
if [ $? -eq 1 ];then
    echo "The installation is over!!!"
fi

