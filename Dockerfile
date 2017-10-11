FROM admik/cobbler_ol69

ENV ftp_proxy http://IP.AD.DR.ES:3128
ENV http_proxy http://IP.AD.DR.ES:3128
ENV https_proxy http://IP.AD.DR.ES:3128
ENV no_proxy IP.AD.DR.ES

VOLUME [ " /sys/fs/cgroup " ]
VOLUME [ " /var/lib/cobbler " ]
VOLUME [ " /var/lib/cobbler/api_cobbler " ]
VOLUME [ " /var/www/cobbler " ]
VOLUME [ " /etc/cobbler " ]
VOLUME [ " /etc/dhcp " ]
VOLUME [ " /var/log " ]

ADD setup.sh /root/setup.sh
ADD chain.c32 /usr/lib/syslinux/chain.c32
ADD menu.c32 /usr/lib/syslinux/menu.c32
ADD pxelinux.0 /usr/lib/syslinux/pxelinux.0
ADD run_script.sh /root/run_script.sh
ADD OM-MgmtStat-Dell-Web-LX-8.5.0-2372_A00.tar.gz /root
RUN cd /root/linux/rac/RHEL7/x86_64 && yum -y localinstall *.rpm && rm -rf /root/linux /root/docs

ADD epel-release-7-10.noarch.rpm /root
RUN rpm -ivh /root/epel-release-7-10.noarch.rpm
RUN rm -f /etc/yum.repos.d/*.repo
ADD OracleLinux-7.3-x86_64-0.repo /etc/yum.repos.d
ADD OracleLinux-7.3-x86_64-1.repo /etc/yum.repos.d
ADD OracleLinux-7.3-x86_64-2.repo /etc/yum.repos.d
ADD OracleLinux-7.3-x86_64-3.repo /etc/yum.repos.d
ADD epel7.repo /etc/yum.repos.d

RUN yum install -y openssl-devel --skip-broken

ADD freetype-2.4.11-12.el7.x86_64.rpm /root
RUN yum -y localinstall /root/freetype-2.4.11-12.el7.x86_64.rpm

ADD python-pygments-1.4-9.el7.noarch.rpm /root
RUN rpm --rebuilddb
RUN yum -y localinstall /root/python-pygments-1.4-9.el7.noarch.rpm

RUN rpm --rebuilddb
RUN yum install -y cobbler-web.noarch cobbler.x86_64 ftp tftp-server* xinetd* dhcp-common.x86_64 dhcp.x86_64 dnsmasq.x86_64 nmap.x86_64 tcpdump.x86_64 httpd.x86_64 git.x86_64 automake.noarch make.x86_64 telnet wget

RUN echo "log-facility local7;" >> /etc/cobbler/dhcp.template
RUN mkdir -p /tftpboot
RUN cp -pr /etc/cobbler /etc/cobbler-default
RUN cp -pr /var/lib/cobbler /var/lib/cobbler-default
RUN cp -pr /etc/dhcp /etc/dhcp-default
RUN rm -f /root/*.rpm root/reboot_via_console.sh

CMD /root/setup.sh && httpd && cobblerd && while true; do /root/run_script.sh; sleep 10; done
