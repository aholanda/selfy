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
	*)
		>&2 echo "usage: $0 --install-office|--install-programming"
		>&2 echo " --install-office"
		>&2 echo "    Install packages to setup a basic office environment."
		>&2 echo " --install-programming"
		>&2 echo "    Install packages to setup a basic computer programming (not web) environment."
		exit 1
		;;
esac

exit 0
