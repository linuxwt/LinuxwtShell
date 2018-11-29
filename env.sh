#!/bin/bash

if [ $# -ne 1 ];then
    echo "you need add one arguments: 项目部署目录 after script name"
    exit -1
fi
project_dir="$1"
# 更换yum源并安装docker、docker-compose
yum -y install wget
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
mv CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo
yum clean all && yum makecache && yum -y update
# 安装docker18.03与docker-compose  
installdocker1()
{
        yum -y install yum-utils device-mapper-persistent-data lvm2
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum-config-manager --enable docker-ce-edge
        yum-config-manager --enable docker-ce-test
        yum -y install docker-ce
}
installdocker2()
{
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager  --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum -y install docker-ce
}
docker version
if [ $? -eq 127 ];then
        echo "we can install docker-ce"
        sleep 5
        installdocker1
        if [ $? -ne 0 ];then
            echo "you should use aliyun image."
            installdocker2
        fi
        docker version
        if [ $? -lt 127 ];then
                echo "the installation of docker-ce is ok."
                rpm -qa | grep docker | xargs rpm -e --nodeps 
                yum -y install docker-ce-18.03*
        else
                echo "the installation of docker-ce failed ,please reinstall"
                exit -1
        fi
else
        echo "docker have installed，pleae uninstall old version"
        sleep 5
        rpm -qa | grep docker | xargs rpm -e --nodeps
        docker version
        if [ $? -eq 127 ];then
                echo "old docker have been uninstalled and you can install docker-ce"
                sleep 5
                installdocker1
                if [ $? -ne 0 ];then
                    echo "you should use aliyun image."
                    installdocker2
                fi
                docker version
                if [ $? -lt 127 ];then
                        echo "the installation of docker-ce is ok."
                        rpm -qa | grep docker | xargs rpm -e --nodeps
                        yum -y install docker-ce-18.03*
                else
                        echo "the installation of docker-ce failed anad please reinstall."
                        exit -1
                fi
        else
                echo "the old docker uninstalled conpletely and please uninstall again."
                exit -1
        fi
fi
systemctl start docker && systemctl enable docker && systemctl daemon-reload 
docker_version=$(docker version | grep "Version" | awk '{print $2}' | head -n 2 | sed -n '2p')
if [ $? -eq 0 ];then
        echo "docker start successfully and the version is ${docker_version}"
fi
# 安装docker-compose并检查版本
yum -y install epel-release  && yum -y install python-pip  && pip install docker-compose  && pip install --upgrade pip 
docker-compose_version=$(docker-compose version | grep 'docker-compose' | awk '{print $3}')
if [ $? -eq 0 ];then
        echo "the docker-compose version is ${docker-compose_version}"
fi
# 配置docker加速拉取
echo {\"registry-mirrors\":[\"https://nr630v1c.mirror.aliyuncs.com\"]} > /etc/docker/daemon.json

# 安装常用工具
yum -y install lrzsz && yum -y install openssh-clients && yum -y install telnet && yum -y install rsync 

# 防火墙配置
setenforce 0
sed -i 's/enforcing/disabled/g' /etc/selinux/config
sed -i 's/enforcing/disabled/g' /etc/sysconfig/selinux
systemctl stop firewalld
systemctl disable firewalld
systemctl daemon-reload

# 更改docker存储位置
cp -r /var/lib/docker ${project_dir}
rm -Rf /var/lib/docker
ln -s ${project_dir}/docker /var/lib/docker
systemctl restart docker

sleep 5
echo "yum and docker are ok!!!"
sleep 5
