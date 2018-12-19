#!/bin/bash
    
MAIL_SQL=$(echo "SELECT username FROM mailbox WHERE active = 1" | mysql --defaults-extra-file=/etc/mysql/debian.cnf vmail)


IP_WHITE_LIST_NEW=$(cat /var/log/dovecot.log | grep 'imap-login: Info: Login:'  \
	| grep -v 'rip=127.0.0.1' | grep -v 'user=<>' | awk '{print $9}' \
	| sort | uniq | awk -F'rip=' '{print $2}' | awk -F',' '{print $1}' |  sort | uniq )


echo $IP_WHITE_LIST_NEW | sed 's/ /\n/g' > /tmp/temp.txt
cat ./whitelist/whitelist_ip.txt >> /tmp/temp.txt
cat /tmp/temp.txt | sort | uniq | sed 's/ /\n/g' > ./whitelist/whitelist_ip.txt
IP_WHITE_LIST=$(cat ./whitelist/whitelist_ip.txt)


MAIL=$(cat /var/log/dovecot.log | grep 'auth failed' | grep -v 'user=<>' | awk -F'user=<' '{print $2}' | awk -F'>' '{print $1}' |  sort | uniq )
MAIL_WHITE_LIST=$MAIL_SQL
IP_WHITE_LIST=$(cat ./whitelist/whitelist_ip.txt)
for i in $MAIL_WHITE_LIST
do
    MAIL=$(echo $MAIL | sed "s/$i//g")
done

MAIL=$(echo $MAIL | sed 's/ /|/g')
#echo $MAIL
IP_BAN=$(cat /var/log/dovecot.log | grep -E "user=<>|$MAIL" |  awk -F'rip=' '{print $2}' | awk -F',' '{print $1}' |  sort | uniq) 
#echo $IP_BAN 
OLD_IPBAN=$(cat ./blacklist/blacklist_ip.txt)
for i in $IP_WHITE_LIST
do
    IP_BAN=$(echo $IP_BAN | sed "s/ $i / /g")
    OLD_IPBAN=$(echo $OLD_IPBAN | sed "s/ $i / /g")
    
 #echo $i
done





echo $IP_BAN  > /tmp/temp.txt
echo $OLD_IPBAN  >> /tmp/temp.txt
#cat  /tmp/temp.txt
> /tmp/temp2.txt
for i in $(cat /tmp/temp.txt | sort | uniq | sed 's/127.0.0.1 //g')
do
    #echo ${#i}
    
    #echo $i | awk -F "." '{print NF}'
    if (( $(echo $i | awk -F "." '{print NF}') != 4 ))
    then
	    echo $i
	else
	    echo $i >> /tmp/temp2.txt
    fi
done
cat /tmp/temp2.txt | sort | uniq 
cat /tmp/temp2.txt | sort | uniq | sed 's/127.0.0.1 //g' | sed 's/ /\n/g' > ./blacklist/blacklist_ip.txt



