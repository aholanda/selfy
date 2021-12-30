#!/usr/bin/env bash

function setup {
	M='setup>'
	INSTALL='sudo apt-get install -y'
	ANSIBLE_DIR='/etc/ansible'

	# Setup basic Linux box
	${INSTALL} git gpg sudo wget ansible && \
		if  [ ! -d ${ANSIBLE_DIR} ];then sudo mkdir ${ANSIBLE_DIR};fi &&\
	      	sudo cp ./hosts ${ANSIBLE_DIR}

	echo "$M set sudo group to not be prompted for password" 
	sudo sed -i 's/^%sudo\s*ALL=(ALL:ALL)\s*ALL/%sudo ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
}

function print_usage_and_exit {
		>&2 echo "usage: $0 [OPTIONS] <ANSIBLE-PLAYBOOK ARGS>"
		>&2 echo " where OPTIONS may be:"
		>&2 echo "  --install-office"
		>&2 echo "    Install packages to setup a basic office environment."
		>&2 echo "  --install-programming"
		>&2 echo "    Install packages to setup a basic computer programming (not web) environment."
		>&2 echo "  --install-webdev"
		>&2 echo "    Install packages to setup a basic web development environment."
		>&2 echo "  <ANSIBLE-PLAYBOOK ARGS>"
		>&2 echo "     All arguments accepted by ansible-playbook command."
		>&2 echo "  --setup"
		>&2 echo "    Setup the environment to execute $0."
		exit 1
}

if [ "$#" -eq 0 ];
then
	print_usage_and_exit
fi

if [ "`which ansible`" == "" ];
then
	setup
fi


case $1 in
	--install-programming)
		shift
		ansible-playbook programming.yml $@
		;;
	--install-office)
		shift
		ansible-playbook office.yml $@
		;;
	--install-webdev)
		shift
		ansible-playbook programming.yml --extra-vars "is_webdev_env=True" $@
		;;
	--setup)
		setup
		;;
	*)
		print_usage_and_exit
		;;
esac

exit 0

