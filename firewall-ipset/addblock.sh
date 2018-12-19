#!/bin/bash
FILE_NAME=$2
BLOCK_NAME=$1
echo 'file name: ' $FILE_NAME
echo 'Block name: ' $BLOCK_NAME
ipset --flush $BLOCK_NAME
ipset create $BLOCK_NAME nethash
for ip in $(cat $FILE_NAME | grep -v '#') ; do ipset --add $BLOCK_NAME $ip; done
iptables -D INPUT -m set --match-set $BLOCK_NAME src -j LOG --log-prefix " Drop Bad IP List $BLOCK_NAME" --log-level 6 
iptables -D INPUT -m set --match-set $BLOCK_NAME src -j DROP
iptables -v -I INPUT -m set --match-set $BLOCK_NAME src -j DROP
iptables -v -I INPUT -m set --match-set $BLOCK_NAME src -j LOG --log-prefix " Drop Bad IP List $BLOCK_NAME" --log-level 6 
