project=$1
from_branch=$2
to_branch=$3
conflict_branch=$4
commit_none=$5
log_file=$6

echo -e "\033[31m工程:${project}\033[0m"
echo -e "\033[33m参数:\nfrom_branch: ${from_branch}\nto_branch: ${to_branch}\nconflict_branch: ${conflict_branch}\ncommit_none: ${commit_none}\033[0m"

path=`pwd`
filename=$path/$log_file
if [ ! -f "$filename" ]
then
	echo -e "\033[31m----->> 日志文件[$log_file]不存在.\033[0m"
	exit 0
fi

dic_path=$path/$project
if [ ! -d "$dic_path" ]; 
then
	echo -e "\033[31m----->> 工程目录[$project]不存在.\033[0m"
	exit 0
fi

if [ ["$from_branch" == ""] ] 
then
	echo -e "\033[31m----->> 没有输入分支from_branch名称.\033[0m"
	exit 0
fi

if [ ["$to_branch" == ""] ] 
then
	echo -e "\033[31m----->> 没有输入分支to_branch名称.\033[0m"
	exit 0
fi

if [[ "$from_branch" == "$to_branch" ]] 
then
	echo -e "\033[31m----->> 两个分支名称相同.\033[0m"
	exit 0
fi

cd $dic_path

rm -fr ".git/rebase-merge"
git reset --hard
git checkout .

echo -e "\033[33m-------->> 开始切换到[$from_branch]分支, 并且拉取最新代码.\033[0m"
git checkout $from_branch
git reset --hard origin/$from_branch
git checkout .
git pull --rebase
git rebase origin/$from_branch

echo -e "\033[33m-------->> 开始切换到[$to_branch], 并且拉取最新代码.\033[0m"
git checkout $to_branch
git reset --hard origin/$to_branch
git checkout .
git pull --rebase
git rebase origin/$to_branch

if [ ${to_branch} = ${conflict_branch} ] 
then
	echo -e "\033[33m-------->> 开始合并[$from_branch]分支内容到[$to_branch]分支,使用ours策略参数.\033[0m"
	git merge --no-ff --no-commit --strategy-option ours $from_branch 
else
	if [ ${from_branch} = ${conflict_branch} ] 
	then
		echo -e "\033[33m-------->> 开始合并[$from_branch]分支内容到[$to_branch]分支,使用theirs策略参数.\033[0m"
		git merge --no-ff --no-commit --strategy-option theirs $from_branch 
	else
		echo -e "\033[33m-------->> 开始合并[$from_branch]分支内容到[$to_branch]分支.\033[0m"
		git merge --no-ff --no-commit $from_branch 
	fi
fi

if [ -f "gradle.properties" ]
then
	git reset --quiet HEAD gradle.properties
	git checkout -- gradle.properties
fi

check_change=`git status -s` 
if [[ -z $check_change ]]
then
	echo "工程名:[${project}] -- 来源:[${from_branch}], 目标:[${to_branch}], 冲突为准:[${conflict_branch}], 无变更内容. " >> ${filename}
	echo "工程名:[${project}] -- [无需]提交" >> ${filename}
else	
	# 使用原来的分支代码, 忽略掉所有的修改
	if [ ${commit_none} = yes ] 
	then
		echo "工程名:[${project}] -- 来源:[${from_branch}], 目标:[${to_branch}], 冲突为准:[${conflict_branch}], 撤销变更如下. " >> ${filename}
		echo "${check_change}" >> ${filename}
		echo -e "-------->> \033[33m撤销本地所有的变更,请耐心等待,执行中.......\033[0m"
		IFS_old=$IFS      		# 记录老的分隔符
		IFS=$'\n'              	# 以换行符作为分隔符
		for fileline in `git status -s`
		do
			IFS=","
			array=(`echo ${fileline} | awk '{printf("%s,%s",$1,$2)}'`) 
			A=${array[0]}
			name=${array[1]}
			git reset --quiet HEAD ${name}
			if [[ "$A" == "A" ]]
			then
				rm -rf ${name}
			fi
		done
		git checkout -- .
		IFS=$IFS_old     # 分隔符改回去 不影响下次使用
		check_changeV2=`git status -s` 
		if [[ -z $check_changeV2 ]]
		then
			#git commit -m "Merge branch '${from_branch}' into ${to_branch}"
			#git push
			echo "工程名:[${project}] -- [自动]提交,撤销所有变更" >> ${filename}
		else
			echo "工程名:[${project}] -- [手动]提交,撤销变更错误" >> ${filename}
		fi
	else
		echo "工程名:[${project}] -- 来源:[${from_branch}], 目标:[${to_branch}], 冲突为准:[${conflict_branch}], 变更结果如下: " >> ${filename}
		echo "${check_change}" >> ${filename}
		#check_conflict=`git diff --check`
		check_conflict=`git diff --name-only --diff-filter=U`
		if [[ -z $check_conflict ]]
		then
			#git commit -m "Merge branch '${from_branch}' into ${to_branch}"
			#git push
			echo "工程名:[${project}] -- [自动]提交" >> ${filename}
		else	
			echo "工程名:[${project}] -- [手动]提交,冲突待解决" >> ${filename}
		fi
	fi
fi

echo "" >> ${filename}
echo "" >> ${filename}

cd $path