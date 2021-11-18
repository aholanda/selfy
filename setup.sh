#!/usr/bin/env bash

INSTALL='apt-get install -y'

# Setup basic Linux box
${INSTALL} git gpg sudo wget

# Set sudo to not prompt for password
sed -i 's/^#\s*\(%sudo\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers

