#!/bin/bash
#auth liutao
#date 2017-9-27

#使用时替换以下变量
install_home=/root/install
mysql_server_ip=192.168.100.190
mysql_usenamer=root
mysql_password=123456

#安装依赖环境
yum install wget unzip mysql -y

#初始化mysql和redis
docker run -d -p 3306:3306 --name open-falcon-mysql -e MYSQL_ROOT_PASSWORD=$mysql_password mysql
docker run -d -p 6379:6379 --name open-falcon-redis redis

#数据库安装(源码包才有数据库文件，二进制包没有，所以这里只能先用源码包把数据装上)
cd $install_home
wget https://github.com/open-falcon/falcon-plus/archive/master.zip
unzip master.zip
rm master.zip -f

cd ${install_home}/falcon-plus-master/scripts/mysql/db_schema
mysql -h$mysql_server_ip -u$mysql_usenamer -p$mysql_password < 1_uic-db-schema.sql
mysql -h$mysql_server_ip -u$mysql_usenamer -p$mysql_password < 2_portal-db-schema.sql
mysql -h$mysql_server_ip -u$mysql_usenamer -p$mysql_password < 3_dashboard-db-schema.sql
mysql -h$mysql_server_ip -u$mysql_usenamer -p$mysql_password < 4_graph-db-schema.sql
mysql -h$mysql_server_ip -u$mysql_usenamer -p$mysql_password < 5_alarms-db-schema.sql

#下载二进制包
cd $install_home
wget https://github.com/open-falcon/falcon-plus/releases/download/v0.2.1/open-falcon-v0.2.1.tar.gz
mkdir open-falcon
tar -zxvf open-falcon-v0.2.1.tar.gz -C open-falcon
rm open-falcon-v0.2.1.tar.gz -f

#替换字符串
cd $install_home/open-falcon
grep -Ilr 3306  ./ | xargs -n1 -- sed -i "s/$mysql_usenamer:/$mysql_usenamer:$mysql_password/g"
grep -Ilr 3306  ./ | xargs -n1 -- sed -i "s/127.0.0.1/$mysql_server_ip/g"
mv $install_home/open-falcon /usr/local/

#启动服务
/usr/local/open-falcon/open-falcon restart

#查看状态
/usr/local/open-falcon/open-falcon check
