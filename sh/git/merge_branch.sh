project=$1
from_branch=$2
to_branch=$3
log_file=$4

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
echo -e "\033[31m----->> projecth = $project\033[0m"
echo -e "\033[31m----->> from_branch = $from_branch\033[0m"
echo -e "\033[31m----->> to_branch = $to_branch\033[0m"

git reset --hard
git checkout .

echo -e "\033[33m-------->> 开始切换到$from_branch分支, 并且拉取最新代码.\033[0m"
git checkout $from_branch
git reset --hard origin/$from_branch
git checkout .
git pull --rebase
git rebase origin/$from_branch

echo -e "\033[33m-------->> 开始切换到$to_branch, 并且拉取最新代码.\033[0m"
git checkout $to_branch
git reset --hard origin/$to_branch
git checkout .
git pull --rebase
git rebase origin/$to_branch

echo -e "\033[33m-------->> 开始合并$from_branch分支内容到$to_branch分支.\033[0m"
git merge --no-ff --no-commit $from_branch

if [ -f "gradle.properties" ]
then
	echo -e "-------->> \033[33m撤销gradle.properties的修改.\033[0m"
	git reset HEAD gradle.properties
	git checkout -- gradle.properties
fi

check_change=`git status -s` 

echo "工程名: 【${project}】 来源: ${from_branch} 目标: ${to_branch} 变更结果如下: " >> ${filename}
echo "${check_change}" >> ${filename}
echo "" >> ${filename}
echo "" >> ${filename}

cd $path