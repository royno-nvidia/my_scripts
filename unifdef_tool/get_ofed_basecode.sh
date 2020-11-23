#!/bin/bash
#
# Copyright (c) 2020 Mellanox Technologies. All rights reserved.
#
# This Software is licensed under one of the following licenses:
#
# 1) under the terms of the "Common Public License 1.0" a copy of which is
#    available from the Open Source Initiative, see
#    http://www.opensource.org/licenses/cpl.php.
#
# 2) under the terms of the "The BSD License" a copy of which is
#    available from the Open Source Initiative, see
#    http://www.opensource.org/licenses/bsd-license.php.
#
# 3) under the terms of the "GNU General Public License (GPL) Version 2" a
#    copy of which is available from the Open Source Initiative, see
#    http://www.opensource.org/licenses/gpl-license.php.
#
# Licensee has the right to choose one of the above licenses.
#
# Redistributions of source code must retain the above copyright
# notice and one of the license notices.
#
# Redistributions in binary form must reproduce both the above copyright
# notice, one of the license notices in the documentation
# and/or other materials provided with the distribution.
#
# Author: Roy Novich <royno@nvidia.com>
#
# IMPORTANT: This script must be run as root
SCRIPT_NAME=$(basename "$0")
ofa=$(\ls /usr/src | grep mlnx-ofa_kernel)
ofa_dir=/usr/src/$ofa/
CUSTOM_OFA_DIR=
CUSTOM_CONFIG=
NEW_DIR="/var/tmp/${ofa}_basecode"
CONFIG=/tmp/$(date +%s)_final_defs.h 
if [ ! "$USER" == "root" ]; then
	echo "$USER, please run this script as root"
	echo "Aborting.."
	exit 1
fi
while [ ! -z "$1" ]
do
	case "$1" in
		-d | --directory)
		CUSTOM_OFA_DIR=$2
		if [ ! -d $CUSTOM_OFA_DIR ]; then
			echo "Path '$CUSTOM_OFA_DIR' is not a directory,"
			echo "Please make sure to give mlnx_ofed directory path as argument."
			echo "Aborting.."
			exit 1
		fi
		shift;
		;;
		-c | --config-file)
		CUSTOM_CONFIG=$2
		if [ ! -f $CUSTOM_CONFIG ]; then
			echo "Path '$CUSTOM_CONFIG' is not a file,"
			echo "Please make sure to give config.h file path as argument."
			echo "Aborting.."
			exit 1
		fi
		shift;
		;;
		-h | --help)
		echo "Usage: ${SCRIPT_NAME} [options]
			
	use this script to get OFED code without #ifdef.

		-h, --help 		Display this help message and exit.
		-d, --directory		Path to specific OFED directory,
					default is '$ofa_dir'
		-c, --config-file	Path to specific ready config file,
					script will not create new one.
"
		exit 1
		;;
		*)
		echo "-E- Unsupported option: $1" >&2
		echo "use -h flag to display help menu" 
		exit 1
		;;
	esac 
	shift
done
if [ ! -z "$CUSTOM_OFA_DIR" ];then
	ofa_dir=$CUSTOM_OFA_DIR
	dir_owner=$(stat -c '%U' $ofa_dir)
	NEW_DIR="/var/tmp/$(basename $ofa_dir)_basecode_$(date +%Y-%m-%d_%H-%M)"
else
	if [ -z "$ofa" ]; then
		echo "-E- No Kernel src found, Aborting.." >&2
		exit 1
	fi
fi
echo "script running.."
cd $ofa_dir
echo "Inside $PWD"
if [ ! -f "compat/config.h" ]; then
	echo "Configuring ofed envaironment"
	sudo /swgwork/royno/OFED/my_scripts/configure_ofed_env
	if [ $? -ne 0 ];then
		echo
		echo "Script failed.."
		exit 1
	fi
fi
if [ ! -d $NEW_DIR ];then
	echo "Copy src to $NEW_DIR"
	sudo /bin/cp -rf $ofa_dir $NEW_DIR
else
	echo "Directory '$NEW_DIR' exists, Aborting.."
	exit 1
fi	
cd $NEW_DIR
echo "Inside $PWD"
echo "Configure Done"
if [ -z "$CUSTOM_CONFIG" ];then
	echo "Create config file"
	/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/build_defs_file.sh $NEW_DIR $CONFIG
else
	/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/unifdef_installer.sh
	CONFIG=$CUSTOM_CONFIG
fi
if [ ! -f "${CONFIG}" ]; then
	echo "-E- Config file does not exist at '${CONFIG}'" >&2
	exit 1
fi
echo "start cleaning files.."
for i in $(find ${PWD} \( -name '*.c' -o \
			  -name '*.h' -o \
			  -name 'Kbuild' -o \
			  -name 'Makefile' \) )
do
	echo "cleaning ${i} ..."
	unifdef -f ${CONFIG} ${i} -o ${i}.tmp
	mv -f ${i}.tmp $i
done

echo
echo "Script ended succsfully!"
echo "---------------------------------------------------------------------------"
echo "OFED plain basecode directory: '$NEW_DIR'"
echo "Original OFED directory: '$ofa_dir'"
echo "Look for config.h at '$CONFIG'"
echo "---------------------------------------------------------------------------"

