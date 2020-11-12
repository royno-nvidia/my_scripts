#!/bin/bash

OS=$(cat /etc/os-release | grep -w ID | sed -e 's/.*=//g')
echo "Checking if unifdef installed"
if ! command -v unifdef &> /dev/null
then
	echo "unifdef tool is missing.. installing"
	case $OS in
		*fedora*)
			sudo yum -y install unifdef
			;;
		*rhel*)
			wget "https://www.rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/u/unifdef-2.10-14.fc33.x86_64.rpm"
			sudo rpm -ivh unifdef-2.10-14.fc33.x86_64.rpm
			;;
		*sles*)
			wget "https://www.rpmfind.net/linux/opensuse/distribution/leap/15.2/repo/oss/x86_64/unifdef-2.11-lp152.3.6.x86_64.rpm"
			sudo rpm -ihv unifdef-2.11-lp152.3.6.x86_64.rpm
			;;
		*ubuntu*)
			sudo apt install unifdef
			;;
		*)
			echo "Can't handle $OS os, Aborting"
			exit 1
			;;
	esac
else
	echo "Already installed"
fi
