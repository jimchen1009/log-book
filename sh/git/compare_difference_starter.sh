
echo
echo -e " 							比较指定与当前最新版本之间差异"
echo -e " 	1. 包括工程 pjg-server-config pjg-rpc pjg-common pjg-server pjg-app-server pjg-battle-server等."
echo -e " 	2. 列举的分支名称，是pjg-server-config本地所有分支，没有checkout过的分支没有显示."
echo -e " 	3. 每个工程的分支名称需要一致[默认名称], 例如: develop分支，pjg-server-config, pjg-rpc 等工程本地名称都是develop."
echo -e " 	4. 第一次输入需要比较的工程编号."
echo -e " 	4. 第二次输入需要比较的版本号[不输入默认记录版本号]."

tool_path=`pwd`
cd ../..
path=`pwd`

declare -a projectnames
projectnames[0]=pjg-server-config
projectnames[1]=pjg-common
projectnames[2]=pjg-server
projectnames[3]=pjg-app-server
projectnames[4]=pjg-battle-server
projectnames[5]=pjg-rpc
projectnames[6]=pjg-http

#
for (( i = 0 ; i < ${#projectnames[@]}; i++ ))
do
	echo -e "\033[33m$i = [${projectnames[$i]}] \033[0m"
done
echo -e "----->> \033[31m请输入工程的编号. \033[0m"
read index
if [[ "$index" == "" ]] 
then
	echo -e "----->> \033[31m没有选择工程编号, 回车直接退出操作.\033[0m"
	read
	exit 0
fi
project=${projectnames[${index}]}
if [[ "$project" == "" ]] 
then
	echo -e "----->> \033[31m工程不存在, 回车直接退出操作.\033[0m"
	read
	exit 0
fi
dic_path=$path/$project
if [ ! -d "$dic_path" ]; 
then
	echo -e "----->> \033[31m工程目录不存在, 回车直接退出操作.\033[0m"
	read
	exit 0
fi

#
cd $dic_path
current_branch=`git branch | grep "*"`
current_branch=${current_branch:2}


#
echo
echo -e "----->> \033[33mcommit记录例子: SHA-1: 778aa8efcec532d95f1b1dc448c63a87a04c91cb\033[0m"
echo -e "----->> \033[33m例子commit版本编号是: 778aa8efcec532d95f1b1dc448c63a87a04c91cb\033[0m"
echo -e "----->> \033[33m当前分支:${current_branch}, 工程:${project}\033[0m \033[31m请输入需要对比差异的commit版本编号[不填写默认]\033[0m"
read version 
if [[ "$version" == "" ]] 
then
	version_file=${project}-${current_branch}.version
	for i in {1..20}
	do
		version_file=`echo ${version_file/\//_}`
	done
	version=`tail -n 1 ${tool_path}/${version_file}`
fi
if [[ "$version" == "" ]] 
then
	echo -e "----->> \033[31m版本编号为空, 回车直接退出操作.\033[0m"
	read
	exit 0
fi
echo -e "----->> \033[33m对比的版本编号是: ${version}\033[0m"

# 复制的目录
directories=(configs,resources,src,env,proto,tsssdk,thrift,META-INF,WEB-INF)

echo
echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"
no_change=`git stash save Jim $(date +%Y%m%d) | grep -E "No|没有"` #暂时使用这两个关键字
git reset --hard
git pull --rebase

current=`date "+%Y-%m-%d_%H%M%S"`
copy_path=$path/${project}_${current}
rm -rf $copy_path
mkdir $copy_path
for file in $dic_path/*
do
	if [ -d "$file" ]
	then
		name=`basename $file`
		if [[ "${directories[@]}"  =~ "$name" ]]; then
			cp -r $file $copy_path
		fi
	else
		cp -r $file $copy_path
	fi
done
git reset --hard $version
cp -r $copy_path/. $dic_path/.


echo
echo -e "----->> \033[33m通过git查看文件差异, 关闭git再按回车结束操作. \033[0m"
read 
git reset --hard origin/${current_branch}
git pull --rebase
if [[ "$no_change" == "" ]] 
then
	echo -e "----->> \033[31还原本地保存的修改...\033[0m"
	git stash pop
fi
rm -rf $copy_path

