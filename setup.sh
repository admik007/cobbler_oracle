#!/bin/bash
set -e
set -x
set -u

test -f /etc/cobbler/settings || rsync -avHS /etc/cobbler-default/ /etc/cobbler/

test -f /var/lib/cobbler/kickstarts/default.ks || rsync -avHS /var/lib/cobbler-default/ /var/lib/cobbler/

mkdir -p /var/log/apache2
mkdir -p /var/lib/cobbler
mkdir -p /var/www/cobbler
mkdir -p /tftpboot
