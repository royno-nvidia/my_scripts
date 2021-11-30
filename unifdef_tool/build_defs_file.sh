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
# Script usage: ./build_defs_file.sh <ofed_dir_path> <output_filename(optional)>
# This script uses to build config file unifdef can handle from given OFED dir
if [ -d "$1" ]; then
	IS_DIR=1
	WORK_DIR=$1
	COMPAT_FILE=$WORK_DIR/compat/config.h
else
	if [ -f "$1" ]; then
	IS_DIR=0
	COMPAT_FILE=$1
	else
		echo "-E- Argument 1 for script must be directory/file path"
		exit 1
	fi

fi
echo $COMPAT_FILE
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CONFIG_PATH=/tmp/config.h
CONFIGURE_PATH=/tmp/configure.ac
MK_PATH=${WORK_DIR}/configure.mk.kernel
DEFSFILE=/tmp/defs_file.h
FINAL=$2
if [ -z "$FINAL" ];then
	FINAL=/tmp/final_defs.h
fi

sudo rm -rf $CONFIG_PATH $CONFIGURE_PATH $DEFSFILE
echo "start build compat file '$FINAL' for unifdef use"
cp $COMPAT_FILE /tmp/$(date +%s)_$(basename $COMPAT_FILE)
$SCRIPTS_DIR/split_config_h.sh $COMPAT_FILE
$SCRIPTS_DIR/handle_config_h.sh $CONFIG_PATH
$SCRIPTS_DIR/handle_configure_ac.sh $CONFIGURE_PATH

echo "/*-----------------------*/" > $FINAL
echo "/* config.h defs section */" >> $FINAL
echo "/*-----------------------*/" >> $FINAL
echo "/*-----------------------*/" >> $DEFSFILE
echo "/* configure.mk.kernel defs section */" >> $DEFSFILE
echo "/*-----------------------*/" >> $DEFSFILE
grep =y ${MK_PATH} | sort | uniq | sed -e 's/=y/ 1/' | sed -e 's/^/#define /' >> $DEFSFILE
grep -E "=$"  ${MK_PATH} | sort | uniq | sed -e 's/=//' | sed -e 's/^/#undef /' >> $DEFSFILE
cat $DEFSFILE >> $FINAL
echo "/*---------------------------*/" >> $FINAL
echo "/* configure.ac defs section */" >> $FINAL
echo "/*---------------------------*/" >> $FINAL
unifdef -f $DEFSFILE $CONFIGURE_PATH >> $FINAL

rm -rf $CONFIG_PATH $CONFIGURE_PATH $DEFSFILE
echo "'${FINAL}' created"

