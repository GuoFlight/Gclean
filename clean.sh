#!/bin/bash

############################
# 作用：清理过期文件
# author：京城郭少
# 配合crontab一起使用更佳
###########################

cleanTime=15		#将N天以前的文件移动到废纸篓中
rmTime=30		#将废纸篓中30天以前的文件删除
dirClean="/home/test"	#需要删除文件的目录路径
dirGarbage="/home/garbage"		#废纸篓
rmTag="test"		#删除tag，文件的路径要带有此tag才会被清理(防止误删)

#变量初始化
dirGarbage=`dirname $dirGarbage/test`
dirClean=`dirname $dirClean/test`

#函数作用:得到新文件名
#输入:旧文件名
#输出:新文件名
get_new_filename(){
    #分隔符
    sep_char="_"

    #分离出文件名
    old_filename=`basename "$1"`
    old_path=`readlink -f "$1"`
    old_dirname=`dirname "$old_path"`


    #得到新文件名
    new_dirname=`echo ${old_dirname//\//$sep_char}`
    cur_time=`date "+%Y%m%d%H%M%S"`
    new_filename="$new_dirname$sep_char$old_filename$sep_char$cur_time$sep_char$RANDOM"

    echo $new_filename
    return 0
}

#函数作用:将文件移动到gargabe目录中
#输入:文件名
mv_to_garbage(){
	#若文件不存在
	if [ ! -e "$1" ]; then
    		echo "删除失败 $1: No such file or directory"
    	exit 1
	fi

	new_filename=`get_new_filename "$1"`

	mv "$1" "$dirGarbage/$new_filename"
}

#将指定目录中的文件移动到废纸篓中
#参数1：需要清理文件的目录路径
function clean(){
	if [ -z "$1" ]; then
		return
	fi

	dir=`readlink -f "$1"`
	files=`find $dir -type f -mtime +$cleanTime`
	OLDIFS=$IFS         #备份原for循环的分隔符
	IFS=$'\n'           #将for循环的隔符替换为换行
	for i in "$files"; do
		[[ "$i" =~ "$rmTag" ]] && mv_to_garbage "$i"	#将此文件移动到废纸篓中
	done

	#删除空目录
	emptyDirs=`find "$dir" -empty -type d -mtime +$cleanTime`
	for i in "$emptyDirs"; do
                [[ "$i" =~ "$rmTag" ]] && rmdir "$i"
        done
	IFS="$OLDIFS"       #恢复for循环原来的分隔符
}

#清理废纸篓中的文件
function cleanGarbage(){
        files=`find $dirGarbage -type f -mtime +$rmTime`
	OLDIFS=$IFS         #备份原for循环的分隔符
        IFS=$'\n'            #将for循环的隔符替换为换行
        for i in "$files"; do
               [[ "$i" =~ "$dirGarbage" ]] && rm -f "$i"         #删除此目录(谨慎操作!!!)
        done
	IFS="$OLDIFS"       #恢复for循环原来的分隔符
}

function main(){
	mkdir -p "$dirGarbage"	#创建废纸篓
	cleanGarbage		#清理废纸篓
	clean "$dirClean"	#将目录中符合条件的文件移动到废纸篓中
}
main
