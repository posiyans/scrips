#!/bin/bash
DIR=`dirname $(readlink -e "$0")`
echo '!!! Add list from https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/blocklist_de.ipset !!!'
FILE_NAME=$DIR/blacklist.txt
BLOCK_NAME=blacklist 
wget -O $FILE_NAME https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/blocklist_de.ipset
$DIR/addblock.sh  $BLOCK_NAME $FILE_NAME
rm $DIR/blacklist.txt

echo '!!! Add local list !!!'
$DIR/create_local_black_list.sh
FILE_NAME=$DIR/blacklist/blacklist_ip.txt 
BLOCK_NAME=localblacklist
$DIR/addblock.sh  $BLOCK_NAME $FILE_NAME




