#!/bin/bash
##过滤出当前目录下的21号创建的文件##

>/tmp/num.txt
>/tmp/file.txt
>/tmp/file2.txt
> test.txt

ls -l $PWD | awk -F ' ' '{print $7}' >> /tmp/num.txt
ls -l $PWD | awk -F ' ' '{print $9}' >> /tmp/file.txt

sed -i '1d' /tmp/num.txt
sed -i '1d' /tmp/file.txt

paste /tmp/num.txt /tmp/file.txt > /tmp/file2.txt
while read num file
do
    [ ${num} -eq 21 ] && echo -e  "${num}\t${file}" >> test.txt  
done < /tmp/file2.txt
