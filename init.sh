#!/usr/bin/env bash

sudo su

# Installing yum-utils so MongoDB repo can be added
if [[ -z $(rpm -qa | grep -o yum-utils ) ]]; then
	yum -y install yum-utils 
	echo "yum-utils has been installed."
else
	echo "yum-utils already installed."
fi

# Installing policycoreutils so SELinux can be permanently set to permisive
if [[ -z $(rpm -qa | grep -o policycoreutils-python) ]]; then
	yum -y install policycoreutils-python 
	echo "policycoreutils-python has been installed."
else
	echo "policycoreutils-python already installed."
fi

# Unlocking necessary ports due to SELinux policies
if [[ -z $(semanage port -l | grep -o 27017) ]]; then
	semanage port -a -t mongod_port_t -p tcp 27017 
	echo "27017 port added."
else
	echo "27017 port already defined."
fi

# Setting policy to permisive permanently
if [[ -n $(cat /etc/selinux/config | grep -o SELINUX=enforcing) ]]; then
	sed -i -e 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
	echo "SELinux policy permanently changed to permissive."
else
	echo "SELinux policy already changed to permissive/dissabled."
fi

# Adding MongoDB repository
if [[ -z $( yum repolist | grep mongodb) ]]; then
	yum-config-manager --add-repo https://repo.mongodb.org/yum/redhat/mongodb-org.repo
	echo "MongoDB repository added."
else
	echo "MongoDB repository already exists on the list."
fi

# Installing MongoDB
if [[ -z $(rpm -qa | grep -o mongo) ]]; then
	yum install -y mongodb-org
	echo "mongodb-org has been installed."
else
	echo "mongodb-org already installed."
fi

# Changing bindIp property in /etc/mongod.conf so it can be accessed from host
if [[ -n $(cat /etc/mongod.conf | grep -o 127.0.0.1) ]]; then
	sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
	echo "Listening changed to all interfaces."
else
	echo "Listening already set to listen on all interfaces."
fi

reboot

sudo service mongod start