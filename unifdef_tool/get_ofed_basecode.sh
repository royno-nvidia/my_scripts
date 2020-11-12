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
# IMPORTANT: This script must be sourced to get full functionality

ofa=$(\ls /usr/src | grep mlnx-ofa_kernel)
ofa_dir=/usr/src/$ofa/
CONFIG=/tmp/final_config.h
NEW_DIR="/var/tmp/${ofa}_basecode"
if [[ "$(basename -- "$0")" == "get_ofed_basecode.sh" ]]; then
	    echo "Don't run $0, source it" >&2
	        exit 1
	fi
echo "script running.."
echo $ofa
if [ "X" == "X$ofa" ]; then
	echo "-E- No Kernel src found, Aborting.." >&2
	return 1
fi
if [ ! -d $NEW_DIR ];then
	echo "Copy src to $NEW_DIR"
	sudo /bin/cp -rf $ofa_dir $NEW_DIR
fi	
cd $NEW_DIR
echo "Inside $PWD"
if [ ! -f "compat/config.h" ]; then
	echo "Configuring ofed envaironment"
	sudo /swgwork/royno/OFED/my_scripts/configure_ofed_env
	if [ $? -ne 0 ];then
		echo
		echo "Script failed.."
		return 1
	fi
fi
sudo chown -f ${whoami} -R  $NEW_DIR
sudo chown -f ${whoami} compat/config.h
echo "Configure Done"
echo "Create config file"
/swgwork/royno/OFED/my_scripts/unifdef_tool/split_config_h.sh $PWD/compat/config.h
if [ $? -ne 0 ];then
	echo "Script failed.."
	return 1
fi
/swgwork/royno/OFED/my_scripts/unifdef_tool/handle_config_h.sh /tmp/config.h
if [ $? -ne 0 ];then
	echo "Script failed.."
	return 1
fi
/swgwork/royno/OFED/my_scripts/unifdef_tool/handle_configure_ac.sh /tmp/configure.ac
if [ $? -ne 0 ];then
	echo "Script failed.."
	return 1
fi

if [ ! -f "${CONFIG}" ]; then
	echo "-E- Config file does not exist at ${CONFIG}" >&2
	return 1
fi
echo "start cleaning files.."
/swgwork/royno/OFED/my_scripts/unifdef_tool/unifdef_installer.sh
if [ $? -ne 0 ];then
	echo "Script failed.."
	return 1
fi
for i in $(find ${PWD} \( -name '*.c' -o \
			  -name '*.h' -o \
			  -name 'Kbuild' -o \
			  -name 'Makefile' \) )
do
	echo "cleaning ${i} ..."
	sudo unifdef -f ${CONFIG} ${i} -o ${i}.tmp -b
	mv -f ${i}.tmp $i
done

echo
echo "Script ended succsfully!"
echo "Look for config.h at '$CONFIG'"
echo "OFED plain basecode directory: '$NEW_DIR'"
echo "Original OFED directory: '$ofa_dir'"
