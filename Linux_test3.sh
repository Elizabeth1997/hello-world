#!/bin/bash
#-z 为判断字符串是否为空
if [ -z $JAVA_HOME ];then  
	java_file="/usr/local/java" 
	if [ ! -d "$java_file" ]; then
		mkdir $java_file
	fi
	cd /usr/local/java
	#下载jdk
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz  
    #解压缩 tar.gz 归档压缩文件
    tar -xvf jdk-8u131-linux-x64.tar.gz
    #设置环境变量
    export JAVA_HOME="/usr/local/java/jdk1.8.0_131" 
    if ! grep "JAVA_HOME=/usr/local/java/jdk1.8.0_131" /etc/environment
    	then
    	echo "JAVA_HOME=/usr/local/java/jdk1.8.0_131" | sudo tee -a /etc/environment
    	echo "export JAVA_HOME" | sudo tee -a /etc/environment
		echo "PATH=$PATH:$JAVA_HOME/bin" | sudo tee -a /etc/environment	  
	    echo "export PATH" | sudo tee -a /etc/environment  
	    echo "CLASSPATH=.:$JAVA_HOME/lib" | sudo tee -a /etc/environment  
	    echo "export CLASSPATH" | sudo tee -a /etc/environment  
	fi
	source /etc/environment  
	echo "Congraduation! jdk has been installed successfully !"   

else  
	JAVA_VERSION=$(java -version 2>&1 | awk 'NR==1{gsub(/"/,"");print $3}')
	echo "版本号为：$JAVA_VERSION"
    echo "JDK的安装路径为：$JAVA_HOME" 	
fi   

function install_apache(){
echo "apache2.4.7 will be installed,please be patient"
cd /usr/local/src
#下载httpd
wget http://archive.apache.org/dist/apr/apr-1.4.5.tar.gz  
wget http://archive.apache.org/dist/apr/apr-util-1.3.12.tar.gz   
wget http://mirror.bit.edu.cn/apache/httpd/httpd-2.4.29.tar.gz
#解压缩

tar -zxf apr-1.4.5.tar.gz
cd apr-1.4.5
./configure --prefix=/usr/local/apr
make && make install

cd /usr/local/src
tar zxf apr-util-1.3.12.tar.gz
cd apr-util-1.3.12
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
make && make install

yum -y install pcre-devel

cd /usr/local/src
tar -zxf httpd-2.4.29.tar.gz
/bin/cp -r apr-1.4.5 /usr/local/src/httpd-2.4.29/srclib/apr
/bin/cp -r apr-util-1.3.12 /usr/local/src/httpd-2.4.29/srclib/apr-util
cd httpd-2.4.29
./configure --prefix=/usr/local/apache2 --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/ --with-pcre --enable-mods-shared=most --enable-so --with-included-apr
# make是编译  make install是安装
make && make install

echo "export PATH=$PATH:/usr/local/apache2/bin" >>/etc/profile
source /etc/profile
#配置防火墙等
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
/etc/init.d/iptables save
/usr/local/apache2/bin/apachectl
}

function start_httpd_service(){
#启动
/usr/local/apache2/bin/apachectl start
#查看是否正常监听80端口
netstat -lntp|grep 80
#查看80端口占用情况
lsof -i :80
#查看是否启动成功
#wget http://172.18.98.21
}
#判断是否安装了httpd
ISEEMPTY=$(find / -name 'httpd')
if [ -z $ISEEMPTY ]; then
	install_apache
	echo "Httpd is installed!"
	start_httpd_service
else 
	HTTPD_VERSION=$(/usr/local/apache2/bin/httpd -v)
	HTTPD_POSITION=$(find / -name 'httpd'|head -1)
	echo "httpd的版本为：$HTTPD_VERSION"
	echo "httpd的安装位置为：$HTTPD_POSITION"
	start_httpd_service
	#还需要知道安装的路径
fi
