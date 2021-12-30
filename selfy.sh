#!/usr/bin/env bash

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
	*)
		>&2 echo "usage: $0 --install-office|--install-programming <ANSIBLE-PLAYBOOK ARGS>"
		>&2 echo " --install-office"
		>&2 echo "    Install packages to setup a basic office environment."
		>&2 echo " --install-programming"
		>&2 echo "    Install packages to setup a basic computer programming (not web) environment."
		>&2 echo " --install-webdev"
		>&2 echo "    Install packages to setup a basic web development environment."
		>&2 echo " <ANSIBLE-PLAYBOOK ARGS>"
		>&2 echo "    All arguments accepted by ansible-playbook command."
		exit 1
		;;
esac

exit 0
