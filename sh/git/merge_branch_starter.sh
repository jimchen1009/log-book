
#国服的工程
local_projects=pjg-server-config,pjg-rpc,pjg-common,pjg-server,pjg-app-server,pjg-battle-server,pjg-http,routerserver,pjg-idip,pjg-picture
#海外的工程
bt_allprojects=pjg-server-config,pjg-rpc,pjg-common,pjg-server,pjg-app-server,pjg-battle-server,pjg-http,routerserver,pjg-pay,pjg-bgm,pjg-db-job
#海外特有的工程
btdev_projects=pjg-pay,pjg-bgm,pjg-db-job

from_branch=$1
to_branch=$2

config_branch=$from_branch
if [[ "$3" == config_from ]] 
then
	config_branch=$from_branch
fi
if [[ "$3" == config_to ]] 
then
	config_branch=$to_branch
fi

allprojects=$local_projects
#allprojects=pjg-server-config
if [[ "$4" == bt ]] 
then
	allprojects=$bt_allprojects
fi
if [[ "$4" == btdev ]] 
then
	allprojects=$btdev_projects
fi

mentioned_list="@all"
if [[ "$to_branch" == tw* ]] 
then
	mentioned_list="zouwei,wudi"
fi
if [[ "$to_branch" == xm* ]] 
then
	mentioned_list="huangyangting,hezhiqing"
fi
if [[ "$to_branch" == jp* ]] 
then
	mentioned_list="situqianmin,yangjiuzhou,chenpeijie1"
fi


tool_path=`pwd`
git reset --quiet HEAD
git checkout -- .
cd ..
no_change=`git stash save Jim $(date +%Y%m%d) | grep -E "No|没有"` #暂时使用这两个关键字
git pull --rebase
if [[ "$no_change" == "" ]] 
then
	git stash pop
fi
cd ..

echo $allprojects
echo $mentioned_list

merge_filename=merge_branch_log.txt
username=`git config user.name`
current0=`date "+%Y-%m-%d_%H%M%S"`
temp_file=${tool_path}/merge_branch_log${current0}.txt
touch $temp_file

#以下是测试使用的
#webhook_key=""

webhook_message=webhook_message.txt
rm ${webhook_message}
touch ${webhook_message}

echo "【服务端】开始合并【${from_branch}】到【${to_branch}】,配置【${config_branch}】为准\n【暂停提交${to_branch}】." > ${webhook_message}
${tool_path}/webhook_sender.sh $webhook_key $webhook_message $mentioned_list

current1=`date "+%Y-%m-%d %H:%M:%S"`
echo "" >> ${temp_file}
echo "================================ 合并[${from_branch}]到[${to_branch}], 配置[${config_branch}]为准, 操作的用户[${username}], 时间[${current1}] ================================" >> ${temp_file}
echo "" >> ${temp_file}

projects=(`echo $allprojects | tr ',' ' '`)
for (( i = 0 ; i < ${#projects[@]}; i++ ))
do
	project=${projects[$i]}
	conflict_branch=NONE
	commit_none=no
	if [[ "$project" == pjg-server-config ]] 
	then
		if [[ $config_branch = $to_branch ]] 
		then
			commit_none=yes
		fi
		conflict_branch=$config_branch
	fi
	${tool_path}/merge_branch.sh $project $from_branch $to_branch $conflict_branch $commit_none $temp_file
	echo -e "\033[33m-------------------------------------------------------------------------------------------------------------------------\033[0m\n"
done

cat $temp_file
brief_meaage=`cat ${temp_file} | grep 提交 | grep 工程名`
echo -e "\033[33m简要信息:\n${brief_meaage}\n\033[0m"
commit_meaage=`echo ${brief_meaage} | grep 手动`
echo -e "\033[33m手动提交信息:\n${commit_meaage}\n\033[0m"

echo -e "----->> \033[31m完成合并请输入: Okay \033[0m"
read finishCode

cd ${tool_path}
if [[ "$finishCode" == Okay ]] 
then
	echo "操作用户:${username}\n【服务端】完成合并【${from_branch}】到【${to_branch}】,配置【${conflict_branch}】为准\n【恢复提交${to_branch}】." > ${webhook_message}
	conflit_json_files=`cat $temp_file | grep  -E "AA|UU|M" | grep ".json" | awk '{print "· "$0}' | sort`
	#if [ -n "$conflit_json_files" ]; then
	#	echo "配置存在冲突[部分多语言导致]:" >> ${webhook_message}
	#	echo "$conflit_json_files" >> ${webhook_message}
	#fi
	merge_file=${tool_path}/${merge_filename}
	touch $merge_file
	cat $temp_file >> $merge_file
	rm -rf $temp_file
	${tool_path}/webhook_sender.sh $webhook_key $webhook_message $mentioned_list
	#if [ -n "$conflit_json_files" ]; then
	#	echo "【服务端】完成合并【${from_branch}】到【${to_branch}】,【恢复提交】." > ${webhook_message}
	#	echo " 检查配置是否需要同步: AA|UU 完全冲突, M 未同步." >> ${webhook_message}
	#	./webhook_sender.sh $webhook_key $webhook_message $mentioned_list
	#fi
	git commit ${merge_filename} -m '工具提交合并日志'
	git pull
fi
