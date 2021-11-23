
tool_path=`pwd`
cd ../..
path=`pwd`

author_commit=$path/author_commit
rm -rf $author_commit
mkdir $author_commit

#测试使用
webhook_url=""


declare -a projectnames
projectnames[0]=server-config
projectnames[1]=common
projectnames[2]=server

#开发通知列表
webhook_author_list=(chenjingjun)

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
		echo -e "\033[31m工程[${project}]变更结果如下:\033[0m"
		for file in `git diff --name-only $version`
		do
			for author in `git log ${version}..HEAD -- ${file} | grep "Author:" | sort | uniq | awk -F ' ' '{print $2}'`
			do
				author_file=${author_commit}/${author}.txt
				if [ ! -f "$author_file" ]
				then
					echo "${author}" >> ${author_file}
				fi
				echo "${project}  ${file}" >> ${author_file}
			done
			echo ${file}
		done
		message=`git reset $version` #没有显示增加的文件
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
for file in `ls -1 .`
do
	author_file=$author_commit/$file
	author_name=`cat ${author_file} | head -n 1`
	if [[ "${webhook_author_list[@]}" =~ "$author_name" ]] 
	then
		echo "$author_name"
		webhook_title=${author_file}_title.txt
		echo "开发(${author_name})当前版本改动的文件:" > $webhook_title
		$tool_path/webhook_sender.sh $webhook_url $webhook_title $author_name
		count=`cat ${author_file} | wc -l`
		for((i=2;i<=$count;i+=30));  
		do   
			webhook_message=${author_file}_message$i.txt
			j=`expr $i + 30`
			cat ${author_file} | tail -n +$i | head -n 30 >> $webhook_message
		$tool_path/webhook_sender.sh $webhook_url $webhook_message
		done 
	fi
done
	
cd $tool_path

echo ""
echo -e "----->> \033[33m停顿5s后自动关闭. \033[0m"
sleep 5s