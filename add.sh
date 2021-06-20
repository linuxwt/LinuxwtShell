#!/bin/bash
# 1.txt是一个每一行都有一个数的文件，这个脚本可以用来计算某一列的值，
# 比如当我们过滤出某一列的所有值像计算一下总和，可以使用此脚本
a=$(cat 1.txt)
b=($a)
sum=0
for (( i=0;i<12;i++ )) 
do
     sum=$(( ${b[${i}]} + $sum ));

done
echo $sum
