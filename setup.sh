#!/usr/bin/env bash

M='setup>'
INSTALL='sudo apt-get install -y'
ANSIBLE_DIR='/etc/ansible'

# Setup basic Linux box
${INSTALL} git gpg sudo wget ansible && \
	if  [ ! -d ${ANSIBLE_DIR} ];then sudo mkdir ${ANSIBLE_DIR};fi &&\
	      sudo cp ./hosts ${ANSIBLE_DIR}

echo "$M set sudo group to not be prompted for password" 
sudo sed -i 's/^%sudo\s*ALL=(ALL:ALL)\s*ALL/%sudo ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

