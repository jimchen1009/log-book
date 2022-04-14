
#测试使用
webhook_key=""


declare -a projectnames
projectnames[0]=pjg-server-config
projectnames[1]=pjg-rpc
projectnames[2]=pjg-common
projectnames[3]=pjg-server
projectnames[4]=pjg-app-server
projectnames[5]=pjg-battle-server
projectnames[6]=pjg-http
projectnames[7]=pjg-idip

#开发通知列表
webhook_author_list=(chenjingjun)


tool_path=`pwd`
cd ../..
path=`pwd`

author_commit=${path}/author_commit
rm -rf ${author_commit}
mkdir ${author_commit}

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

current=`date "+%Y%m%d%H%M"`
ssh_path=${path}/version
rm -rf ${ssh_path}
mkdir -p ${ssh_path}
html_path=${ssh_path}/static/version/${current}
rm -rf ${html_path}
mkdir -p ${html_path}
#资源站点名称
web_url=http://10.17.2.62:8000/static/version/${current}

author_names=""
for (( i = 0 ; i < ${#projectnames[@]}; i++ ))
do
	echo -e "\033[33m-------------------------------------------------------------------------------------------------------------------------\033[0m\n"
	project=${projectnames[$i]}
	dic_path=$path/$project
	if [ ! -x "$dic_path" ]; 
	then
		echo -e "----->> \033[31mno dictory ${dic_path}, skip project ${project}.\033[0m"
	else
		cd ${dic_path}
		version_file=${project}-${current_branch}.version
		for j in {1..20}
		do
			version_file=`echo ${version_file/\//_}`
		done
		version=`tail -n 1 ${tool_path}/${version_file}`
		commit_date=`tail -n 3 ${tool_path}/${version_file} | head -n 1`
		commit_date=${commit_date:5}
		echo -e "----->> \033[33m工程[${project}]对比的版本编号是: ${version}\033[0m"
		rm -fr ".git/rebase-merge"
		no_change=`git stash save $(date +%Y%m%d) | grep -E "No|没有"` #暂时使用这两个关键字
		git reset --hard
		git checkout .
		git checkout $current_branch
		git reset --hard origin/$current_branch
		git checkout .
		git pull --rebase
		git rebase origin/$current_branch
		echo -e "\033[31m工程[${project}]变更结果如下:\033[0m"
		project_file=${author_commit}/${project}.txt
		touch ${project_file}
		current_path=${path}/${project}${current}
		mkdir ${current_path}
		for file in `git diff --name-only ${version}`
		do
			echo ${file} >> ${project_file} 
			for author in `git log ${version}..HEAD -- ${file} | grep "Author:" | sort | uniq | awk -F ' ' '{print $2}'`
			do
				author_file=${author_commit}/${author}.txt
				if [ ! -f "$author_file" ]
				then
					if [[ "${webhook_author_list[@]}" =~ "$author" ]] 
					then
						echo ${author_file}
						if [[ "$author_names" == "" ]] 
						then
							author_names=$author
						else
							author_names=$author_names,$author
						fi
					fi
				fi
				echo "${project}/${file}" >> ${author_file}
			done
		done
		for file in `cat ${project_file}`
		do
			cp --parents ${file} ${current_path}
		done
		git reset --hard ${version}
		for file in `cat ${project_file}`
		do
			if [ "${file##*.}"x = "json"x ]
			then
				echo -e "\033[33m忽略比较文件 ${file}\033[0m"
			else 
				echo -e "\033[33m开始比较文件 ${file}\033[0m"
				#python比较工具不优化, 显示差异有误导(BCompare等其他方式替换)
				python ${tool_path}/diffhtml.py --commit-id ${version} --filename ${file} --version-path ${dic_path} --current-path ${current_path} --html-path ${html_path}/${project}
			fi
		done 
		rm -rf ${project_file}
		rm -rf ${current_path}
		git reset --hard origin/$current_branch
		git reset ${version}
	fi
	echo ""
done

echo
echo -e "----->> \033[33m通过git查看文件差异, 关闭git再按回车结束操作. \033[0m"
read 

webhook_title=$author_commit/version-title.txt

if [[ "$author_names" == "" ]] 
then
	echo "版本无相关人员差异变更." > $webhook_title
else
	python ${tool_path}/diffversion.py --author_names ${author_names} --author_path ${author_commit} --html_pathname ${html_path}/version_files.html
	cd ${ssh_path}
	# 远程操作命令需要配置root的公钥 ssh-copy-id
	tar -czf version.tar.gz *
	scp version.tar.gz root@10.17.2.62:/home/pjg/webhook
	ssh root@10.17.2.62 "cd /home/pjg/webhook; tar -zxf version.tar.gz"
	echo "版本差异部署地址(忽略json): ${web_url}/version_files.html" > $webhook_title
	cd $tool_path
fi

for (( i = 0 ; i < ${#projectnames[@]}; i++ ))
do
	echo -e "\033[33m-------------------------------------------------------------------------------------------------------------------------\033[0m\n"
	project=${projectnames[$i]}
	dic_path=${path}/${project}
	if [ ! -x "$dic_path" ]; 
	then
		echo -e "----->> \033[31mno dictory ${dic_path}, skip project ${project}.\033[0m"
	else
		cd ${dic_path}
		git reset --hard origin/${current_branch}
	fi
	echo ""
done

echo $author_names
$tool_path/webhook_sender.sh $webhook_key $webhook_title $author_names
	

echo ""
echo -e "----->> \033[33m回车结束操作. \033[0m"
read readname