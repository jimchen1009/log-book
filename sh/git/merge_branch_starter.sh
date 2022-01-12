
#国服的工程
local_projects=pjg-server-config,pjg-rpc,pjg-common,pjg-server,pjg-app-server,pjg-battle-server,pjg-http,routerserver,pjg-idip,pjg-picture
#海外的工程
bt_allprojects=pjg-server-config,pjg-rpc,pjg-common,pjg-server,pjg-app-server,pjg-battle-server,pjg-http,routerserver,pjg-pay,pjg-bgm,pjg-db-job
#海外特有的工程
btdev_projects=pjg-pay,pjg-bgm,pjg-db-job

from_branch=$1
to_branch=$2

allprojects=$local_projects

mentioned_list=""

if [[ "$3" == bt ]] 
then
	allprojects=$bt_allprojects
fi
if [[ "$3" == btdev ]] 
then
	allprojects=$btdev_projects
fi
if [[ "$to_branch" == tw* ]] 
then
	mentioned_list=""
else
	if [[ "$to_branch" == xm* ]] 
	then
		mentioned_list=""
	else
		if [[ "$to_branch" == jp* ]] 
		then
			mentioned_list=""
		else
			mentioned_list="@all"
		fi
	fi
fi

echo $allprojects
echo $mentioned_list

current0=`date "+%Y-%m-%d_%H%M%S"`
temp_file=merge_branch_log${current0}.txt
touch $temp_file

webhook_key="3b26de32-5b08-496e-9d6c-9e9214065f77"

webhook_message=webhook_message.txt
rm ${webhook_message}
touch ${webhook_message}
echo "【服务端】开始合并【${from_branch}】到【${to_branch}】,【暂停提交${to_branch}】." > ${webhook_message}

./webhook_sender.sh $webhook_key $webhook_message $mentioned_list
./merge_branch_all.sh $allprojects $from_branch $to_branch $temp_file

debug_file=merge_branch_log.txt
touch $debug_file
cat $temp_file

echo -e "----->> \033[31m完成合并请输入: Okay \033[0m"
read finishCode

if [[ "$finishCode" == Okay ]] 
then
	echo "【服务端】完成合并【${from_branch}】到【${to_branch}】,【恢复提交】." > ${webhook_message}
	conflit_json_files=`cat $temp_file | grep  -E "AA|UU|M" | grep ".json" | awk '{print "· "$0}' | sort`
	#if [ -n "$conflit_json_files" ]; then
	#	echo "配置存在冲突[部分多语言导致]:" >> ${webhook_message}
	#	echo "$conflit_json_files" >> ${webhook_message}
	#fi
	cat $temp_file >> $debug_file
	rm -rf $temp_file
	./webhook_sender.sh $webhook_key $webhook_message $mentioned_list
	#if [ -n "$conflit_json_files" ]; then
	#	echo "【服务端】完成合并【${from_branch}】到【${to_branch}】,【恢复提交】." > ${webhook_message}
	#	echo " 检查配置是否需要同步: AA|UU 完全冲突, M 未同步." >> ${webhook_message}
	#	./webhook_sender.sh $webhook_key $webhook_message $mentioned_list
	#fi
fi
