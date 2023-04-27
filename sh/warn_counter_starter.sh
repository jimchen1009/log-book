
# 下载路径, 目前由于浏览器驱动原因用这个分隔符
download_path="C:/Users/chenjingjun/Desktop/hippo_warn"
# 报错模板的位置, 需要w2获取最新
pattern_path="C:/ProjectG/pjg-server/src/test/resources/tencent"
# 
python_path="../../python/com/pjg"

nodtepad_path="E:/software/Notepad++/notepad++.exe"

#总计报错
count_path="${download_path}/count"
input_path="${download_path}/decode"
rm -rf ${count_path}
python ${python_path}/warn_pattern_count.py --input_path "${input_path}/" --output_path "${count_path}" --pattern_path=${pattern_path} --filter_count=false

#打开文件
${nodtepad_path} ${count_path}/warn.log &
${nodtepad_path} ${count_path}/other.log &