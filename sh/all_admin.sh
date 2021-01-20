#!/bin/sh

if [ $1 == "start" ]
then
  
  echo -e "\033[31m请耐心等待执行各个服务脚本,服务进程数量多...\033[0m";
  ./server_admin.sh $1 "zoo.cfg" "cd ./zookeeper-3.4.12/bin; ./zkServer.sh start ../conf/zoo.cfg; cd ../../"
  ./server_admin.sh $1 "zoo-area.cfg" "cd ./zookeeper-3.4.12/bin; ./zkServer.sh start ../conf/zoo-area.cfg; cd ../../"
  echo -e "\033[31mzookeeper关闭后等待3s, 再继续执行...\033[0m"; sleep 3s
  ./server_admin.sh $1 "tomcat-idip" "cd ./tomcat-idip/bin; ./startup.sh; cd ../../; sleep 1s"
  ./server_admin.sh $1 "RouterServer 1$" "cd ./routerserver; ./start.sh; cd ../; sleep 2s"   
  ./server_admin.sh $1 "BattleServer 1$" "cd ./battle; ./admin.sh start 1; cd ../; sleep 2s"
  ./server_admin.sh $1 "BattleServer 2$" "cd ./battle; ./admin.sh start 2; cd ../; sleep 2s"
  for((i=1;i<=15;i++));  
  do   
    ./server_admin.sh $1 "AppServerLauncher $i$" "cd ./appserver; ./appctrl.sh start $i; cd ../; sleep 1s"  
  done  
  ./server_admin.sh $1 "ServerStarter configs" "sleep 2s; cd ./server; ./startup_t.sh; cd ../; sleep 5s" 
  echo -e "\033[31m别着急, 全部进程启动完毕需要再等5s, 等待中...\033[0m"; sleep 5s
else
  if [ $1 == "stop" ]
  then
    ./server_admin.sh $1 "ServerStarter configs" "cd ./server; ./shutdown_t.sh; cd ../; sleep 1s"
    ./server_admin.sh $1 "BattleServer 1$" "cd ./battle; ./admin.sh stop 1; cd ../l"
    ./server_admin.sh $1 "BattleServer 2$" "cd ./battle; ./admin.sh stop 2; cd ../"
    for((i=1;i<=15;i++));
    do 
      ./server_admin.sh $1 "AppServerLauncher $i$" "cd ./appserver; ./appctrl.sh stop $i; cd ../"
    done
    ./server_admin.sh $1 "RouterServer 1$" "cd ./routerserver; ./shutdown.sh; cd ../"
    ./server_admin.sh $1 "tomcat-idip" "cd ./tomcat-idip/bin; ./shutdown.sh; cd ../../"
    echo -e "\033[31m关闭zookeeper之前先等待3s, 再继续执行...\033[0m"; sleep 3s
	count=`ps -ef | grep -E "ServerStarter|BattleServer|tomcat-idip|RouterServer|AppServerLauncher" | grep -v "server_admin.sh" | grep -v "grep" |wc -l`
	if [ 0 == $count ]
	then
	  ./server_admin.sh $1 "zoo.cfg" "cd ./zookeeper-3.4.12/bin; ./zkServer.sh stop ../conf/zoo.cfg; cd ../../"
      ./server_admin.sh $1 "zoo-area.cfg" "cd ./zookeeper-3.4.12/bin; ./zkServer.sh stop ../conf/zoo-area.cfg; cd ../../" 
	  echo -e "\033[31m别着急, 全部进程关闭需要再等5s, 等待中...\033[0m"; sleep 5s
	else
	  echo -e "\033[31m检测存在没有关闭的服务,请重复执行关服操作.\033[0m"; sleep 5s
	fi	
  else
    echo "do not support parameter:$1"
  fi
fi
echo -e "\033[33m查看相关服务: ps -ef | grep -E \"ServerStarter|BattleServer|zookeeper|tomcat-idip|RouterServer|AppServerLauncher\"\033[0m"
exit 0

