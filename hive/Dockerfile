FROM openjdk:8

MAINTAINER mian <gopher.mian@outlook.com>

WORKDIR /root

# install hive 2.1.0
RUN curl -O https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-2.1.0/apache-hive-2.1.0-bin.tar.gz && \
    tar -xzvf apache-hive-2.1.0-bin.tar.gz && \
    mv apache-hive-2.1.0-bin /usr/local/hive && \
    rm apache-hive-2.1.0-bin.tar.gz

# set environment variable
ENV HIVE_HOME=/usr/local/hive
ENV PATH=$PATH:/usr/local/hive/bin
