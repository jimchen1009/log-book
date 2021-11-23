webhook_key=$1
webhook_file=$2

webhook_message_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=${webhook_key}"
webhook_upload_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/upload_media?key=${webhook_key}&type=file"

media_id=`curl -F "filename=@${webhook_file}" "${webhook_upload_url}" | grep media_id | awk -F '"' '{print($14)}'`

echo ${media_id}

generate_data()
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

echo $(generate_data) > webhook_data.txt

curl "$webhook_message_url" \
   -H "Content-Type: application/json; charset=UTF-8" \
   -d "@webhook_data.txt"
