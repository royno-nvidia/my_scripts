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

ofa=$(\ls /usr/src | grep mlnx-ofa_kernel)
ofa_dir=/usr/src/$ofa/
NEW_DIR="/var/tmp/${ofa}_basecode"
CONFIG=/tmp/final_defs.h 
if [ ! "$USER" == "root" ]; then
	echo "This script must be run as root"
	exit 1
fi
echo "script running.."
echo $ofa
if [ "X" == "X$ofa" ]; then
	echo "-E- No Kernel src found, Aborting.." >&2
	exit 1
fi
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
/swgwork/royno/OFED/my_scripts/unifdef_tool/unifdef_installer.sh
if [ $? -ne 0 ];then
	echo "Script failed.."
	exit 1
fi
echo "Create config file"
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/build_defs_file.sh $NEW_DIR
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

