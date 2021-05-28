#!/bin/env bash

# 28/05/2021
# Author: henry 

# 1, Set time zone for local 
ln -s /usr/share/zoneinfo/Australia/Sydney /etc/localtime
if ! crontab -l |grep ntpdate &>/dev/null ; then
	(echo "* 1 * * * ntpdate time.windows.com >/dev/null 2>&1" ; crontab -l) | crontab
fi


# 2, Disable selinux
# cat /etc/selinux/config  make sure SELINUX=disabled
sed -i '/SELINUX/{s/enforing/disabled/}' /etc/selinux/config


# 3, Disable firewall
# if centos 7 versions
if egrep "7.[0-9]" /etc/redhat-release &>/dev/null; then
	systemctl stop firewalld
	systemctl disable firewalld
# if centos 6 versions
elif egrep "6.[0-9]" /etc/redhat-release &>/dev/null; then
	service iptables stop
	chkconfig iptables off
fi

# 4, Show the time and user of history commands

if ! grep HISTTIMEFORMAT /etc/bashrc; then
	echo 'export HISTTIMEFORMAT="%d-%m-%Y %T `whoami` "' >>/etc/bashrc
fi

# 5, SSH time out
# shut SSH connection after a certain time. for security reason
if ! grep "TMOUT=600" /etc/profile &>/dev/null; then
	echo " export TMOUT=600" >> /etc/profile
fi


# 6, Disable remote login for root
# security reason coz root is a default user
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config



# 7, Disable scheduled tasks to send email to root
# /etc/crontab  some junk mail stored
sed -i 's/^MAILTO=root/MAILTO=""/' /etc/crontab 

# 8, Set the maximum number of files which can open at the same time
# cat EOF should be in the left
if ! grep "* soft nofile 65535" /etc/security/limits.conf &>/dev/null ; then
	cat >> /etc/security/limits.conf << EOF
	* soft nofile 65535
	* hard nofile 65535
EOF
fi


# 9, Minimize the use of swap
# sofe disk and it slows down. 
echo "0" > /proc/sys/vm/swappiness


# 10, System kernel parameter optimization
cat >> /etc/systcl.conf << EOF
	net.ipv4.tcp_syncookies = 1
	net.ipv4.tcp_max_tw_buckets = 20480
	net.core.netdev_max_backlog = 262144
	net.ipv4.tcp_max_syn_backlog = 20480
	net.ipv4.tcp_fin_timeout = 20
EOF


# 11, Install some system test tools
yum install gcc make autoconf sysstat net-tools iostat iftop iotp lrzsz -y

