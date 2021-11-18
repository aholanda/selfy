#!/usr/bin/env bash

M='setup>'
INSTALL='apt-get install -y'

# Setup basic Linux box
${INSTALL} git gpg sudo wget

echo "$M set sudo group to not be prompted for password" 
sed -i 's/^%sudo\s*ALL=(ALL:ALL)\s*ALL/%sudo ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

