#!/bin/bash
FILE=/var/lib/cobbler/api_cobbler/cobbler_file.txt
BACKINFO=/var/lib/cobbler/api_cobbler/cobbler_send.txt
USER=`cat /var/lib/cobbler/api_cobbler/credentials.txt | grep USER | cut -d ':' -f2`
PASS=`cat /var/lib/cobbler/api_cobbler/credentials.txt | grep PASS | cut -d ':' -f2`

if [ -f $FILE ]; then
        for HOST in `cat ${FILE}`; do
                cobbler system edit --name=${HOST} --netboot-enabled=TRUE
                cobbler sync
                racadm -r ${HOST} -u ${USER} -p ${PASS} config -g cfgServerInfo -o cfgServerFirstBootDevice PXE
                racadm -r ${HOST} -u ${USER} -p ${PASS} config -g cfgServerInfo -o cfgServerBootOnce 0
                racadm -r ${HOST} -u ${USER} -p ${PASS} serveraction powercycle
        done
fi
rm -f $FILE
for SYSTEM in `cobbler system list`; do
        echo -n "${SYSTEM} " >> ${BACKINFO}.tmp
        echo `cobbler system report --name=${SYSTEM} | grep "Netboot Enabled" | awk {'print $4'}` >> ${BACKINFO}.tmp
done
rm -f ${BACKINFO}
mv ${BACKINFO}.tmp ${BACKINFO}
