
# 机器人通知KEY
#webhook_key="3b26de32-5b08-496e-9d6c-9e9214065f77" 
webhook_key="bcd2d17e-878a-4648-8747-f56b7020dc06"
# 下载路径, 目前由于浏览器驱动原因用这个分隔符
download_path="C:/Users/chenjingjun/Desktop/hippo_warn"
# 报错模板的位置, 需要w2获取最新
pattern_path="C:/ProjectG/pjg-server/src/test/resources/tencent"
# 
python_path="../../python/com/pjg"

nodtepad_path="E:/software/Notepad++/notepad++.exe"

#总计报错
count_path="${download_path}/count"
input_path="${download_path}/download"
rm -rf ${count_path}
python ${python_path}/warn_pattern_count.py --input_path "${input_path}/" --output_path "${count_path}" --pattern_path=${pattern_path} --filter_count=false

#打开文件
${nodtepad_path} ${count_path}/warn.log &
${nodtepad_path} ${count_path}/other.log &

echo -e "\033[31m输入海外名称或者回车完成操作.\033[0m"

read action_key
if [[ "$action_key" != "" ]] 
then
	cd ${count_path}
	for file in `ls ${count_path}`
	do
		echo ${file} 
		${tool_path}/webhook_upload.sh ${webhook_key} ${file}
	done
	cd ${path}
	webhook_message=webhook_message.txt
	rm -rf ${webhook_message}
	touch ${webhook_message}
	usernanme=`git config user.name`
	echo "操作者:【${usernanme}】,【海外${action_key}】留意留意报错汇总(5分钟内能查阅完毕)" > ${webhook_message}
	${tool_path}/webhook_sender.sh $webhook_key $webhook_message
	rm -rf ${webhook_message}
sleep 3
fi