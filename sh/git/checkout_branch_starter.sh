

echo -e " 							切分支脚本工具说明"
echo -e " 	1. 包括工程 pjg-server-config pjg-rpc pjg-common pjg-server pjg-app-server."
echo -e " 	2. 列举的分支名称，是pjg-server-config本地所有分支，没有拉取的分支没有显示."
echo -e " 	3. 每个工程的分支名称需要一致[默认名称], 例如: develop分支，pjg-server-config, pjg-rpc 等工程本地名称都是develop."
echo -e " 	4. 第一次输入切分支的工程编号, 多个编号连续输入,如 0123 这样子, 不输入默认全部工程."
echo -e " 	4. 第二次输入分支的编号, 只能选择一个分支."

path=`pwd`

declare -a projectnames
projectnames[0]=pjg-server-config
projectnames[1]=pjg-rpc
projectnames[2]=pjg-common
projectnames[3]=pjg-server
projectnames[4]=pjg-app-server

#打印工程列表
echo -e "----->> \033[31mplease enter nothing or the numbers of the projects: \033[0m"

for (( i = 0 ; i < ${#projectnames[@]}; i++ ))
do
	echo -e "\033[33m$i = [${projectnames[$i]}] \033[0m"
done


#输入工程编号
read indexes
echo



#根据输入编号初始化选择的工程
declare -a projects
if [[ "$indexes" == "" ]] 
then
	for (( i = 0 ; i < ${#projectnames[@]}; i++ ))
	do
		projects[$i]=${projectnames[$i]}
	done
else
	for (( i = 0; i < ${#indexes}; i++ )); do
		index=${indexes:$i:1}
		value=${projectnames[$index]}
		projects[${#projects[@]}]=$value
	done
fi



#获取当前的分支列表, 并且打印出来
cd $path/pjg-server-config

declare -a branches

echo -e "----->> \033[31mplease enter the number of the branch: \033[0m"

for branch in `git for-each-ref --shell --format='%(refname:short)' refs/heads/`; do
	value=${branch:1:${#branch}-2}
	index=${#branches[@]}
	echo -e "\033[33m$index = [$value] \033[0m"
    branches[index]=$value
done

#输入分支编号
cd $path

read index 




#获取当前选择的分支
echo
echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"

checkout_branch=${branches[$index]}



#开始切分支
for (( i = 0 ; i < ${#projects[@]}; i++ ))
do
	project=${projects[$i]}
	dic_path=$path/$project
	if [ ! -x "$dic_path" ]; 
	then
		echo -e "----->> \033[31mno dictory $dic_path, skip project $project.\033[0m"
	else
		./checkout_branch.sh $path $project $checkout_branch
	fi
	echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"
done

read -n 1 -p "enter any key to quit."

