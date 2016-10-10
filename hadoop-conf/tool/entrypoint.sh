#! /bin/bash

if [ "$HADOOP_ROLE" == "NAMENODE1" ] ; then
    if [ ! -f /data/hdfs/runonce.lock ]; then
        if [ ! -d /data/hdfs/namenode ]; then
          echo "NO DATA IN /data/hdfs/namenode"
          echo "FORMATTING NAMENODE"
          hdfs namenode -format || { echo 'FORMATTING FAILED' ; exit 1; }
        fi
    hdfs zkfc -formatZK -force
    touch /data/hdfs/runonce.lock
    fi
    export HADOOP_ROLE="NAMENODE1"
    hadoop-daemon.sh start zkfc
    hdfs namenode
elif [ "$HADOOP_ROLE" == "NAMENODE2" ] ; then
    if [ ! -f /data/hdfs/runonce.lock ]; then
      if [ ! -d /data/hdfs/namenode ]; then
        echo "NO DATA IN /data/hdfs/namenode"
        echo "SYNCING DATA FROM NAMENODE1"
        hdfs namenode -bootstrapStandby
      fi
    touch /data/hdfs/runonce.lock
    fi
    export HADOOP_ROLE="NAMENODE"
    hadoop-daemon.sh start zkfc
    hdfs namenode
elif [ "$HADOOP_ROLE" == "HMASTER" ]; then
    cp /etc/hosts /etc/hosts.old
    sed -e "s/.*`hostname`/`curl -s http://rancher-metadata/latest/self/container/ips/0` `hostname`/g" /etc/hosts.old > /etc/hosts
    hbase-daemon.sh start master
    /tool/server -n 10 -conf /tool/server-conf.yml
elif [ "$HADOOP_ROLE" == "HREGIONSERVER" ]; then
    cp /etc/hosts /etc/hosts.old
    sed -e "s/.*`hostname`/`curl -s http://rancher-metadata/latest/self/container/ips/0` `hostname`/g" /etc/hosts.old > /etc/hosts
    /tool/agent -s hmaster1:34616 -conf /tool/agent-conf.yml
    /tool/agent -s hmaster2:34616 -conf /tool/agent-conf.yml
    hbase regionserver start
fi