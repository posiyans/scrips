#!/bin/bash

echo '!!! Add list from https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/blocklist_de.ipset !!!'
FILE_NAME=blacklist.txt
BLOCK_NAME=blacklist 
wget -O $FILE_NAME https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/blocklist_de.ipset
./addblock.sh  $BLOCK_NAME $FILE_NAME
rm ./blacklist.txt

echo '!!! Add local list !!!'
./create_local_black_list.sh
FILE_NAME=./blacklist/blacklist_ip.txt 
BLOCK_NAME=localblacklist
./addblock.sh  $BLOCK_NAME $FILE_NAME


