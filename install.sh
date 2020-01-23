#!/bin/bash

if [ $EUID -ne 0 ]; then
	echo "USAGE: sudo $0"
	exit 1
fi
executer=$(who am i | awk '{print $1}')


# Install Docker
apt remove docker docker-engine docker.io containerd runc
apt update
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#apt-add-repository --yes --update ppa:ansible/ansible

apt update
apt install -y software-properties-common python-virtualenv python-pip
apt install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker $USER
#apt install -y ansible

# install ansible role
ansible-galaxy install --roles-path ./roles emmetog.jenkins 2> /dev/null
mkdir -p /data
chown $executer:$executer /data

sed -i "s/ubuntu/$executer/g" roles/emmetog.jenkins/defaults/main.yml

if [ ! -d venv ]; then
	virtualenv venv
fi
source venv/bin/activate
pip install -r requirements.txt
ansible-playbook deploy-jenkins.yml
