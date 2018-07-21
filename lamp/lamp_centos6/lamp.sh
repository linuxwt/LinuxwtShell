#!/bin/bash

# 给安装、配置、加入系统服务、php扩展以及本脚本(一键安装脚本，改脚本会调用前面三个脚本)新建一个专门的存放目录
dirscripts=/server/scripts
if [ ! -d $dirscripts ];then
	mkdir -p $dirscripts
fi

# 给源码包（amp源码包、依赖源码包、php扩展包新建一个专门的存放目录
dirpackages=/server/packages
if [ ! -d $dirpackages ];then
	mkdir -p $dirpackages
fi

# 源码包解压至目录/tmp
tar zvxf ./lamp.tar.gz -C /tmp



# 调用脚本开始安装
bash lamp_installation.sh && 
bash lamp_configure.sh &&
bash lamp_service.sh &&
bash php_plugin.sh && 


# 安装完成后将所有相关文件移到设置好的目录里
mv lamp.tar.gz $dirpackages
mv ./lamp_installation.sh $dirscripts
mv ./lamp_configure.sh $dirscripts
mv ./lamp_service.sh $dirscripts
mv ./php_plugin.sh $dirscripts
# $0指代本脚本
mv $0 $dirscripts
 

  
