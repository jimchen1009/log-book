
#国服的工程
local_projects=pjg-server-config,pjg-rpc,pjg-common,pjg-server,pjg-app-server,pjg-battle-server,pjg-http,routerserver,pjg-idip,pjg-picture
#海外的工程
bt_allprojects=pjg-server-config,pjg-rpc,pjg-common,pjg-server,pjg-app-server,pjg-battle-server,pjg-http,routerserver,pjg-pay,pjg-bgm,pjg-db-job

from_branch=$1
to_branch=$2

allprojects=$local_projects
if [[ "$3" == bt ]] 
then
	allprojects=$bt_allprojects
fi
echo $allprojects

webhook_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=693axxx6-7aoc-4bc4-97a0-0ec2sifa5aaa"
start_message="【服务端】开始合并【${from_branch}】到【${to_branch}】,【暂停提交】."

./webhook_sender.sh $webhook_url $start_message
./merge_branch_all.sh $allprojects $from_branch $to_branch

echo -e "----->> \033[31m完成合并请输入: Okay \033[0m"
read finishCode

if [[ "$finishCode" == Okay ]] 
then
	finish_message="【服务端】完成合并【${from_branch}】到【${to_branch}】,【恢复提交】."
	./webhook_sender.sh $webhook_url $finish_message
fi
