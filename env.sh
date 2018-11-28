#!/bin/bash

project_dir="$1"
# 更换yum源并安装docker、docker-compose
yum -y install wget
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
mv CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo
yum clean all && yum makecache && yum -y update
# 安装docker18.03与docker-compose  
installdocker()
{
        yum -y install yum-utils device-mapper-persistent-data lvm2
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum-config-manager --enable docker-ce-edge
        yum-config-manager --enable docker-ce-test
        yum -y install docker-ce
}
docker version
if [ $? -eq 127 ];then
        echo "we can install docker-ce"
        sleep 5
        installdocker
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
                installdocker
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
# 更改docker存储位置
cp -r /var/lib/docker /${project_dir}
rm -Rf /var/lib/docker
ln -s /${project_dir}/docker /var/lib/docker
systemctl restart docker

# 安装常用工具
yum -y install lrzsz && yum -y install openssh-clients && yum -y install telnet && yum -y install rsync 

# 防火墙配置
setenforce 0
sed -i 's/enforcing/disabled/g' /etc/selinux/config
sed -i 's/enforcing/disabled/g' /etc/sysconfig/selinux

sleep 5
echo "yum and docker are ok!!!"
sleep 5

# 安装jdk、maven
tomcat_dir="/${project_dir}/gooalgene/java"
if [ ! -d ${tomcat_dir} ];then
    mkdir -p ${tomcat_dir}
else
    mv ${tomcat_dir} ${tomcat_dir}.bak
    mkdir -p ${tomcat_dir}
fi

# 宿主机上部署jdk和maven
prog=$(rpm -qa|grep java | wc -l)
if [ ${prog} -gt 0 ];then
    echo "the system have java,next we uninstall it and install new."
    sleep 5
    rpm -qa|grep java | xargs rpm -e --nodeps 
else
    echo "you need installed java"
fi
cd ${tomcat_dir}

wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u192-b12/750e1c8617c5452694857ad95c3ee230/jdk-8u192-linux-x64.tar.gz
tar zvxf jdk-8u192-linux-x64.tar.gz
mv jdk1.8.0_192 jdk1.8
wget  http://apache.fayea.com/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
tar zvxf apache-maven-3.5.4-bin.tar.gz
mv apache-maven-3.5.4 maven3.5
# 加入环境变量
cp /etc/profile /etc/profile.bak
cat <<EOF>> /etc/profile
export JAVA_HOME=/${project_dir}/gooalgene/java/jdk1.8 MAVEN_HOME=/${project_dir}/gooalgene/java/maven3.5
export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$JAVA_HOME/bin:\$MAVEN_HOME/bin:\$PATH 
EOF


sleep 3
echo "jdk and maven are ok!!!"
sleep 3


# 安装mysql、mongodb客户端
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-common-5.7.24-1.el7.x86_64.rpm 
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-libs-5.7.24-1.el7.x86_64.rpm
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-libs-compat-5.7.24-1.el7.x86_64.rpm
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client-5.7.24-1.el7.x86_64.rpm

mariadb_num=$(rpm -qa|grep mariadb | wc -l)
if [ ${mariadb_num} -eq 0 ];then
    echo "you can install mysql."
else
    rpm -qa | grep mariadb | xargs rpm -e --nodeps
fi
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


sleep 3
echo "mysql and mongodb client are ok!!!"
sleep 3
