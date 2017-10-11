#!/bin/bash
FILE=/var/lib/cobbler/api_cobbler/cobbler_file.txt
BACKINFO=/var/lib/cobbler/api_cobbler/cobbler_send.txt
REBOOT=/var/lib/cobbler/api_cobbler/cobbler_reboot.txt
USER=`cat /var/lib/cobbler/api_cobbler/credentials.txt | grep USER | cut -d ':' -f2`
PASS=`cat /var/lib/cobbler/api_cobbler/credentials.txt | grep PASS | cut -d ':' -f2`

HOSTSFILE=`cat /etc/hosts | grep -i MYHOST | wc -l`
if [ ${HOSTSFILE} -eq '0' ]; then
echo "192.168.0.11 MYHOST01" >> /etc/hosts
echo "192.168.0.12 MYHOST02" >> /etc/hosts
fi

if [ -f $FILE ]; then
. /etc/bashrc
        for HOST in `cat ${FILE}`; do
                cobbler system edit --name=${HOST} --netboot-enabled=TRUE
                echo ${HOST}_`date` >> ${REBOOT}
                racadm -r $HOST -u $USER -p $PASS --nocertwarn config -g cfgServerInfo -o cfgServerFirstBootDevice PXE > /dev/null 2>&1
                racadm -r $HOST -u $USER -p $PASS --nocertwarn config -g cfgServerInfo -o cfgServerBootOnce 0 > /dev/null 2>&1
                racadm -r $HOST -u $USER -p $PASS --nocertwarn serveraction powercycle > /dev/null 2>&1
        done
        cobbler sync
rm -f $FILE
fi

for SYSTEM in `cobbler system list`; do
        echo -n "${SYSTEM} " >> ${BACKINFO}.tmp
        echo `cobbler system report --name=${SYSTEM} | grep "Netboot Enabled" | awk {'print $4'}` >> ${BACKINFO}.tmp
done
rm -f ${BACKINFO}
mv ${BACKINFO}.tmp ${BACKINFO}
