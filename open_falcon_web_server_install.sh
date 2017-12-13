#!/bin/bash
#auth liutao
#date 2017-9-27

#使用时替换以下变量
install_home=/root/install
client_ip=`ip address | grep "global e"| cut -d ' ' -f6 | cut -d '/' -f1`
mysql_server_ip=192.168.100.190
mysql_usenamer=root
mysql_password=123456

#依赖环境
yum install git -y

#源代码
cd $install_home
git clone https://github.com/open-falcon/dashboard.git

#官方依赖
yum install -y python-virtualenv
yum install -y python-devel
yum install -y openldap-devel
yum install -y mysql-devel
yum groupinstall "Development tools" -y

cd $install_home/dashboard/
virtualenv ./env
./env/bin/pip install -r pip_requirements.txt -i https://pypi.douban.com/simple

#替换ip，改为服务端实际位置
sed -i "/^API_ADDR/s/127.0.0.1/$mysql_server_ip/g" $install_home/dashboard/rrd/config.py
sed -i "/^PORTAL_DB_HOST/s/127.0.0.1/$mysql_server_ip/g" $install_home/dashboard/rrd/config.py
sed -i "/^ALARM_DB_HOST/s/127.0.0.1/$mysql_server_ip/g" $install_home/dashboard/rrd/config.py

#替换账号密码
sed -i "/^PORTAL_DB_USER/s/root/$mysql_usenamer/g" $install_home/dashboard/rrd/config.py
sed -i "/^ALARM_DB_USER/s/root/$mysql_usenamer/g" $install_home/dashboard/rrd/config.py
sed -i "/^PORTAL_DB_PASS/s/\"\"/\"$mysql_password\"/g" $install_home/dashboard/rrd/config.py
sed -i "/^ALARM_DB_PASS/s/\"\"/\"$mysql_password\"/g" $install_home/dashboard/rrd/config.py

#安装python支持模块
yum install epel-release -y
yum install python-pip -y
pip install --upgrade pip
pip install gunicorn
pip install flask
pip install flask-Babel
pip install requests
pip install MySQL-python

#启动客户端
mv $install_home/dashboard/ /usr/local/
/usr/local/dashboard/control start

#访问验证
echo "sucessful!! http:/$client_ip:8081"
