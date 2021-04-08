
allprojects=$1
from_branch=$2
to_branch=$3

current0=`date "+%Y-%m-%d_%H%M%S"`
log_file=merge_branch_log${current0}.txt
touch $log_file

current1=`date "+%Y-%m-%d %H:%M:%S"`
echo "" >> ${log_file}
echo "		------<<开始操作标记位置 [${current1}]>>------		" >> ${log_file}

projects=(`echo $allprojects | tr ',' ' '`)
for (( i = 0 ; i < ${#projects[@]}; i++ ))
do
	project=${projects[$i]}
	./merge_branch.sh $project $from_branch $to_branch $log_file
	echo -e "\033[33m------------------------------------------------------------------------------------------------------------------------------------\033[0m\n"
done

debug_file=merge_branch_log.txt
touch $debug_file
cat $log_file >> $debug_file
cat $log_file
rm -rf $log_file
exit 0

