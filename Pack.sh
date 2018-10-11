#!/bin/bash
date=`date +%F`
echo "Please enter the dir of your website (/home/wwwroot/xxx.xxx.com):"
read -p"WebSite Path Is:" Web_Dir
echo "Please enter a Name of the files after pached:"
read -p"Packed File Name Is:" Web_Name

echo "Please enter the User of your Database:"
read -p"DataBase User Is:" DBS_User
echo "Please enter the Name of you Database:"
read -p"DataBase Name Is:" DBS_Name

Pack_Web(){
cd /root/Backup
tar -cvPf $Web_Name"_"$date.tar.gz $Web_Dir >> /dev/null
}

Pack_DBS(){
mysqldump -u $DBS_User -p $DBS_Name > /root/Backup/$DBS_Name.sql
}

Pack_All(){
cd /
mkdir DataBase_Backup_$date
mv /root/Backup/* /DataBase_Backup_$date
#tar -cvPf DataBase_Backup_$date.tar.gz /DataBase_Backup_$date >> /dev/null
zip -q -r DataBase_Backup_$date.zip /DataBase_Backup_$date >> /dev/null
mv DataBase_Backup_$date.zip /root/Backup/
rm -rf DataBase_Backup_$date/
}

if [ -e "/root/Backup" ];then
	Pack_Web
	Pack_DBS
	Pack_All
else
	mkdir /root/Backup
	Pack_Web
	Pack_DBS
	Pack_All
fi
