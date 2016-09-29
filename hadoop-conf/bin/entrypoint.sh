#! /bin/bash

if [ "$HADOOP_ROLE" == "NAMENODE1" ] ; then
  if [ ! -f /data/hdfs/runonce.lock ]; then
    if [ ! -d /data/hdfs/namenode ]; then
      echo "NO DATA IN /data/hdfs/namenode"
      echo "FORMATTING NAMENODE"
      hdfs namenode -format || { echo 'FORMATTING FAILED' ; exit 1; }
    fi
    touch /data/hdfs/runonce.lock
  fi
  export HADOOP_ROLE="NAMENODE1"
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
fi

hadoop-daemon.sh start zkfc
hdfs namenode
