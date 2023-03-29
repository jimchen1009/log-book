cd proto
path=`pwd`
count=` ls -l | wc -l`
echo "当前执行路径:${path}, 文件数量:${count}"
for file in *
do
	git checkout -- ${file}
done
echo "开始执行修改版本与替换C#包名......"
for file in *
do
	sed -i '1i syntax = "proto2";' ${file}
done
echo "开始执行导出C#代码......"
rm -rf ../out/*
for file in *
do	
	name=$(ls $file | cut -d. -f1)
	#按照方式: npm install -g protogen, 不支持修改包名只能使用sed替换了
	protogen -i:${file} -o:../out/${name}.cs
	sed -i "s/namespace ${name}/namespace PJGClientLib.Protocol/g" ../out/${name}.cs
done
cd ../out
count=` ls -l | wc -l`
echo "结果文件路径:${path}, 文件数量:${count}"
read pasuse