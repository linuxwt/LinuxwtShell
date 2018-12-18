#!/bin/bash

if [ $# -ne 7 ];then
        echo "sorry,ou need enter the 导入库名 宿主机IP 宿主机映射端口 用户 密码 容器名 安全目录映射目录 of the scripts."
        exit -1
fi
# 变量设定
dbname="$1"
Host="$2"
port="$3"
username2="$4"
password2="$5"
container_name="$6"
yingshe_dir="$7"


# 获取mysql安全目录
secure_dir=$(docker exec ${container_name} mysql -u${username2} -p${password2} -e "show variables like '%secure%';" | grep 'priv' | awk '{print $2}')

# 获取要导入的表名
table_name=$(ls ${yingshe_dir}/${dbname} | grep txt$ | awk -F '.' '{print $1}')

# 创建导入日志
touch ${yingshe_dir}/${dbname}/import.log
LOG="${yingshe_dir}/${dbname}/import.log"
# 导入开始时间
TIME1=$(date +%Y%m%d_%R)

# 创建存放带有外键的表名文件
if [ -f "${yingshe_dir}/${dbname}/foreign_table" ];then
    mv ${yingshe_dir}/${dbname}/foreign_table ${yingshe_dir}/${dbname}/foreign_table.bak
    touch ${yingshe_dir}/${dbname}/foreign_table
else
    touch ${yingshe_dir}/${dbname}/foreign_table
fi

# 循环导入每一个表的结构和数据
table_array=(${table_name})
for table in ${table_array[@]}
do
# 导入表结构
echo "current table structure:${table}"
mysql -u ${username2} -h ${Host}  -p${password2} -P ${port} ${dbname} <  ${yingshe_dir}/${dbname}/${table}.sql

# 查看表是否有外键
foreign_num=$(docker exec ${container_name} mysql -u${username2} -p${password2} -e "use ${dbname};show create table ${table}"  | grep FOREIGN | wc -l)

if [ ${foreign_num} -eq 0 ];then
# 导入表数据
echo "current table data:${table}"
docker exec ${container_name} mysql -u${username2} -p${password2} -e "use ${dbname};LOAD DATA INFILE '${secure_dir}/${dbname}/${table}.txt' INTO TABLE ${table} FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'  LINES TERMINATED BY '\n';"
else
echo "current table foreign key:${table}"
echo "${table}" >> ${yingshe_dir}/${dbname}/foreign_table 
fi
done

#获取具有外键的表
foreign_table_name=$(cat ${yingshe_dir}/${dbname}/foreign_table)
foreign_table_name_array=(${foreign_table_name})
for foreign in ${foreign_table_name_array[@]}
do
docker exec ${container_name} mysql -u${username2} -p${password2} -e "use ${dbname};LOAD DATA INFILE '${secure_dir}/${dbname}/${foreign}.txt' INTO TABLE ${foreign} FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'  LINES TERMINATED BY '\n';"
done
# 导入时间计算
if [ $? -eq  0 ];then
    TIME2=$(date +%Y%m%d_%R)

    echo " ${TIME1} start to import.   Mysql database import Success at ${TIME2} " >> $LOG
else
    TIME2=$(date +%Y%m%d_%R)
    echo " ${TIME1} start to import.   Mysql database import Fail.Please check it. time: ${TIME2} " >>$LOG
    exit 1;
fi
