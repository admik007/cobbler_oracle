#!/bin/bash
set -e
set -x
set -u

mkdir -p /var/log/httpd
mkdir -p /var/log/cobbler/tasks
mkdir -p /var/lib/cobbler
mkdir -p /var/www/cobbler
mkdir -p /tftpboot

if [ ! -f /etc/cobbler/settings ]; then
  rsync -avHS /etc/cobbler-default/ /etc/cobbler/
fi

#if [ ! -f /etc/dhcp/dhcpd.conf ]; then
# rsync -avHS /etc/dhcp-default/ /etc/dhcp/
#fi

if [ ! -f /var/lib/cobbler/kickstarts/default.ks ]; then
 rsync -avHS /var/lib/cobbler-default/ /var/lib/cobbler/
 rsync -avHS /var/www/cobbler-default/ /var/www/cobbler/
fi

#echo "sed -i 's/127.0.0/`ip a | grep eth0 | grep global | awk {'print $2'} | cu                                                     t -d '.' -f1,2,3`/g' /etc/cobbler/settings" | bash
echo "sed -i 's/192.168.1/`ip a | grep eth0 | grep global | awk {'print $2'} | c                                                     ut -d '.' -f1,2,3`/g' /etc/cobbler/dhcp.template" | bash

/etc/init.d/rsyslog restart
/etc/init.d/cobblerd restart
/etc/init.d/httpd restart
cobbler sync
/etc/init.d/xinetd restart
