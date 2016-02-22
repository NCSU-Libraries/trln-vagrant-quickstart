#!/bin/sh

set -e

# make sure kernel-headers are installed 
if [ -z "$(rpm -qa kernel-headers)" ]; then
	yum -y install kernel-headers
fi


# update kernel and headers package to latest;
# this should help keep virtualbox guest additions working
# with *less* fuss.

yum update -y kernel kernel-headers

echo "Latest kernel installed"

# make sure NetworkManager > 1.0 is installed

yum update -y systemd NetworkManager

# make sure puppet's installed so we can do the rest of 
# the provisioning with that
#if [ -z "$(rpm -qa puppetlabs-release)" ]; then
#	echo "Adding puppet labs repository"
#	rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
#fi


#if [ -z "$(rpm -qa puppet)" ]; then
#	echo "Installing puppet on guest"
#	yum install -y puppet
#fi

if [ ! "$(which puppet)" ]; then
	echo "Where is puppet?"
	exit 1
fi

echo "Puppet installation/check  complete"

echo "End base package installation"

	
