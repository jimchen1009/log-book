
echo
echo -e "\033[33m 						<批量生成版本commit的版本编号>\033[0m"
echo -e "\033[33m 	包括工程 pjg-server-config pjg-rpc pjg-common pjg-server pjg-app-server pjg-battle-server等.\033[0m"
echo
echo

tool_path=`pwd`
lockfile=$tool_path/lock.txt
if [ -f "$lockfile" ]
then
	echo -e "\033[31m----------------------批量生成版本号操作不允许操作,请找对应的负责人!----------------------\033[0m"
	read
	exit 0
fi

echo -e "----->> \033[31m请输入操作的原因. \033[0m"
read reason
if [[ "$reason" == "" ]] 
then
	echo -e "----->> \033[31m没有输入操作的原因, 回车直接退出操作.\033[0m"
	read
	exit 0
fi

current=`date "+%Y-%m-%d %H%M%S"`
echo "" >> ${lockfile}
echo "文件锁, 不能删除！ [${current}]" >> ${lockfile}
echo "" >> ${lockfile}

cd ../..
path=`pwd`

#需要生成记录的工程
declare -a projects
projects[0]=pjg-server-config
projects[1]=pjg-common
projects[2]=pjg-server
projects[3]=pjg-app-server
projects[4]=pjg-battle-server
projects[5]=pjg-rpc
projects[6]=pjg-http

for project in ${projects[@]}
do
	cd $path/$project
	current_branch=`git branch | grep "*"`
	current_branch=${current_branch:2}
	no_change=`git stash save Jim $(date +%Y%m%d) | grep -E "No|没有"` #暂时使用这两个关键字
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
	echo "#原因: ${reason}" >> ${filename}
	version=`git rev-parse HEAD`
	echo "${version}" >> ${filename}
	if [[ "$no_change" == "" ]] 
	then
		git stash pop
	fi
	echo -e "\033[33m版本号生成: ${version}, 文件路径: ${filename}\033[0m\n"
	echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"
	echo "工程: ${project}" >> ${lockfile}
	echo "commit版本号: ${version}" >> ${lockfile}
done

cd $tool_path
echo -e "----->> \033[31m按回车键结束操作.\033[0m"
read
exit 0


