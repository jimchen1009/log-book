
declare -a webhooknames
declare -a webhook_wx_keys
declare -a webhook_fs_keys
declare -A fs_user_ids

#测试使用
webhook_wx_keys[0]="3b26de32-5b08-496e-9d6c-9e9214065f77"
webhook_fs_keys[0]="ab105da7-2cd3-444c-94ec-f6b8ecf55139"
#总群
#webhook_wx_keys[1]="08ed176a-5c5d-4745-82a5-dd27c514e987"
webhook_fs_keys[1]="49980b24-641d-427f-bbf5-3f43bbcefdca"
#后端群
#webhook_wx_keys[2]="bcd2d17e-878a-4648-8747-f56b7020dc06"
webhook_fs_keys[2]="53be5094-1c07-4e17-a8f0-22f6411f3055"

webhook_wx_key=${webhook_wx_keys[$1]}
webhook_fs_key=${webhook_fs_keys[$1]}

#飞书UserId列表
fs_user_ids["chenjingjun"]=""

title=""
content=""
while read -r line
do 
	if [[ -n "$title" ]]
	then
		if [[ -n "$content" ]]
		then
			content="${content}\n"
		fi
		content="${content}${line}"
	else
		title="${line}"
	fi
done < $2

wx_user_list=`echo $3 | sed -e 's/,/","/g'`	
generate_wx_data()
{
  cat <<EOF
{
	"msgtype": "text",
	"text": {
		"content": "${title}\n${content}",
		"mentioned_list":["$wx_user_list"]
	}
}
EOF
}

at_list=""
fs_user_list=(`echo $3 | sed -e 's/,/ /g'`)
for fs_user in ${fs_user_list[@]}
do
	fs_user_id=${fs_user_ids[$fs_user]}
    echo "${fs_user}: ${fs_user_id}"
	if [ -n "${fs_user_id}" ]
	then
		at_list="${at_list}<at id=${fs_user_id}></at>"
	fi
done
echo "${at_list}"


generate_fs_data()
{
  cat <<EOF
{
	"msg_type": "interactive",
	"card": {
		"config": {
			"wide_screen_mode": true
		},
		"header": {
			"template": "green",
			"title": {
				"content": "$title",
				"tag": "plain_text"
			}
		},
		"elements": [
			{
				"tag": "markdown",
				"content": "${content}${at_list}"
			}
		]
	}
}
EOF
}

if [[ -n "$webhook_wx_key" ]]
then
	webhook_wx_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=${webhook_wx_key}"
	echo $(generate_wx_data) > webhook_data_wx.txt
	curl "$webhook_wx_url" \
		-H "Content-Type: application/json; charset=UTF-8" \
		-d "@webhook_data_wx.txt"
fi

if [[ -n "$webhook_fs_key" ]]
then
	webhook_fs_url="https://open.feishu.cn/open-apis/bot/v2/hook/${webhook_fs_key}"
	echo $(generate_fs_data) > webhook_data_fs.txt
	curl "$webhook_fs_url" \
		-H "Content-Type: application/json; charset=UTF-8" \
		-d "@webhook_data_fs.txt"
fi





   

