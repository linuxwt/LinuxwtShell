#!/bin/bash

# 一键以docker自动部署mongo单点服务和mysql单点服务并创建库用户同时进行用户验证
# 本脚本在centos7.5上测试通过
# 本脚本需要带上$1-$8参数，分别表示
# $1 mongodb的admin库的库用户
# $2 admin库的用户密码
# $3 创建一个项目库，mysql和mongo均使用该库名
# $4 项目库用户
# $5 项目库用户密码
# $6 mysql的远程root和本地root密码
# $7 mysql项目库用户
# $8 mysql的项目库用户密码
# 脚本在第186行涉及到网卡en32，改成你自己的网卡名字


# 第一阶段：准备工作
# 配置国内yum源、安装docker-ce、docker-compose、配置docker镜像加速拉取、配置iptables、禁用firewalld和selinux
# 配置163源
yum -y install wget
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
mv CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo
yum clean all && yum makecache && yum -y update
if [ $? -eq 0 ];then
        echo "replacing yum resource to 163  and update are successful."
else
        exit -1
fi
sleep 5
# 安装最新docker并检查版本
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
# 安装iptables并添加需要的端口以及禁用firewalld
yum -y install iptables-services
add_port=(27017 33066 8080)
for port in ${add_port[@]}
do
	iptables -I INPUT -p tcp --dport ${port} -j ACCEPT
done
systemctl stop firewalld && systemctl disable firewalld && service iptables save && systemctl restart iptables && systemctl restart docker && systemctl daemon-reload
cat /etc/sysconfig/iptables
sleep 5
# 禁用selinux
# 永久禁用，生效需要重启系统
sed -i 's/disabled/enforcing/g' /etc/sysconfig/selinux
# 暂时禁用，即时生效
selinux_status=$(getenforce)
if [ ${selinux_status} == "Enforcing" ];then
        setenforce 0
fi



# 第二阶段：通过Dockerfile来构建mongo3.6镜像、启用非认证的mongo容器、创建mongo库用户、验证mongo库用户、启用认证的mongo容器
# 拉取mysql5.7镜像、启用mysql容器、创建mysql库用户、验证mysql库用户
# 构建mongo镜像
image_dir="/data/images"
if [ -d ${image_dir} ];then
        mv /data/images /data/images.bak
        mkdir -p /data/images
else
        mkdir -p /data/images
fi
touch ${image_dir}/Dockerfile_mongo
echo "FROM centos:centos7" >> ${image_dir}/Dockerfile_mongo
echo "MAINTAINER linuxwt <tengwanginit@gmail.com>" >> ${image_dir}/Dockerfile_mongo
echo " " >> ${image_dir}/Dockerfile_mongo
echo "RUN yum -y update" >> ${image_dir}/Dockerfile_mongo
echo " " >> ${image_dir}/Dockerfile_mongo
echo "RUN  echo '[mongodb-org-3.6]' > /etc/yum.repos.d/mongodb-org-3.6.repo" >> ${image_dir}/Dockerfile_mongo
echo "RUN  echo 'name=MongoDB Repository' >> /etc/yum.repos.d/mongodb-org-3.6.repo" >> ${image_dir}/Dockerfile_mongo
echo "RUN  echo 'baseurl=http://repo.mongodb.org/yum/redhat/7/mongodb-org/3.6/x86_64/' >> /etc/yum.repos.d/mongodb-org-3.6.repo" >> ${image_dir}/Dockerfile_mongo
echo "RUN  echo 'enabled=1' >> /etc/yum.repos.d/mongodb-org-3.6.repo" >> ${image_dir}/Dockerfile_mongo
echo "RUN  echo 'gpgcheck=0' >> /etc/yum.repos.d/mongodb-org-3.6.repo" >> ${image_dir}/Dockerfile_mongo
echo " " >> ${image_dir}/Dockerfile_mongo
echo "RUN yum -y install make" >> ${image_dir}/Dockerfile_mongo
echo "RUN yum -y install mongodb-org" >> ${image_dir}/Dockerfile_mongo
echo "RUN mkdir -p /data/db" >> ${image_dir}/Dockerfile_mongo
echo " " >> ${image_dir}/Dockerfile_mongo
echo "EXPOSE 27017" >> ${image_dir}/Dockerfile_mongo
echo "ENTRYPOINT [\"/usr/bin/mongod\"]" >> ${image_dir}/Dockerfile_mongo
docker build -t centos7/mongo:3.6 -<${image_dir}/Dockerfile_mongo
# 运行非认证的mongo容器
# 编写docker-compose.yml文件并
mongo_dir="/data/gooalgene/mongo"
if [ ! -d ${mongo_dir}/mongo ];then
	mkdir -p ${mongo_dir}/mongo
fi
touch ${mongo_dir}/docker-compose.yml
echo "always madvise [never]" > ${mongo_dir}/enabled
echo "always madvise [never]" > ${mongo_dir}/defrag
if [ ! -f "/etc/localtime" ];then
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
fi
if [ ! -f "/etc/timezone" ];then
	echo "Asia/Shanghai" > /etc/timezone
fi
echo "mongo_linuxwt:" > ${mongo_dir}/docker-compose.yml 
echo "  restart: always" >> ${mongo_dir}/docker-compose.yml
echo "  image: centos7/mongo:3.6" >> ${mongo_dir}/docker-compose.yml
echo "  container_name: mongo_linuxwt" >> ${mongo_dir}/docker-compose.yml
echo "  volumes:" >> ${mongo_dir}/docker-compose.yml
echo "    - /etc/localtime:/etc/localtime" >> ${mongo_dir}/docker-compose.yml
echo "    - /etc/timezone:/etc/timezone" >> ${mongo_dir}/docker-compose.yml
echo "    - \$PWD/mongo:/data/db" >> ${mongo_dir}/docker-compose.yml
echo "    - \$PWD/enabled:/sys/kernel/mm/transparent_hugepage/enabled" >> ${mongo_dir}/docker-compose.yml
echo "    - \$PWD/defrag:/sys/kernel/mm/transparent_hugepage/defrag" >> ${mongo_dir}/docker-compose.yml
echo "  ulimits:" >> ${mongo_dir}/docker-compose.yml
echo "    nofile:" >> ${mongo_dir}/docker-compose.yml
echo "      soft: 300000" >> ${mongo_dir}/docker-compose.yml
echo "      hard: 300000" >> ${mongo_dir}/docker-compose.yml
echo "  ports:" >> ${mongo_dir}/docker-compose.yml
echo "      - \"27017:27017\"" >> ${mongo_dir}/docker-compose.yml
echo "  command: --bind_ip_all --port 27017 --oplogSize 204800 --profile=1 --slowms=500" >> ${mongo_dir}/docker-compose.yml
# 启动非认证mongo容器
cd ${mongo_dir} && docker-compose up -d  
# 创建库用户并验证
# 先在宿主机安装mongo客户端
wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.6.6.tgz
tar zvxf mongodb-linux-x86_64-rhel70-3.6.6.tgz
mv mongodb-linux-x86_64-rhel70-3.6.6 /usr/local/mongodb
echo "PATH=/usr/local/mongodb/bin:\$PATH" >> /etc/profile
echo "export PATH" >> /etc/profile
source /etc/profile
# 创建admin库用户授予读写权限并验证、创建项目库linuxwt的用户授予读写权限并验证
docker exec -it mongo_linuxwt mongo admin --eval "db.createUser({user:\"$1\", pwd:\"$2\", roles:[{role:\"root\", db:\"admin\"},{role:\"clusterAdmin\",db:\"admin\"}]})"
docker exec -it mongo_linuxwt mongo $3 --eval "db.createUser({user:\"$4\", pwd:\"$5\", roles:[{role:\"root\", db:\"admin\"},{role:\"clusterAdmin\",db:\"admin\"}]})"
# 进行验证需要获得服务器的网络地址
ip_netmask=$(ip addr | grep 'ens32' | grep 'inet' | awk '{print $2}')
ip=${ip_netmask:0:8}
mongo_port=$(docker port mongo_linuxwt | awk '{print $3}')
mongo_port1=${mongo_port:7:6}
# 验证mongo库用户
docker exec -it mongo_linuxwt mongo admin --eval "db.auth(\"$1\",\"$2\")"
docker exec -it mongo_linuxwt mongo $3 --eval "db.auth(\"$4\",\"$5\")"
if [ $? -eq 0 ];then
        remote_check_mongo="mongo ${ip}${mongo_port1}/admin -u "$1" -p "$2" -authenticationDatabase 'admin'"
	echo "local check login of admin database is ok and please use the command - ${remote_check_mongo} - check the remote login."
	sleep 5
 	mongo ${ip}${mongo_port1}/admin -u "$1" -p "$2" -authenticationDatabase 'admin'
	mongo ${ip}${mongo_port1}/$3 -u "$4" -p "$5" -authenticationDatabase "$3"
	if [ $? -eq 0 ];then
		echo "mongo remote login is ok"
	else
		echo "mongo remote login is unavaiable"
		exit -1
	fi
fi
# 运行认证的mongo容器
cp docker-compose.yml docker-compose.yml.noauth
docker-compose down
# 判断是否正确down掉
mongo_linuxwt_down=$(docker-compose down | grep "mongo_linuxwt" | wc -l)
if [ ${mongo_linuxwt_down} == 0 ];then
	echo "mongo_linuxwt down normally"
else
	echo "docker-compose down failed and please check the container which is running.."
	exit -1
fi 
sed -i 's/command.*/& --auth/g' docker-compose.yml && docker-compose up -d  
if [ $? -eq 0 ];then
	echo "mongo container with authentication is running" 
else
	exit -1
fi
# 拉取mysql5.7的镜像
docker pull mysql:5.7  
# 编写docker-compose.yml文件
mysql_dir="/data/gooalgene/mysql"
mysql_dir="/data/gooalgene/mysql"
if [ ! -d ${mysql_dir}/mysql ];then
        mkdir -p ${mysql_dir}/mysql	
else
	mv ${mysql_dir}/mysql  ${mysql_dir}/mysql.bak
	mkdir -p ${mysql_dir}/mysql
fi
touch ${mysql_dir}/docker-compose.yml  
touch ${mysql_dir}/mysqld.cnf
cd ${mysql_dir}
echo "mysql_linuxwt:" > ${mysql_dir}/docker-compose.yml
echo "  restart: always" >> ${mysql_dir}/docker-compose.yml
echo "  image: mysql:5.7" >> ${mysql_dir}/docker-compose.yml
echo "  container_name: mysql_linuxwt" >> ${mysql_dir}/docker-compose.yml
echo "  volumes:" >> ${mysql_dir}/docker-compose.yml
echo "    - /etc/localtime:/etc/localtime" >> ${mysql_dir}/docker-compose.yml
echo "    - /etc/timezone:/etc/timezone" >> ${mysql_dir}/docker-compose.yml
echo "    - \$PWD/mysql:/var/lib/mysql" >> ${mysql_dir}/docker-compose.yml
echo "    - \$PWD/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf" >> ${mysql_dir}/docker-compose.yml
echo "  ports:" >> ${mysql_dir}/docker-compose.yml
echo "    - 33066:3306" >> ${mysql_dir}/docker-compose.yml
echo "  environment:" >> ${mysql_dir}/docker-compose.yml
echo "    MYSQL_ROOT_PASSWORD: $6" >> ${mysql_dir}/docker-compose.yml
# 编写mysqld.cnf(该配置文件里面的一些缓存参数仅做参考，请根据机器实际情况修改) 
echo "[mysqld]" > mysqld.cnf
echo "pid-file = /var/run/mysqld/mysqld.pid" >> mysqld.cnf
echo "socket = /var/run/mysqld/mysqld.sock" >> mysqld.cnf
echo "datadir = /var/lib/mysql" >> mysqld.cnf
echo "symbolic-links=0" >> mysqld.cnf
echo "character-set-server=utf8" >> mysqld.cnf
echo "back_log=500" >> mysqld.cnf
echo "wait_timeout=1800" >> mysqld.cnf
echo "max_connections=3000" >> mysqld.cnf
echo "max_user_connections=800" >> mysqld.cnf
echo "innodb_thread_concurrency=40" >> mysqld.cnf
echo "default-storage-engine=innodb" >> mysqld.cnf
echo "key_buffer_size=400M" >> mysqld.cnf
echo "innodb_buffer_pool_size=1G" >> mysqld.cnf
echo "innodb_log_file_size=256M" >> mysqld.cnf 
echo "innodb_flush_method=O_DIRECT" >> mysqld.cnf
echo "innodb_log_buffer_size=20M" >> mysqld.cnf
echo "query_cache_size=40M" >> mysqld.cnf
echo "read_buffer_size=4M" >> mysqld.cnf
echo "sort_buffer_size=4M" >> mysqld.cnf
echo "read_rnd_buffer_size=8M" >> mysqld.cnf
echo "tmp_table_size=64M" >> mysqld.cnf
echo "thread_cache_size=64" >>mysqld.cnf
echo "max_allowed_packet=200M" >> mysqld.cnf
echo "server-id=1" >> mysqld.cnf
echo "log_bin=mysql-bin" >> mysqld.cnf
echo "general-log=1" >> mysqld.cnf
# 启动mysql容器
docker-compose up -d
if [ $? -eq 0 ];then
	echo "mysql container start successfully."
else
	echo "mysql container start failed and please check the revelant file!"
	exit -1
fi
# 验证root远程账号、创建库用户账号并验证
# 先在宿主机安装mysql客户端
wget https://downloads.mysql.com/archives/get/file/MySQL-client-5.5.40-1.el7.x86_64.rpm
mariadb_package=$(rpm -qa|grep mariadb | wc -l)
if [ $? -eq 1 ];then
	rpm -qa| grep mariadb | xargs rpm -e --nodeps 
	rpm -ivh MySQL-client-5.5.40-1.el7.x86_64.rpm
else
	rpm -ivh MySQL-client-5.5.40-1.el7.x86_64.rpm	
fi
# 验证root远程账号并创建项目库,创建库用户并授予所有权限
# 进行验证需要获得服务器的网络地址
mysql -u root -h ${ip} -P33066 -p$6 -e "create database $3;show databases;"
mysql -u root -h ${ip} -P33066 -p$6 -e "create user '$7'@'%' identified by '$8';"
mysql -u root -h ${ip} -P33066 -p$6 -e "grant all privileges on $3.* to '$7'@'%';flush privileges;"
# 验证库用户
mysql -u $7 -h ${ip} -P33066 -p$8 -e "show databases;"
