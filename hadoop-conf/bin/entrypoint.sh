#! /bin/bash

if [ "$HADOOP_ROLE" == "NAMENODE1" ] ; then
  if [ ! -f /root/hdfs/runonce.lock ]; then
    if [ ! -d /root/hdfs/namenode ]; then
      touch /root/hdfs/runonce.lock
      echo "NO DATA IN /root/hdfs/namenode"
      echo "FORMATTING NAMENODE"
      hdfs namenode -format || { echo 'FORMATTING FAILED' ; exit 1; }
    fi
  fi
  export HADOOP_ROLE="NAMENODE1"
elif [ "$HADOOP_ROLE" == "NAMENODE2" ] ; then
  if [ ! -f /root/hdfs/runonce.lock ]; then
    if [ ! -d /root/hdfs/namenode ]; then
      touch /root/hdfs/runonce.lock
      echo "NO DATA IN /root/hdfs/namenode"
      echo "SYNCING DATA FROM NAMENODE1"
      hdfs namenode -bootstrapStandby
    fi
  fi
  export HADOOP_ROLE="NAMENODE"
fi

hadoop-daemon.sh start zkfc
hdfs namenode
