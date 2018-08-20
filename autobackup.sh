#!/usr/bin/env bash

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


#Web
cd /
tar -cvf $dir1"_"$date.tar $dir1 >> /dev/null
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
rm -rf $dir1"_"$date.tar

#MySql
mysqldump -u$databaseuser -p$databasepass -h127.0.0.1 $databasename1 > /$databasename1"_"$date.dump
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
rm -rf $databasename1"_"$date.dump


cp $0 /backup/autobackup.sh
echo "* * */"$day" * * /bin/bash /backup/autobackup.sh" >> /etc/crontab
/etc/rc.d/init.d/crond restart

bash $0
