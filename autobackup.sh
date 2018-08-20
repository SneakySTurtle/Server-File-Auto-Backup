#!/bin/bash

echo "+------------------------------------------------------------------------+"
echo "|                     System Support:CentOS                              |"
echo "|                     Database Support:MySQL                             |"
echo "+------------------------------------------------------------------------+"
echo "|       A tool to auto-compress & auto-upload data to FTP server         |"
echo "+------------------------------------------------------------------------+"
echo "|                     Author: SneakyTurtle Jindom                        |"
echo "|                     Version: 1.0.0                                     |"
echo "+------------------------------------------------------------------------+"

Build(){
mkdir /backup
touch /backup/config
}


Set_Info(){
	echo "请输入自动备份任务的执行周期(以天为单位):"
	read -p "自动备份周期天数:" day
	echo "请输入你的FTP服务器IP地址(例如182.148.157.246):"
	read -p "FTP服务器IP:" FTPIP
	echo "请输入你的FTP服务器端口(例如21):"
	read -p "FTP服务器端口:" FTPPORT
	echo "请输入你的FTP服务器的用户名和密码(例如admin password):"
	read -p "FTP用户名密码:" USERPASSWD
	echo "请输入你的数据库用户名(例如root):"
	read -p "数据库用户名:" databaseuser
	echo "请输入你的数据库密码(例如password):"
	read -p "数据库密码:" databasepass
	echo "请输入你想要保存文档到FTP服务器的何位置(例如/share/backup):"
	read -p "FTP服务器路径:" sdir
	echo "请输入你需要备份的目录(例如/root/data):"
	read -p "备份目录路径:" dir1
	echo "请输入你需要备份的数据库名(例如wordpress):"
	read -p "数据库名称:" databasename1
	echo "day:"$day >> /backup/config
	echo "FTPIP:"$FTPIP >> /backup/config
	echo "FTPPORT:"$FTPPORT >> /backup/config
	echo "USERPASSWD:"$USERPASSWD >> /backup/config
	echo "databaseuser:"$databaseuser >> /backup/config
	echo "databasepass:"$databasepass >> /backup/config
	echo "sdir:"$sdir >> /backup/config
	echo "dir1:"$dir1 >> /backup/config
	echo "databasename1:"$databasename1 >> /backup/config
	echo -e "\033[32m +++++初始化信息已保存到/backup/config+++++ \033[0m"
}

Load_InFo(){
	day=$(cat /backup/config | grep "day" | cut -d ":" -f 2)
	FTPIP=$(cat /backup/config | grep "FTPIP" | cut -d ":" -f 2)
	FTPPORT=$(cat /backup/config | grep "FTPPORT" | cut -d ":" -f 2)
	USERPASSWD=$(cat /backup/config | grep "USERPASSWD" | cut -d ":" -f 2)
	databaseuser=$(cat /backup/config | grep "databaseuser" | cut -d ":" -f 2)
	databasepass=$(cat /backup/config | grep "databasepass" | cut -d ":" -f 2)
	sdir=$(cat /backup/config | grep "sdir" | cut -d ":" -f 2)
	dir1=$(cat /backup/config | grep "dir1" | cut -d ":" -f 2)
	databasename1=$(cat /backup/config | grep "databasename1" | cut -d ":" -f 2)
	date=`date +%Y%m%d`
}

backup_web(){
echo -e "\033[31m +++++开始备份网页文件数据+++++ \033[0m"

cd /
tar -cvf $dir1"_"$date.tar $dir1 >> /dev/null

echo -e "\033[31m +++++开始上传网页文件数据+++++ \033[0m"
ftp -A -n<<EOF
open $FTPIP $FTPPORT
user $USERPASSWD
cd $sdir
lcd /
prompt
mput $dir1"_"$date.tar
close
bye
EOF
echo -e "\033[31m +++++上传完成，清理环境+++++ \033[0m"
rm -rf $dir1"_"$date.tar
}

backup_MySQL(){
echo -e "\033[31m +++++开始备份数据库数据+++++ \033[0m"
mysqldump -u$databaseuser -p$databasepass -h127.0.0.1 $databasename1 > /$databasename1"_"$date.dump
echo -e "\033[31m +++++开始上传数据库数据+++++ \033[0m"
ftp -A -n<<EOF
open $FTPIP $FTPPORT
user $USERPASSWD
cd $sdir
lcd /
prompt
mput $databasename1"_"$date.dump
close
bye
EOF
echo -e "\033[31m +++++数据上传完成，清理数据+++++ \033[0m"
rm -rf $databasename1"_"$date.dump
echo -e "\033[32m +++++日志已保存到/backup/+++++ \033[0m"
}

if [ -e "/backup/config" ];then
	echo " 
  0. 更新配置
  1. 备份网页
  2. 备份数据库
  3. 同时备份
 " && echo
 stty erase '^H' && read -p " 请输入数字 [0-3]:" num
case "$num" in
	0)
	Set_Info
	;;
	1)
	Load_InFo
	backup_web
	;;
	2)
	Load_InFo
	backup_MySQL
	;;
	3)
	Load_InFo
	backup_web
	backup_MySQL
	;;
	*)
	echo "请输入正确数字 [0-10]"
	;;
esac
else
	Build
	echo "检测为初次运行，路径生成完毕，请重新运行脚本"
fi
