

echo
echo -e "\033[33m 						<ProjectG版本合并脚本>\033[0m"
echo -e "\033[33m 	工具非正式版本, 处于测试阶段, 使用工具过程中请留意结果是否与预期一致.\033[0m"
echo -e "\033[33m 	工程需要使用与工作不一致的目录[ProjectG], 因为脚本会强制还原本地修改.\033[0m"
echo -e "\033[33m 	失误恢复分支: 1.开启force push权限 2.git reset --hard commitId 3.git push --force \033[0m"
echo
echo

declare -a branchprojects
declare -a branchnames
branchnames[0]=国服
branchnames[1]=海外
branchnames[2]=国服海外共有
branchnames[3]=海外特有工程
branchnames[4]=配置文件
branchprojects[0]=pjg-server-config,pjg-rpc,pjg-common,pjg-server,pjg-app-server,pjg-battle-server,pjg-http,routerserver,pjg-idip,pjg-picture
branchprojects[1]=pjg-server-config,pjg-rpc,pjg-common,pjg-server,pjg-app-server,pjg-battle-server,pjg-http,routerserver,pjg-pay,pjg-bgm,pjg-db-job
branchprojects[2]=pjg-server-config,pjg-rpc,pjg-common,pjg-server,pjg-app-server,pjg-battle-server,pjg-http,routerserver
branchprojects[3]=pjg-pay,pjg-bgm,pjg-db-job
branchprojects[4]=pjg-server-config

#流水线的工程
pipelineprojects=(pjg-server-config pjg-rpc pjg-common pjg-server pjg-app-server pjg-battle-server pjg-http pjg-idip)

tool_path=`pwd`
./git-checkout-head.sh
cd ../..
path=`pwd`


#打印工程列表
echo -e "----->> \033[31m以下是工程对应的编号: \033[0m"
for (( i = 0 ; i < ${#branchnames[@]}; i++ ))
do
	echo -e "\033[33m$i = [${branchnames[$i]}] \033[0m"
done
read index 
allprojects=${branchprojects[0]}
branchname=${branchnames[0]}
if [[ "$index" != "" ]] 
then
	allprojects=${branchprojects[$index]}
	branchname=${branchnames[$index]}
fi

if [[ -z $allprojects ]]
then
	echo -e "\033[31m无效的工程:${current_branch}, 回车退出\033[0m"
	read
	exit 0
fi


echo -e "\033[31m本地记录分支列表: \033[0m"
cd $path/pjg-server-config
declare -a branches
for branch in `git for-each-ref --shell --format='%(refname:short)' refs/heads/`; do
	value=${branch:1:${#branch}-2}
	index=${#branches[@]}
	echo -e "\033[33m$index = [$value] \033[0m"
    branches[index]=$value
done
cd $path
echo -e "\033[31m从分支 [FROM] 合并到分支 [TO], 配置以 [CONFIG] 为准.\033[0m"
echo -e "\033[33mFROM  : 输入分支编号或者分支名称.\033[0m"
echo -e "\033[33mTO    : 输入分支编号或者分支名称.\033[0m"
echo -e "\033[33mCONFIG: 配置是TO分支为准输入to, 否则默认from.\033[0m"


echo -e "\033[31m请输入参数FROM TO CONFIG 使用空格隔开, 确认无误再按回车: \033[0m"
read parameters
array=($parameters)

#参数FROM
from_branch=""
read_from=${array[0]}
if [ -n "$(echo $read_from| sed -n "/^[0-9]\+$/p")" ]
then 
    from_branch=${branches[$read_from]}
else 
    from_branch=${read_from}
fi 

#参数TO
to_branch=""
read_to=${array[1]}
if [ -n "$(echo $read_to| sed -n "/^[0-9]\+$/p")" ]
then 
    to_branch=${branches[$read_to]}
else 
    to_branch=${read_to}
fi 


#参数CONFIG
config_branch=NONE
read_config=${array[2]}
if [[ "$read_config" == to ]] 
then
	config_branch=$to_branch
fi
if [[ "$read_config" == from ]] 
then
	config_branch=$from_branch
fi

mentioned_list="maiwei,weikeyu"
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
if [[ "$to_branch" == ko* ]] 
then
	mentioned_list="lijunying,yangjiuzhou,hejue"
fi

echo $allprojects
echo $mentioned_list

merge_filename=merge_branch_log.txt
username=`git config user.name`
current0=`date "+%Y-%m-%d_%H%M%S"`
temp_file=${tool_path}/merge_branch_log${current0}.txt
touch $temp_file


webhook_message=webhook_message.txt
rm ${webhook_message}
touch ${webhook_message}

echo "💡 服务端分支合并开始" > ${webhook_message}
echo "操作用户: ${username}" >> ${webhook_message}
echo "涉及工程: ${branchname}" >> ${webhook_message}
echo "来源分支: ${from_branch}" >> ${webhook_message}
echo "目标分支: **${to_branch}** 暂停提交" >> ${webhook_message}
echo "配置为准: **${config_branch}**" >> ${webhook_message}
${tool_path}/webhooks_sender.sh 0 $webhook_message $mentioned_list

current1=`date "+%Y-%m-%d %H:%M:%S"`
echo "" >> ${temp_file}
echo "================================ 合并[${from_branch}]到[${to_branch}], 配置[${config_branch}]为准, 操作的用户[${username}], 时间[${current1}] ================================" >> ${temp_file}
echo "" >> ${temp_file}

projects=(`echo $allprojects | tr ',' ' '`)
for (( i = 0 ; i < ${#projects[@]}; i++ ))
do
	project=${projects[$i]}
	conflict_branch=NONE
	to_branch_suffix=empty
	if [[ "$project" == pjg-server-config ]] 
	then
		if [[ $config_branch = $to_branch ]] 
		then
			to_branch_suffix=json
		fi
		# 去掉参数,
		#conflict_branch=$config_branch
	fi
	${tool_path}/merge_branch.sh $project $from_branch $to_branch $conflict_branch $to_branch_suffix $temp_file
	echo -e "\033[33m-------------------------------------------------------------------------------------------------------------------------\033[0m\n"
done

cat $temp_file
brief_meaage=`cat ${temp_file} | grep 提交 | grep 工程名`
echo -e "\033[33m简要信息:\n${brief_meaage}\n\033[0m"
commit_meaage=`cat ${temp_file} | grep 手动 | grep 工程名`

if [[ -z $commit_meaage ]]
then
	echo -e "\033[33m无冲突需要解决, 已执行提交.\n\033[0m"
else
	echo -e "\033[33m解决冲突并手动提交,详情:\n${commit_meaage}\n\033[0m"
	if [ "$username" = "chenjingjun" ] 
	then
		start "C:\ProjectG-V0"
	fi
fi

echo -e "----->> \033[31m打开pineline地址请输入: Okay \033[0m"
read linkUrl
if [[ "$linkUrl" == Okay ]] 
then
	for (( i = 0 ; i < ${#projects[@]}; i++ ))
	do
		project=${projects[$i]}
		if [[ "${pipelineprojects[@]}"  =~ "${project}" ]]; 
		then
			start https://gitlab.bt/pjg/${project}/-/pipelines
		fi
	done
fi

echo -e "----->> \033[31m完成合并请输入: Okay \033[0m"
read finishCode

cd ${tool_path}
if [[ "$finishCode" == Okay ]] 
then
	echo "💡 服务端分支合并完成" > ${webhook_message}
	echo "操作用户: ${username}" >> ${webhook_message}
	echo "涉及工程: ${branchname}" >> ${webhook_message}
	echo "来源分支: ${from_branch}" >> ${webhook_message}
	echo "目标分支: **${to_branch}** 恢复提交" >> ${webhook_message}
	echo "配置为准: **${config_branch}**" >> ${webhook_message}
	conflit_json_files=`cat $temp_file | grep  -E "AA|UU|M" | grep ".json" | awk '{print "· "$0}' | sort`
	#if [ -n "$conflit_json_files" ]; then
	#	echo "配置存在冲突[部分多语言导致]:" >> ${webhook_message}
	#	echo "$conflit_json_files" >> ${webhook_message}
	#fi
	merge_file=${tool_path}/${merge_filename}
	touch $merge_file
	cat $temp_file >> $merge_file
	rm -rf $temp_file
	${tool_path}/webhooks_sender.sh 1 $webhook_message $mentioned_list
	message="${branchname},合并[${from_branch}]到[${to_branch}]的日志"
	git commit ${merge_filename} -m ${message}
	git push
fi
