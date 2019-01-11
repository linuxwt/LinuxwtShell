#!/bin/bash

# 该脚本按照文件种第二列中的某几个匹配项来过滤文件
echo -n "please enter the filename which you wangte to spilt and field1 field2 field3 of the condition ->"
read file_name field1 field2 field3
field_name=(${field1} ${field2} ${field3})
for prog in ${field_name[@]}
do
    a=$(cat ${file_name} | awk '{print $2}' | grep -n ${prog} | awk -F ':' '{print $1}')
    b=($a)
for proc in ${b[@]}
do
    sed -n "${proc}p" ${file_name} >> ${prog}.txt
done
done
