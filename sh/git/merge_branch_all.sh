
allprojects=$1
from_branch=$2
to_branch=$3
conflict_branch=$4
to_branch_suffix=$5
log_file=$6

current1=`date "+%Y-%m-%d %H:%M:%S"`
echo "" >> ${log_file}
echo "================================ 合并[${from_branch}]到[${to_branch}],冲突为准[${conflict_branch}],分支开始操作标记位置 [${current1}] ================================" >> ${log_file}
echo "" >> ${log_file}

projects=(`echo $allprojects | tr ',' ' '`)
for (( i = 0 ; i < ${#projects[@]}; i++ ))
do
	project=${projects[$i]}
	./merge_branch.sh $project $from_branch $to_branch $conflict_branch $to_branch_suffix $log_file
	echo -e "\033[33m-------------------------------------------------------------------------------------------------------------------------\033[0m\n"
done
exit 0

