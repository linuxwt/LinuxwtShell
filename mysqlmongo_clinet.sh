#!/bin/bash

# 这个脚本主要是用于安装mysql5.7客户端和mongodb3.6的客户端
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-common-5.7.24-1.el7.x86_64.rpm
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-libs-5.7.24-1.el7.x86_64.rpm
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-libs-compat-5.7.24-1.el7.x86_64.rpm
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client-5.7.24-1.el7.x86_64.rpm

rpm -ivh  mysql-community-common-5.7.24-1.el7.x86_64.rpm
rpm -ivh  mysql-community-libs-5.7.24-1.el7.x86_64.rpm
rpm -ivh  mysql-community-libs-compat-5.7.24-1.el7.x86_64.rpm
rpm -ivh  mysql-community-client-5.7.24-1.el7.x86_64.rpm

wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.6.6.tgz
tar vxf mongodb-linux-x86_64-rhel70-3.6.6.tgz
mv mongodb-linux-x86_64-rhel70-3.6.6 /usr/local/mongodb
cat <<EOF>> /etc/profile
export MONGODB_HOME=/usr/local/mongodb
export PATH=\$MONGODB_HOME/bin:\$PATH
EOF
