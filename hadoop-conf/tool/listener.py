#!/bin/python
# coding:utf-8

import sys
import os
import subprocess
import socket
import fcntl
import struct
from optparse import OptionParser
# childutils这个模块是supervisor的一个模型，可以方便我们处理event消息
from supervisor import childutils


__doc__ = "\033[32m%s,捕获PROCESS_STATE_FATAL事件类型,当异常退出时触发报警\033[0m" % sys.argv[0]


def write_stdout(s):
    sys.stdout.write(s)
    sys.stdout.flush()


def write_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()


class CallError(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)


class ProcessesMonitor():

    def __init__(self):
        self.stdin = sys.stdin
        self.stdout = sys.stdout

    def runforever(self):
        while 1:
            # 下面这个东西，是向stdout发送"READY"，然后就阻塞在这里，一直等到有event发过来
            # headers,payload分别是接收到的header和body的内容
            headers, payload = childutils.listener.wait(
                self.stdin, self.stdout)
            # 判断event是否是需要的，不是的话，向stdout写入"RESULT\NOK"，并跳过当前
            # 循环的剩余部分
            if headers['eventname'] == 'PROCESS_STATE_FATAL':
                os.system(
                    "supervisorctl -s unix:///tmp/supervisor.sock shutdown")
                childutils.listener.ok(self.stdout)
                continue

            childutils.listener.ok(self.stdout)


def main():
    parser = OptionParser()
    if len(sys.argv) == 2:
        if sys.argv[1] == '-h' or sys.argv[1] == '--help':
            print __doc__
            sys.exit(0)
    #(options, args) = parser.parse_args()
    # 下面这个，表示只有supervisord才能调用该listener，否则退出
    if not 'SUPERVISOR_SERVER_URL' in os.environ:
        try:
            raise CallError(
                "%s must be run as a supervisor event" % sys.argv[0])
        except CallError as e:
            write_stderr("Error occurred,value: %s\n" % e.value)

        return

    prog = ProcessesMonitor()
    prog.runforever()

if __name__ == '__main__':
    main()