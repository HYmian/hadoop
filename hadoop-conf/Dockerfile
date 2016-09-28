FROM busybox

MAINTAINER mian <gopher.mian@outlook.com>

ADD config/hdfs/* /usr/local/hadoop/etc/hadoop/
VOLUME /usr/local/hadoop/etc/hadoop/

ADD config/hbase/* /usr/local/hbase/conf/
VOLUME /usr/local/hbase/conf

ADD bin /hadoop/
VOLUME /hadoop
