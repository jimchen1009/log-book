
webhook_file=$2
webhook_message=$3

declare -a webhook_wx_keys
declare -a webhook_fs_keys

tool_path="E:/demo/log-book/sh/git"

#测试使用
#webhook_wx_keys[0]="3b26de32-5b08-496e-9d6c-9e9214065f77"
webhook_fs_keys[0]="ab105da7-2cd3-444c-94ec-f6b8ecf55139"
#总群
#webhook_wx_keys[1]="08ed176a-5c5d-4745-82a5-dd27c514e987"
webhook_fs_keys[1]="49980b24-641d-427f-bbf5-3f43bbcefdca"
#后端群
#webhook_wx_keys[2]="bcd2d17e-878a-4648-8747-f56b7020dc06"
webhook_fs_keys[2]="53be5094-1c07-4e17-a8f0-22f6411f3055"

webhook_wx_key=${webhook_wx_keys[$1]}
webhook_fs_key=${webhook_fs_keys[$1]}


media_id=""
generate_wx_data()
{
  cat <<EOF
{
	"msgtype": "file",
	"file": {
		"media_id": "$media_id"
	}
}
EOF
}


if [[ -n "$webhook_wx_key" ]]
then
	webhook_wx_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=${webhook_wx_key}"
	webhook_wx_upload_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/upload_media?key=${webhook_wx_key}&type=file"
	media_id=`curl -F "filename=@${webhook_file}" "${webhook_wx_upload_url}" | grep media_id | awk -F '"' '{print($14)}'`

	echo $(generate_wx_data) > webhook_data_wx.txt
	curl "$webhook_wx_url" \
		-H "Content-Type: application/json; charset=UTF-8" \
		-d "@webhook_data_wx.txt"
fi

if [[ -n "$webhook_fs_key" ]]
then
	directory=`date "+%Y%m%d%H%M"`
	rm -rf ${directory}
	mkdir ${directory}
	if [ -f $webhook_file ]
	then
		cp  ${webhook_file} ${directory}
	else
		for file in ${webhook_file}/*
		do
			cp ${file} ${directory}
		done
	fi
	echo "站点地址: 10.17.2.62" >> ${webhook_message}
	echo "文件路径: /home/pjg/webhook/static/upload" >> ${webhook_message}
	for file in ${directory}/*
	do
		filename=$(basename "$file")
		echo ${filename}
		echo "[${filename}](http://10.17.2.62:8000/static/upload/${file})" >> ${webhook_message}
	done
	tar -czf ${directory}/upload.tar.gz ${directory}
	scp ${directory}/upload.tar.gz root@10.17.2.62:/home/pjg/webhook/static/upload
	ssh root@10.17.2.62 "cd /home/pjg/webhook/static/upload; tar -zxf upload.tar.gz"
	rm -rf ${directory}
	${tool_path}/webhooks_sender.sh $1 ${webhook_message}
fi


