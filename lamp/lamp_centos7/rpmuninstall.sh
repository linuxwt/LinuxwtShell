#!/bin/bash

# 将系统自带的应用包卸载掉，这里拿httpd mysql mariadb做例子
package1=`rpm -qa | grep httpd`
if [ $? -eq 0 ];then
	rpm -e --nodeps $package1
fi 

package2=`rpm -qa | grep mysql`
if [ $? -eq 0 ];then
        rpm -e --nodeps $package2
fi 

package3=`rpm -qa | grep mariadb`
if [ $? -eq 0 ];then
        rpm -e --nodeps $package3
fi 

