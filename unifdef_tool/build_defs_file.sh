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
# Script usage: ./build_defs_file.sh <ofed_dir_path>
# This script uses to build config file unifdef can handle from given OFED dir

WORK_DIR=$1
COMPAT_FILE=$WORK_DIR/compat/config.h
AUTOCONF_FILE=$WORK_DIR/include/generated/autoconf.h
CONFIG_PATH=/tmp/config.h
CONFIGURE_PATH=/tmp/configure.ac
DEFSFILE=/tmp/defs_file.h
AUTOCONF_PATH=/tmp/final_autoconf.h
FINAL=/tmp/final_defs.h


echo "$FINAL"
sudo rm -rf $CONFIG_PATH $CONFIGURE_PATH $DEFSFILE $AUTOCONF_PATH
echo "start build compat file '$FINAL' for unifdef use"
/swgwork/royno/OFED/my_scripts/unifdef_tool/unifdef_installer.sh
if [ $? -ne 0 ];then
	echo "Script failed.."
	exit 1
fi
cp $COMPAT_FILE /tmp/$(date +%s)_$(basename $COMPAT_FILE)
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/split_config_h.sh $COMPAT_FILE
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/handle_config_h.sh $CONFIG_PATH
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/handle_configure_ac.sh $CONFIGURE_PATH
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/handle_autoconf_h.sh $AUTOCONF_FILE

echo "/*-----------------------*/" > $FINAL
echo "/* config.h defs section */" >> $FINAL
echo "/*-----------------------*/" >> $FINAL
cat $DEFSFILE >> $FINAL
echo "/*---------------------------*/" >> $FINAL
echo "/* configure.ac defs section */" >> $FINAL
echo "/*---------------------------*/" >> $FINAL
unifdef -f $DEFSFILE $CONFIGURE_PATH >> $FINAL
echo "/*-------------------------*/" >> $FINAL
echo "/* autoconf.h defs section */" >> $FINAL
echo "/*-------------------------*/" >> $FINAL
cat $AUTOCONF_PATH >> $FINAL

rm -rf $CONFIG_PATH $CONFIGURE_PATH $DEFSFILE $AUTOCONF_PATH
echo "'${FINAL}' created"

