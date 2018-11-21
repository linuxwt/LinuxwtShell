#!/bin/bash

if [ $# -ne 5 ];then
        echo "sorry,you need enter the 备份库名 容器名 连接用户 密码 安全目录映射的目录 of the scripts"
        exit -1
fi
# 变量设定
dbname="$1"
container_name="$2"
username1="$3"
password1="$4"
# yingshe_dir为安全目录映射的目录
yingshe_dir="$5"

# 获取需要导出的表
table_name=$(docker exec ${container_name} mysql -u${username1} -p${password1} -e "use ${dbname};show tables" | grep -v ^Tables_in)
# table_name=$(docker exec ${container_name} mysql -u${username1} -p${password1} -e "use ${dbname};show tables" | grep indel)

# 获取备份的mysql的安全目录
secure_dir=$(docker exec ${container_name} mysql -u${username1} -p${password1} -e "show variables like '%secure%';" | grep 'priv' | awk '{print $2}')

# 创建备份目录
mkdir -p ${yingshe_dir}/${dbname}
# 备份目录需要777权限
chmod 777 ${yingshe_dir}/${dbname}

# 创建导出日志
touch ${yingshe_dir}/${dbname}/export.log
LOG="${yingshe_dir}/${dbname}/export.log"
# 导出开始时间
TIME1=$(date +%Y%m%d_%R)

# 进行循环导出每一个表的数据和结构
table_array=(${table_name})
for table in ${table_array[@]}
do
# 导出数据
docker exec ${container_name} mysql -u${username1} -p${password1} -e "use ${dbname};SELECT * FROM ${table} INTO OUTFILE '${secure_dir}/${dbname}/${table}.txt' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'  LINES TERMINATED BY '\n';"
# 导出结构
docker exec ${container_name} mysqldump -u${username1} -p${password1} -d ${dbname} ${table}  > ${yingshe_dir}/${dbname}/${table}.sql
done

# 导出时间计算
if [ $? -eq  0 ];then
    TIME2=$(date +%Y%m%d_%R)

    echo " ${TIME1} start to export.   Mysql database export Success at ${TIME2} " >> $LOG
else
    TIME2=$(date +%Y%m%d_%R)
    echo " ${TIME1} start to export.   Mysql database export Fail.Please check it. time: ${TIME2} " >>$LOG
    exit 1;
fi
