
echo
echo -e " 				腾讯日志收集导出工具"
echo -e " 	1. 使用chrome浏览器驱动, 需要登录有权限的QQ并且保持在线状态."
echo -e " 	2. 由于驱动预计网页元素不稳定, 需要留意报错以免发生统计遗漏."
echo -e " 	3. 根据提示输入参数即可."
echo -e " 	4. "
echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"

# 机器人通知KEY
#webhook_key="3b26de32-5b08-496e-9d6c-9e9214065f77" 
webhook_key="bcd2d17e-878a-4648-8747-f56b7020dc06"
# 需要保持登录的QQ账号
qq="771129369"
# 下载路径, 目前由于浏览器驱动原因用这个分隔符
download_path="C:/Users/chenjingjun/Desktop/hippo_warn/download"
# 解析的结果
warn_path="C:/Users/chenjingjun/Desktop/hippo_warn"
# 报错模板的位置, 需要w2获取最新
pattern_path="C:/ProjectG/pjg-server/src/test/resources/tencent"
# 工具目录
tool_path="E:/demo/log-book/sh/git"
# 
python_path="../../python/com/pjg"
#
nodtepad_path="E:/software/Notepad++/notepad++.exe"


declare -a log_warns
log_warns[0]=log			#所有日志搜索
log_warns[1]=log_day		#每天日志汇总
log_warns[2]=log_hour		#小时日志汇总

#
for (( i = 0 ; i < ${#log_warns[@]}; i++ ))
do
	echo -e "\033[33m$i = [${log_warns[$i]}] \033[0m"
done
echo -e "\033[31m请输入类型的编号: \033[0m"
read index
if [[ "$index" == "" ]] 
then
	log_warn=""
else
	log_warn=${log_warns[${index}]}
fi


declare -a begin_times
begin_times[0]=`date "+%Y-%m-%d"`
begin_times[1]=`date -d "1 days ago" "+%Y-%m-%d"`
begin_times[2]=`date -d "2 days ago" "+%Y-%m-%d"`
begin_times[3]=`date -d "3 days ago" "+%Y-%m-%d"`
begin_times[4]=`date -d "4 days ago" "+%Y-%m-%d"`
begin_times[5]=`date -d "5 days ago" "+%Y-%m-%d"`
begin_times[6]=`date -d "6 days ago" "+%Y-%m-%d"`
begin_times[7]=`date -d "7 days ago" "+%Y-%m-%d"`


# 下面是默认的参数
start_time=${begin_times[0]}
end_time=`date "+%Y-%m-%d %H:%M:%S"`
days=0
hours=0
range_hours=0 
range_minutes=0
range_seconds=0
filter_count=false

if [[ "$log_warn" == "log" ]] 
then
	range_minutes=10
	range_seconds=0
else
	filter_count=true
	range_hours=120
fi

if [[ "$log_warn" != "" ]] 
then
	echo ""
	echo -e "\033[31m开始时间编号列表: \033[0m"
	for (( i = 0 ; i < ${#begin_times[@]}; i++ ))
	do
		time=${begin_times[$i]}
		week=`date -d "${time}" +%A`
		echo -e "\033[33m$i = [${time}, ${week}] \033[0m"
	done
	echo -e "\033[31m请输入日期编号与小时, 使用空格隔开, 例子: \033[0m"
	echo -e "\033[33m0 6 (编号0的日期, 时间06:00:00) \033[0m"
	echo -e "\033[33m2 9:10:00 (编号2的日期, 时间09:10:00) \033[0m"
	read parameters
	array=($parameters)
	date_index=${array[0]}
	date_hour=${array[1]}
	if [ -n "$(echo $date_index| sed -n "/^[0-9]\+$/p")" ]
	then
		start_time=${begin_times[$date_index]}
	fi
	if [ -n "$(echo $date_hour| sed -n "/^[0-9]\+$/p")" ]
	then
		start_time="${start_time} ${date_hour}:00:00"
	else
		start_time="${start_time} ${date_hour}"
	fi
	echo "下载日志的开始时间:${start_time}"
else
	echo "不执行日志下载, 使用目录日志文件"
fi


#if [[ "$log_warn" == "log_day" ]] 
#then
#	echo -e "----->> \033[31m请输入需要日志的时长(天数). \033[0m"
#	read input_days
#	days=${input_days}
#fi
#if [[ "$log_warn" == "log_hour" ]] 
#then
#	echo -e "----->> \033[31m请输入需要日志的时长(小时). \033[0m"
#	read input_hours
#	hours=${input_hours}
#fi


echo -e "\033[33m-----------------------------------------------------------------------------------------------------------------\033[0m\n"
echo -e "\033[33m--------------------------------------------耐心执行完毕---------------------------------------------------------\033[0m\n"

path=`pwd`

if [[ "$log_warn" != "" ]] 
then
	cd ${download_path}
	rm -rf *
	cd ${path}
	python ${python_path}/hippo_file_download.py --qq ${qq} --log_warn ${log_warn} --start_time "${start_time}" --end_time "${end_time}" --days ${days} --hours ${hours} \
	--range_hours ${range_hours} --range_minutes ${range_minutes} --range_seconds ${range_seconds} --download_path "${download_path}"
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


decode_path="${warn_path}/decode"
rm -rf ${decode_path}
mkdir ${decode_path}
python ${python_path}/hippo_file_decode.py --input_path "${download_path}" --output_path "${decode_path}"


#总计报错
count_path="${warn_path}/count"
rm -rf ${count_path}
python ${python_path}/warn_pattern_count.py --input_path "${decode_path}" --output_path "${count_path}" --pattern_path=${pattern_path} --filter_count=${filter_count}


echo -e "\033[31m输入指令Okay或者回车完成操作.\033[0m"

# 打开文件
${nodtepad_path} ${count_path}/warn.log &
${nodtepad_path} ${count_path}/other.log &


read action_key
if [[ "$action_key" == "Okay" ]] 
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
	echo "操作者:【${usernanme}】,【当周跟版开发】留意留意报错汇总(5分钟内能查阅完毕).\nhttp://10.17.2.62:5173/" > ${webhook_message}
	${tool_path}/webhook_sender.sh $webhook_key $webhook_message
	rm -rf ${webhook_message}
sleep 3
fi