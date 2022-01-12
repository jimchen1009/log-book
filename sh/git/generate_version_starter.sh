
echo
echo -e "\033[33m 						<批量生成版本commit的版本编号>\033[0m"
echo -e "\033[33m 	包括工程 pjg-server-config pjg-rpc pjg-common pjg-server pjg-app-server pjg-battle-server等.\033[0m"
echo -e "\033[33m 	操作的分支以pjg-server-config本地分支为准, pjg-server-config为weekly2, 其他工程均为weekly2.\033[0m"
echo
echo


tool_path=`pwd`
cd ../..
path=`pwd`

cd $path/pjg-server-config
current_branch=`git branch | grep "*"`
current_branch=${current_branch:2}

lockfile=${current_branch}.lock
for i in {1..20}
do
	lockfile=`echo ${lockfile/\//_}`
done
lockfile=${tool_path}/${lockfile}
if [ -f "$lockfile" ]
then
	echo -e "\033[31m----------------------批量生成版本号操作不允许操作,请找对应的负责人!----------------------\033[0m"
	read
	exit 0
fi

echo -e "----->> \033[31m请输入操作用户. \033[0m"
read operator
if [[ "$operator" == "" ]] 
then
	echo -e "----->> \033[31m没有输入操作用户, 回车直接退出操作.\033[0m"
	read
	exit 0
fi

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
	cd $path/$project
	no_change=`git stash save Jim $(date +%Y%m%d) | grep -E "No|没有"` #暂时使用这两个关键字
	project_branch=`git branch | grep "*"`
	project_branch=${project_branch:2}
	if [[ "$current_branch" != "$project_branch" ]] 
	then
		check_branch=`git branch | grep "$current_branch"`
		check_branch=`echo $check_branch`
		if [[ "$check_branch" != "$current_branch" ]] 
		then
			git checkout -b $current_branch --track origin/$current_branch	
		fi
		git checkout $current_branch
	fi
	git reset --hard origin/${current_branch}
	git pull --rebase
	filename=${project}-${current_branch}.version
	for i in {1..20}
	do
		filename=`echo ${filename/\//_}`
	done
	filename=$tool_path/$filename
	echo "" >> ${filename}
	echo "#" >> ${filename}
	echo "#日期: ${current}" >> ${filename}
	echo "#操作: ${operator}" >> ${filename}
	version=`git rev-parse HEAD`
	echo "${version}" >> ${filename}
	if [[ "$no_change" == "" ]] 
	then
		git stash pop
	fi
	echo -e "\033[33m版本号生成: ${version}, 文件路径: ${filename}\033[0m\n"
	echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"
	echo "" >> ${lockfile}
	echo "工程: ${project}" >> ${lockfile}
	echo "commit版本号: ${version}" >> ${lockfile}
	cd $tool_path #直接跳出去, 防止cd $path/$projects失败后用上一个目录操作
done

cd $tool_path
echo -e "----->> \033[31m按回车键结束操作.\033[0m"
read
exit 0


