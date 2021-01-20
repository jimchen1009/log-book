path=$1
project=$2
checkout_branch=$3

cd $path/$project
current_branch=`git branch | grep "*"`
current_branch=${current_branch:2}

echo -e "----->> \033[31mprojecth = $project\033[0m"
echo -e "----->> \033[31mcurrent branch = $current_branch\033[0m"
echo -e "----->> \033[31mcheckout branch = $checkout_branch\033[0m"


no_change=`git stash save Jim $(date +%Y%m%d) | grep -E "No|没有"` #暂时使用这两个关键字

if [[ "$current_branch" != "$checkout_branch" ]] 
then
	check_branch=`git branch | grep "$checkout_branch"`
	check_branch=`echo $check_branch`
	if [[ "$check_branch" != "$checkout_branch" ]] 
	then
		echo -e "----->> \033[31mcheck branch is $check_branch,no local branch [$checkout_branch], checkout is running......\033[0m"
		git checkout -b $checkout_branch --track origin/$checkout_branch	
	fi
fi

echo -e "----->> \033[31m$project checkout is running, the branch is [${checkout_branch}].\033[0m"
git reset --hard
git checkout $checkout_branch
git pull --rebase
if [[ "$no_change" == "" ]] 
then
	echo -e "----->> \033[31mstash pop changes in branch [$current_branch] \033[0m"
	git stash pop
fi
