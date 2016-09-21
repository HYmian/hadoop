FROM openjdk:8

MAINTAINER mian <gopher.mian@outlook.com>

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server curl && rm -rf /var/lib/apt/lists/*

# install hadoop 2.7.3
RUN curl -O http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz && \
    tar -xzvf hadoop-2.7.3.tar.gz && \
    mv hadoop-2.7.3 /usr/local/hadoop && \
    rm hadoop-2.7.3.tar.gz

RUN curl -O https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/1.2.3/hbase-1.2.3-bin.tar.gz && \
    tar -xzvf hbase-1.2.3-bin.tar.gz && \
    mv hbase-1.2.3 /usr/local/hbase && \
    rm hbase-1.2.3-bin.tar.gz

# set environment variable
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/hbase/bin

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    sed -i "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

ADD config/ /tmp/
ADD tool/* /bin/

RUN mv /tmp/hdfs/ssh_config ~/.ssh/config && \
    mv /tmp/hdfs/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/hdfs/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/hdfs/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/hdfs/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/hdfs/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/hdfs/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/hdfs/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/hbase/* /usr/local/hbase/conf/

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]
