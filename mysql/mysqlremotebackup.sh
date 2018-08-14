#!/bin/bash

# 设定要备份的数据库变量,如果是多个数据库可以使用数组
# database=(database1 database2 ... databasen)
database=dbname
# 创建备份数据的存放目录以及脚本存放目录，这样方便以后查看和管理
basedir=/server/backup/
scriptsdir=/server/scripts/
# 判断并创建存放目录
if [ ! -d $basedir ];then
	mkdir -p $basedir
fi
if [ ! -d $scriptsdir ];then
	mkdir -p $scriptsdir
fi
# 循环迭代变零中的元素（即数据库）进行备份操作
for db in $database
# 若是多个数据库，这里的循环写成for db in ${database[@]}
do
	# 具体的备份操作
	/bin/nice -n 19 /usr/local/mysql/bin/mysqldump -h ip -u username -ppassword --databases $db > $basedir$db-$(date +%Y%m%d).sql
	# 删除超过了7天的备份数据
	find $basedir -mtime +7 -name "*.sql" -exec rm -Rf '{}' \;
done
# 将脚本移到我们设定好的目录
if [ ! -f $scriptsdir$0 ];then
	mv $0 $scriptsdir
fi
# 上面的dbname ip username password更换成你自己的
