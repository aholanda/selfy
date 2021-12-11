#!/usr/bin/env bash

case $1 in
	--install)
		shift
		ansible-playbook main.yml $@
		;;
	*)
		echo "usage: $0 --install"
		;;
esac

exit 0
