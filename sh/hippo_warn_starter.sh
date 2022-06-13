
echo
echo -e " 				腾讯日志收集导出工具"
echo -e " 	1. 使用chrome浏览器驱动, 需要登录有权限的QQ并且保持在线状态."
echo -e " 	2. 由于驱动预计网页元素不稳定, 需要留意报错以免发生统计遗漏."
echo -e " 	3. 根据提示输入参数即可."
echo -e " 	4. "
echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"


declare -a log_warns
log_warns[0]=log			#所有日志搜索
log_warns[1]=log_day		#每天日志汇总
log_warns[2]=log_hour		#小时日志汇总

#
for (( i = 0 ; i < ${#log_warns[@]}; i++ ))
do
	echo -e "\033[33m$i = [${log_warns[$i]}] \033[0m"
done
echo -e "\033[31m请输入类型的编号. \033[0m"
read index
if [[ "$index" == "" ]] 
then
	log_warn=""
else
	log_warn=${log_warns[${index}]}
fi


# 下面是默认的参数
start_time=`date "+%Y-%m-%d 00:00:00"`
end_time=`date "+%Y-%m-%d %H:%M:%S"`
days=0
hours=0
range_hours=120 #默认拉取5天
range_minutes=0
filter_count=true

if [[ "$log_warn" == "log" ]] 
then
	#默认是周更日志,时间是6点开始
	start_time=`date "+%Y-%m-%d 06:00:00"`
	end_time=`date "+%Y-%m-%d 06:02:00"`
	range_hours=0
	range_minutes=1
	filter_count=true
else
	start_time=""
fi
if [[ "$log_warn" == "log_day" ]] 
then
	echo -e "----->> \033[31m请输入需要日志的时长(天数). \033[0m"
	read input_days
	days=${input_days}
fi
if [[ "$log_warn" == "log_hour" ]] 
then
	echo -e "----->> \033[31m请输入需要日志的时长(小时). \033[0m"
	read input_hours
	hours=${input_hours}
fi


python_path="../python/com/pjg"

echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"
echo -e "\033[33m--------------------------------------------耐心执行完毕---------------------------------------------------------\033[0m\n"

path=`pwd`
# 下载路径, 目前由于浏览器驱动原因用这个分隔符
download_path="C:/Users/chenjingjun/Desktop/hippo_warn"

if [[ "$log_warn" != "" ]] 
then
	cd ${download_path}
	rm -rf *
	cd ${path}
	python ${python_path}/hippo_file_download.py --log_warn ${log_warn} --start_time "${start_time}" --end_time "${end_time}" --days ${days} --hours ${hours} --range_hours ${range_hours} --range_minutes ${range_minutes} --download_path "${download_path}"
	sleep 1s
else
    cd ${download_path}
	echo -e "\033[33m下载路径中的文件:\033[0m"
	for file in ./*
	do
		if test -f ${file}
		then
			echo -e "\033[33m${file}.\033[0m"
		fi
	done
	cd ${path}
fi


decode_path="${download_path}/decode"
rm -rf ${decode_path}
mkdir ${decode_path}
python ${python_path}/hippo_file_decode.py --input_path "${download_path}" --output_path "${decode_path}"


#总计报错
count_path="${download_path}/count"
rm -rf ${count_path}
python ${python_path}/warn_pattern_count.py --input_path "${decode_path}" --output_path "${count_path}" --filter_count=${filter_count}



echo -e "\033[31m输入指令Okay或者回车完成操作.\033[0m"
read action_key
if [[ "$action_key" == "Okay" ]] 
then
	webhook_key="bcd2d17e-878a-4648-8747-f56b7020dc06"
	cd ${count_path}
	tool_path="D:/demo/log-book/sh/git"
	for file in `ls ${count_path}`
	do
		echo ${file} 
		${tool_path}/webhook_upload.sh ${webhook_key} ${file}
	done
	cd ${path}
	webhook_message=webhook_message.txt
	rm -rf ${webhook_message}
	touch ${webhook_message}
	echo "当前报错汇总未执行【帮助执行】,【当周跟版开发】注意更新模板、留意报错.\nhttp://10.17.2.62:8000/version/arrange/#current-arrange" > ${webhook_message}
	${tool_path}/webhook_sender.sh $webhook_key $webhook_message
	rm -rf ${webhook_message}
sleep 3
fi