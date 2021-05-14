webhook_url=$1
webhook_message=$2
mentioned_list=$3

content=""
while read -r line
do 
	if [ -n "$content" ]; then
		content="${content}\n"
	fi
	echo $line
	content="${content}${line}"
done < ${webhook_message}

char_count=${#content}
if [ $char_count -gt 2048 ]
then
	content=${content: 0: 2048}
	content="${content} ......"
fi
	
generate_data()
{
  cat <<EOF
{
	"msgtype": "text",
	"text": {
		"content": "$content",
		"mentioned_list":["$mentioned_list"]
	}
}
EOF
}

echo $(generate_data) > webhook_data.txt

curl "$webhook_url" \
   -H "Content-Type: application/json; charset=UTF-8" \
   -d "@webhook_data.txt"
