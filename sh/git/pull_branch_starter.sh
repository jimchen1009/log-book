
echo
echo -e " 				无脑pull当前目录下所有git工程"
echo -e "	1. 只支持当前目录下的工程，不会递归"
echo -e "	2. 获取最新文件存在冲突的,注意查看输出的报错信息"
echo

path=`pwd`

declare -a projects


for project in $(ls $path); do
	checkgit=`ls $path/$project -a | grep .git`
	if [[ "$checkgit" != "" ]] 
	then
		echo -e "----->> \033[31mpull current branch $project \033[0m"
		cd $path/$project
		no_change=`git stash save Jim $(date +%Y%m%d) | grep -E "No|没有"` #暂时使用这两个关键字
		git pull --rebase
		if [[ "$no_change" == "" ]] 
		then
			git stash pop
		fi
		projects[${#projects[@]}]=$project
		echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"
	fi
done

cd $path

echo -e "----->> \033[31mthe pull projects list:\033[0m"
#rm projects.txt
for project in ${projects[@]}; do
	echo -e "\033[33m${project}\033[0m"
    #echo ${project} >> projects.txt;
done
  
echo 
read -n 1 -p "enter any key to quit."

