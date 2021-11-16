
tool_path=`pwd`
cd ../..
path=`pwd`

author_commit=$path/author_commit
rm -rf $author_commit
mkdir $author_commit

#测试使用
webhook_url=""


declare -a projectnames
projectnames[0]=pjg-server-config
projectnames[1]=pjg-common
projectnames[2]=pjg-server
projectnames[3]=pjg-app-server
projectnames[4]=pjg-battle-server
projectnames[5]=pjg-rpc
projectnames[6]=pjg-http

declare -a no_changes

for (( i = 0 ; i < ${#projectnames[@]}; i++ ))
do
	echo -e "\033[33m-------------------------------------------------------------------------------------------------------------------------\033[0m\n"
	project=${projectnames[$i]}
	dic_path=$path/$project
	if [ ! -x "$dic_path" ]; 
	then
		echo -e "----->> \033[31mno dictory ${dic_path}, skip project ${project}.\033[0m"
	else
		cd $dic_path
		current_branch=`git branch | grep "*"`
		current_branch=${current_branch:2}
		version_file=${project}-${current_branch}.version
		for j in {1..20}
		do
			version_file=`echo ${version_file/\//_}`
		done
		version=`tail -n 1 ${tool_path}/${version_file}`
		commit_date=`tail -n 3 ${tool_path}/${version_file} | head -n 1`
		commit_date=${commit_date:5}
		echo -e "----->> \033[33m工程[${project}]对比的版本编号是: ${version}\033[0m"
		no_change=`git stash save Jim $(date +%Y%m%d) | grep -E "No|没有"` #暂时使用这两个关键字
		no_changes[$i]=$no_change
		git reset --hard
		git pull --rebase
		for file in `git diff --name-only $version`
		do
			for author in `git log --since "${commit_date}" ${file} | grep "Author:" | sort | uniq | awk -F ' ' '{print $2}'`
			do
				author_file=$author_commit/$author
				if [ ! -f "$author_file" ]
				then
					echo "${author}" >> ${author_file}
				fi
				echo "${project}  ${file}" >> ${author_file}
			done
		done
		echo -e "\033[31m工程[${project}]变更结果如下:\033[0m"
		git reset $version
	fi
	echo ""
done

echo
echo -e "----->> \033[33m通过git查看文件差异, 关闭git再按回车结束操作. \033[0m"
read 


for (( i = 0 ; i < ${#projectnames[@]}; i++ ))
do
	echo -e "\033[33m-------------------------------------------------------------------------------------------------------------------------\033[0m\n"
	project=${projectnames[$i]}
	dic_path=$path/$project
	if [ ! -x "$dic_path" ]; 
	then
		echo -e "----->> \033[31mno dictory ${dic_path}, skip project ${project}.\033[0m"
	else
		cd $dic_path
		current_branch=`git branch | grep "*"`
		current_branch=${current_branch:2}
		git reset --hard origin/${current_branch}
		git pull --rebase
		no_change=${no_changes[$i]}
		if [[ "$no_change" == "" ]] 
		then
			echo -e "----->> \033[31m工程[${project}]还原本地保存的修改...\033[0m"
			git stash pop
		else
			echo -e "----->> \033[31m工程[${project}]没有本地修改...\033[0m"
		fi
	fi
	echo ""
done

cd $author_commit
for author in `ls -1 .`
do
	author_file=$author_commit/$author
	webhook_title=${author_file}_message.txt
	echo "--------------------------------------分割线以下,当前版本涉及的变更文件:" > $webhook_title
	$tool_path/webhook_sender.sh $webhook_url $webhook_title $author
	count=`cat ${author_file} | wc -l`
	for((i=2;i<=$count;i+=30));  
	do   
		webhook_message=${author_file}_message$i.txt
		j=`expr $i + 30`
		cat ${author_file} | tail -n +$i | head -n 30 >> $webhook_message
		cat $webhook_message
	$tool_path/webhook_sender.sh $webhook_url $webhook_message
	done 
done

cd $tool_path

echo -e "----->> \033[33m停顿3s后自动关闭. \033[0m"
sleep 3s