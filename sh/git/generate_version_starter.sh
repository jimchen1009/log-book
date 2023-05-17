
echo
echo -e "\033[33m 						<批量生成版本commit的版本编号>\033[0m"
echo -e "\033[33m 	工具非正式版本, 处于测试阶段, 使用工具过程中请留意结果是否与预期一致.\033[0m"
echo -e "\033[33m 	工程需要使用与工作不一致的目录[ProjectG], 因为脚本会强制还原本地修改.\033[0m"
echo
echo


tool_path=`pwd`
./git-checkout-head.sh
cd ../..
path=`pwd`


#获取当前的分支列表, 并且打印出来
echo -e "\033[31m本地记录分支列表: \033[0m"
cd $path/pjg-server-config
declare -a branches
for branch in `git for-each-ref --shell --format='%(refname:short)' refs/heads/`; do
	value=${branch:1:${#branch}-2}
	index=${#branches[@]}
	echo -e "\033[33m$index = [$value] \033[0m"
    branches[index]=$value
done
echo -e "\033[31m默认分支[release/weekly-2], 否则请输入编号或者分支: \033[0m"
read readname 
current_branch="" 
if [[ "$readname" == "" ]] 
then
	current_branch=release/weekly-2
else
	if [ -n "$(echo $readname| sed -n "/^[0-9]\+$/p")" ]
	then 
		current_branch=${branches[$readname]}
	else 
		current_branch=${readname}
	fi 
	
fi

if [[ -z $current_branch ]]
then
	echo -e "\033[31m无效的分支:${current_branch},回车退出\033[0m"
	read
	exit 0
fi
cd $path


lockfile=${current_branch}.lock

for i in {1..20}
do
	lockfile=`echo ${lockfile/\//_}`
done

filenames=${lockfile}

lockfile=${tool_path}/${lockfile}
touch ${lockfile}

operator=`git config user.name`
echo -e "\033[33m操作者:${operator}, 分支名:${current_branch}, 确认无误输入\033[31myes\033[0m.\033[0m"
read yes
if [[ "$yes" == "yes" ]] 
then
	rm -fr ${lockfile}
fi

if [ -f "$lockfile" ]
then
	echo -e "\033[31m文件锁${lockfile}存在,不允许操作!\033[0m"
	read
	exit 0
fi

echo -e "\033[31m请留意输出的日志, 开始执行 ......\033[0m"

cd $tool_path

current=`date "+%Y-%m-%d %H:%M:%S"`
echo "" >> ${lockfile}
echo "文件锁, 不能删除！ [${current}]" >> ${lockfile}
echo "" >> ${lockfile}


#需要生成记录的工程
declare -a projects
projects[0]=pjg-server-config
projects[1]=pjg-common
projects[2]=pjg-server
projects[3]=pjg-app-server
projects[4]=pjg-battle-server
projects[5]=pjg-rpc
projects[6]=pjg-http
projects[7]=pjg-idip


for project in ${projects[@]}
do
	cd $tool_path
	filename=${project}-${current_branch}.version
	for i in {1..20}
	do
		filename=`echo ${filename/\//_}`
	done
	filename=${tool_path}/${filename}
	if [ ! -f "${filename}" ]
	then
		touch ${filename}
		git add ${filename}
	fi
	filenames="${filenames} ${filename}"
	dic_path=$path/$project
	if [ ! -d "$dic_path" ]; 
	then
		echo -e "\033[31m工程目录[$project]不存在, 退出!\033[0m"
		read
		exit 0
	fi
	cd $dic_path
	rm -fr ".git/rebase-merge"
	git checkout ${current_branch}
	git reset --hard origin/${current_branch}
	git checkout .
	git pull --rebase
	git rebase origin/${current_branch}
	echo "" >> ${filename}
	echo "#" >> ${filename}
	echo "#日期: ${current}" >> ${filename}
	echo "#操作: ${operator}" >> ${filename}
	version=`git rev-parse HEAD`
	echo "${version}" >> ${filename}
	echo -e "\033[33m版本号生成: ${version}, 文件路径: ${filename}\033[0m\n"
	echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"
	echo "" >> ${lockfile}
	echo "工程: ${project}" >> ${lockfile}
	echo "commit版本号: ${version}" >> ${lockfile}
done

cd $tool_path
git status -s
echo -e "\033[33m以上是git变更信息, 确认无误输入\033[31myes\033[0m.\033[0m"
read commit
if [[ "$commit" == "yes" ]] 
then
	git commit ${filenames} -m "分支'${current_branch}'的commit版本号, 工具提交"
	git push
	webhook_message=webhook_message.txt
	rm ${webhook_message}
	touch ${webhook_message}
	echo "💡 后端发版记录commit版本号" >> ${webhook_message}
	echo "操作者: ${operator}" >> ${webhook_message}
	echo "分支: **${current_branch}**" >> ${webhook_message}
	${tool_path}/webhooks_sender.sh 1 $webhook_message $operator
	echo -e "\033[31m完成操作, 回车退出.\033[0m"
	read
else
	echo -e "\033[31m操作不提交git, 退出.\033[0m"
	sleep 2s
fi
exit 0


