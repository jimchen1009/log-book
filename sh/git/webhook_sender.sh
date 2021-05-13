webhook_url=$1
content=$2

generate_data()
{
  cat <<EOF
{
	"msgtype": "text",
	"text": {
		"content": "$content",
		"mentioned_list":["@all"]
	}
}
EOF
}

echo $(generate_data) > webhook_data.txt

curl -v "$webhook_url" \
   -H "Content-Type: application/json; charset=UTF-8" \
   -d "@webhook_data.txt"
