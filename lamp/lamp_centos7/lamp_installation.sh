#!/bin/bash

# 安装lamp依赖环境  
echo "we are ready to install enviroment of dependent..."  
sleep 5  
yum -y install gcc  
yum -y install gcc-c++  
yum -y install openssh-clients  
yum -y install openssl  
yum -y install openssl-devel  
yum -y install pcre pcre-devel  
yum -y install libtool  
yum -y install libxml2 libxml2-devel 
if [ $? -ne 0 ];then
	yum -y install libxml2-devel
fi 
yum -y install bzip2 bzip2-devel  
yum -y install libcurl libcurl-devel  
yum -y install libjpeg libjpeg-devel  
yum -y install libpng libpng-devel  
yum -y install libXpm libXpm-devel  
yum -y install freetype freetype-devel  
echo "yum package is over,the next is source package..."  
sleep 5

# 进入源码包解压后所在的目录
cd /tmp  
tar zvxf apr-1.4.5.tar.gz  
cd apr-1.4.5  
./configure --prefix=/usr/local/apr 
make  
make install  
cd ..  
tar zvxf apr-util-1.3.12.tar.gz  
cd apr-util-1.3.12  
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr 
make  
make install  
cd ..  
tar zvxf bison-2.3.tar.gz  
cd bison-2.3  
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
cd  ncurses-6.0  
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
echo 'installation of dependent package is over.'  
echo  
echo  

# 设定几个变量，方便我们更换应用版本  
A="httpd-2.4.25"  
B="mysql-5.5.40"  
C="php-5.6.30"

# 下面开始源码安装apache、mysql、php  
echo "we are going to install apache..."  
sleep 5  
groupadd httpd  
useradd -g httpd httpd  
tar jvxf $A.tar.bz2  
cd $A  
./configure --prefix=/usr/local/apache2 --with-apr=/usr/local/apr  --with-apr-util=/usr/local/apr-util --with-pcre=/usr/local/pcre --enable-rewrite --enable-so --enable-headers --enable-expires --with-mpm=worker --enable-deflate
make  
make install  
cd ..  
echo  

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
echo

echo "we are going to install php..."  
sleep 5  
groupadd www  
useradd -g www www  
tar zvxf $C.tar.gz  
cd $C  
./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache2/bin/apxs --with-libxml-dir=/usr/include/libxml2 --with-config-file-path=/usr/local/apache2/conf --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-gd --enable-gd-native-ttf --with-zlib --with-mcrypt --with-pdo-mysql=/usr/local/mysql --enable-shmop --enable-soap --enable-sockets --enable-wddx --enable-zip --with-xmlrpc --enable-fpm --enable-mbstring --with-zlib-dir --with-bz2 --with-curl --enable-exif --enable-ftp --with-jpeg-dir=/usr/lib --with-png-dir=/usr/lib --with-freetype-dir=/usr/lib/  --with-xpm-dir=/usr --with-fpm-user=www --with-fpm-group=www --with-openssl --with-curl 
make  
# make test   
make install  
echo  
if [ $? -eq 1 ];then  
    echo "The installation is over!!!"
fi  
