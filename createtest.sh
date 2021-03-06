#!/bin/bash
# 221dc31f9ea8
echo "create hd1 ..."
sudo docker run -id --name hd1 -h hd1 -p 5002:22 -p 9870:9870 -p 8088:8088 -p 19888:19888 221dc31f9ea8

echo "create hd2 ..."
sudo docker run -id --name hd2 -h hd2  -p 5003:22 221dc31f9ea8

echo "create hd3 ..."
sudo docker run -id --name hd3 -h hd3  -p 5004:22 221dc31f9ea8
# 查看启动容器
sudo docker ps
a=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hd1`
b=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hd2`
c=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hd3`

#开启ssh服务
echo "start ssh ..."
sudo docker exec hd1  /usr/sbin/sshd -D  2>/dev/null &
sudo docker exec hd2  /usr/sbin/sshd -D  2>/dev/null &
sudo docker exec hd3  /usr/sbin/sshd -D  2>/dev/null &
# 进入容器添加脚本

#将ip和域名放入hd1中
sudo docker exec -it hd1 /bin/install.sh "$b   hd2"
sudo docker exec -it hd1 /bin/install.sh "$c   hd3"
echo "waiting ..."
#将ip和域名放入hd2中
sudo docker exec -it hd2 /bin/install.sh "$a   hd1"
sudo docker exec -it hd2 /bin/install.sh "$c   hd3"
echo "waiting ..."
#将ip和域名放入hd3中
sudo docker exec -it hd3 /bin/install.sh "$a   hd1"
sudo docker exec -it hd3 /bin/install.sh "$b   hd2"
# 格式化namenode
echo "namenode format ..."
sudo docker exec -it hd1 /usr/local/hadoop-3.1.1/bin/hdfs namenode -format
echo "start hdfs ..."
sudo docker exec -it hd1 /usr/local/hadoop-3.1.1/sbin/start-dfs.sh
echo "start yarn ..."
sudo docker exec -it hd1 /usr/local/hadoop-3.1.1/sbin/start-yarn.sh
echo "success ..."
sudo docker exec -it hd1 /usr/local/jdk1.8.0_191/bin/jps
exit

