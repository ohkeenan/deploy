#!/bin/bash

# Check for CentOS 7.1
version="7.1"
if [[ $(cat /etc/centos-release | grep $version) ]]; then
	echo $version "found."
else
	echo $version "not found."; exit
fi


# Check if EPEL-Release installed
epelpkg="epel-release"
if [[ $(yum list installed $epelpkg | grep $epelpkg) ]]; then
	echo $epelpkg "found."
else
	echo $epelpkg "not found. Installing."; yum -y install $epelpkg
fi


# Check if Ajenti is installed
ajentipkg="ajenti"
if [[ $(yum list installed $ajentipkg | grep $ajentipkg) ]]; then
    echo $ajentipkg "found."
else
    curl https://raw.githubusercontent.com/ajenti/ajenti/1.x/scripts/install-rhel7.sh | sh
fi


# Check if version matches for config then cp and read
now="$(date +'%F-%H%M')"
ajenticonf="/etc/ajenti/config.json"

if [[ $(cat $ajenticonf | grep "root") ]]; then
	cp $ajenticonf $ajenticonf$now;
	read -p "Choose Password for Ajenti: " -s ajentiPass; echo ""
else
	echo "$ajenticonf \"root\" default entry not found. Aborting."; exit
fi

# Replace password:
sed -i "s/sha512.*/$ajentiPass\",/g" $ajenticonf


# Remove httpd and postfix as per instructions
yum -y remove httpd postfix


# Disable SELinux 
# For Ajenti V Mail, SELinux interfers with 
# Courier-authlib authentication, so consider disabling it
setenforce 0


# Install Ajenti V LNMP:
yum -y install ajenti-v ajenti-v-nginx ajenti-v-mysql ajenti-v-php-fpm php-mysql


# Restart
systemctl restart ajenti
