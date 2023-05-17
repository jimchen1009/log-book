
declare -a webhooknames
declare -a webhook_wx_keys
declare -a webhook_fs_keys

#测试使用
#webhook_wx_keys[0]="3b26de32-5b08-496e-9d6c-9e9214065f77"
webhook_fs_keys[0]="ab105da7-2cd3-444c-94ec-f6b8ecf55139"
#总群
#webhook_wx_keys[1]=""
webhook_fs_keys[1]=""
#后端群
#webhook_wx_keys[2]=""
webhook_fs_keys[2]=""

webhook_wx_key=${webhook_wx_keys[$1]}
webhook_fs_key=${webhook_fs_keys[$1]}


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

mentioned_list=`echo $3 | sed -e 's/,/","/g'`	
generate_wx_data()
{
  cat <<EOF
{
	"msgtype": "text",
	"text": {
		"content": "${title}\n${content}",
		"mentioned_list":["$mentioned_list"]
	}
}
EOF
}

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
				"content": "$content"
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





   

