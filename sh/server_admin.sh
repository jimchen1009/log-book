#!/bin/sh

count=`ps -ef | grep "$2" | grep -v "server_admin.sh" | grep -v "grep" |wc -l`
#echo $count
if [ "$1" == "start" ] 
then
  if [ 0 == $count ]
  then
   eval "$3"
  else
    echo "检测存在服务,不能重复启动: $2"
  fi	
else 
  if [ "$1" == "stop" ]
  then
    if [ 0 == $count ]
    then
      echo "检测不存在服务,不需要关闭: $2"
     else
       eval "$3"
    fi  
  fi 
fi
