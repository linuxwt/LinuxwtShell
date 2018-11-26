#!/bin/bash

tomcat_dir="/data/gooalgene/java"
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
export JAVA_HOME=/data/gooalgene/java/jdk1.8 MAVEN_HOME=/data/gooalgene/java/maven3.5
export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$JAVA_HOME/bin:\$MAVEN_HOME/bin:\$PATH 
EOF


