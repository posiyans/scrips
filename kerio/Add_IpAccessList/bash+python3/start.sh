#!/bin/bash
IP_KERIO='192.168.0.1'
PASSWORD='123456'
sshpass -p $PASSWORD scp root@$IP_KERIO:/var/winroute/winroute.cfg ./winroute2.cfg
./start.py
sshpass -p $PASSWORD scp ./winroute.cfg root@$IP_KERIO:/var/winroute/winroute.cfg
sshpass -p $PASSWORD ssh root@$IP_KERIO chmod 700 /var/winroute/winroute.cfg
sshpass -p $PASSWORD ssh root@$IP_KERIO /etc/boxinit.d/60winroute restart
