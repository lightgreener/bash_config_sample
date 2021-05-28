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

7, Set the maximum number of open files
8, Minimize the use of swap
9, System kernel parameter optimization
10, Install some system test tools


