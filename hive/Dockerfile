FROM openjdk:8

MAINTAINER mian <gopher.mian@outlook.com>

WORKDIR /root

# install hadoop 2.7.3
RUN curl -O http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz && \
    tar -xzvf hadoop-2.7.3.tar.gz && \
    mv hadoop-2.7.3 /usr/local/hadoop && \
    rm hadoop-2.7.3.tar.gz

# install hive 2.1.0
RUN curl -O https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-2.1.0/apache-hive-2.1.0-bin.tar.gz && \
    tar -xzvf apache-hive-2.1.0-bin.tar.gz && \
    mv apache-hive-2.1.0-bin /usr/local/hive && \
    rm apache-hive-2.1.0-bin.tar.gz

# set environment variable
ENV HADOOP_HOME=/usr/local/hadoop \
    HIVE_HOME=/usr/local/hive \
    PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/hive/bin