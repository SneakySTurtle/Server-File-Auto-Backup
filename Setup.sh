#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

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
	echo "Please enter the cycle time(/per day):"
	read -p "Cycle Time:" day
	echo "Please enter your FTP Server IP:"
	read -p "IP:" FTPIP
	echo "Please enter your FTP Port:"
	read -p "FTP Port:" FTPPORT
	echo "Please enter your FTP account and password(Separate with spaces eg:user password):"
	read -p "FTP account and password:" USERPASSWD
	echo "Please enter your MySQL user:"
	read -p "MySQL User:" databaseuser
	echo "Please enter you MySQL Pwd:"
	read -p "MySQL Pwd:" databasepass
	echo "Please enter a location you want save in your FTP Server(eg:/share/backup):"
	read -p "Located in:" sdir
	echo "Please enter the location of the Web files you want backup(eg:/user/xxx):"
	read -p "Located in::" dir1
	echo "Please enter the name of Database:"
	read -p "Database Named:" databasename1
	echo "day:"$day >> /backup/config
	echo "FTPIP:"$FTPIP >> /backup/config
	echo "FTPPORT:"$FTPPORT >> /backup/config
	echo "USERPASSWD:"$USERPASSWD >> /backup/config
	echo "databaseuser:"$databaseuser >> /backup/config
	echo "databasepass:"$databasepass >> /backup/config
	echo "sdir:"$sdir >> /backup/config
	echo "dir1:"$dir1 >> /backup/config
	echo "databasename1:"$databasename1 >> /backup/config
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
echo -e "\033[31m +++++Starting backup+++++ \033[0m"

cd /
tar -cvf $dir1"_"$date.tar $dir1 >> /dev/null

echo -e "\033[31m +++++Uploading files+++++ \033[0m"
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
echo -e "\033[31m +++++Done & clean+++++ \033[0m"
rm -rf $dir1"_"$date.tar
}

backup_MySQL(){
echo -e "\033[31m +++++Starting backup+++++ \033[0m"
mysqldump -u$databaseuser -p$databasepass -h127.0.0.1 $databasename1 > /$databasename1"_"$date.dump
echo -e "\033[31m +++++Uploading files+++++ \033[0m"
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
echo -e "\033[31m +++++Done & Clean+++++ \033[0m"
rm -rf $databasename1"_"$date.dump
echo -e "\033[32m +++++log file save in /backup/+++++ \033[0m"
}

if [ -e "/backup/config" ];then
	echo " 
  +----------------Manual------------------------+
 		 0. Update Config
  		 1. Backup Web		
         	 2. Backup MySQL		
         	 3. Backup both at same time	    
  +--------------Automatic-----------------------+	
  		 4. Auto Backup
  +----------------------------------------------+

 " && echo
 stty erase '^H' && read -p " Pls enter a number [0-3]:" num
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
	4)
	chmod -R 755 ./autobackup.sh
 	exec ./autobackup.sh
 	;;
	*)
	echo "ERROR Input [0-4]"
	;;
esac
else
	Build
	echo "Detected it's your  first run, the path is generated, please re-run the script"
fi
