#! /bin/bash

if [ "$HADOOP_ROLE" == "NAMENODE1" ]; then
    if [ ! -f /data/hdfs/runonce.lock ]; then
        echo "oh! this is my first run"
        if [ ! -d /data/hdfs/namenode ]; then
            echo "as expected, there is no namenode"
            echo "I begin to format namenode"
            hdfs namenode -format -nonInteractive
            if [ $? -ne 0 ]; then
                echo "I format namenode failed, ok, maybe I should to run as standby"
                echo "I begin to sync data from active namenode"
                hdfs namenode -bootstrapStandby
                if [ $? -ne 0 ]; then
                    echo "I can't sync data from active namenode"
                    echo "sad, my first run is over"
                    exit -1
                fi
                echo "success, I'm ready for standby name node"
            else
                echo "success, the name node belong to me from now"
            fi
        else
            echo "surprise, there have name node already in my first run"
        fi
        echo "I begin to format zookeeper"
        hdfs zkfc -formatZK -nonInteractive
        if [ $? -ne 0 ]; then
            echo "I can't format zookeeper, maybe I have formated it in previous existence"
        else
            echo "success, I have formated it"
        fi
        touch /data/hdfs/runonce.lock
    fi
    export HADOOP_ROLE="NAMENODE"
    cp /supervisord/$HADOOP_ROLE /etc/supervisord.conf
    supervisord -n -c /etc/supervisord.conf
elif [ "$HADOOP_ROLE" == "NAMENODE2" ]; then
    if [ ! -f /data/hdfs/runonce.lock ]; then
        echo "oh! this is my first run"
        if [ ! -d /data/hdfs/namenode ]; then
            echo "as expected, there is no namenode"
            echo "I begin to sync data from active namenode"
            hdfs namenode -bootstrapStandby
            if [ $? -ne 0 ]; then
                echo "I can't sync data from active namenode"
                echo "sad, my first run is over"
                exit -1
            fi
            echo "success, I'm ready for standby name node"
        else
            echo "surprise, there have name node already in my first run"
        fi
        touch /data/hdfs/runonce.lock
    fi
    export HADOOP_ROLE="NAMENODE"
    cp /supervisord/$HADOOP_ROLE /etc/supervisord.conf
    supervisord -n -c /etc/supervisord.conf
elif [ "$HADOOP_ROLE" == "RESOURCEMANAGER" ] ; then
    cp /supervisord/$HADOOP_ROLE /etc/supervisord.conf
    supervisord -n -c /etc/supervisord.conf
elif [ "$HADOOP_ROLE" == "NODEMANAGER" ] ; then
    cp /supervisord/$HADOOP_ROLE /etc/supervisord.conf
    supervisord -n -c /etc/supervisord.conf
elif [ "$HADOOP_ROLE" == "HMASTER" ]; then
    cp /etc/hosts /etc/hosts.old
    sed -e "s/.*`hostname`/`curl -s http://rancher-metadata/latest/self/container/ips/0` `hostname`/g" /etc/hosts.old > /etc/hosts
    cp /supervisord/$HADOOP_ROLE /etc/supervisord.conf
    supervisord -n -c /etc/supervisord.conf
elif [ "$HADOOP_ROLE" == "HREGIONSERVER" ]; then
    cp /etc/hosts /etc/hosts.old
    sed -e "s/.*`hostname`/`curl -s http://rancher-metadata/latest/self/container/ips/0` `hostname`/g" /etc/hosts.old > /etc/hosts
    cp /supervisord/$HADOOP_ROLE /etc/supervisord.conf
    supervisord -n -c /etc/supervisord.conf
elif [ "$HADOOP_ROLE" == "HIVE" ]; then
    if [ ! -f $HIVE_HOME/runonce.lock ]; then
        hdfs dfs -mkdir -p /tmp/hive
        hdfs dfs -chmod 733 /tmp/hive
        schematool -dbType derby -initSchema
        hiveserver2
        touch $HIVE_HOME/runonce.lock
    fi
fi
