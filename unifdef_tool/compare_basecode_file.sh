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
# Script usage: ./compare_basecode_file.sh <file_name> <config1> <config2>
# This script uses to compare OFED specific file base code as compiled in 2 different kernels

FILENAME=$1
CONFIG1=$2
CONFIG2=$3
POST_FIX="${FILENAME#*.}"
UNIF1_NAME=$(echo $(basename $CONFIG1) | sed -e 's/\./_/g')_$(basename $FILENAME)
UNIF2_NAME=$(echo $(basename $CONFIG2) | sed -e 's/\./_/g')_$(basename $FILENAME)
PROC1=/tmp/$(echo $(basename $CONFIG1) | sed -e 's/\./_/g')_proccessed.h
PROC2=/tmp/$(echo $(basename $CONFIG2) | sed -e 's/\./_/g')_proccessed.h
UNIF1=/tmp/$UNIF1_NAME
UNIF2=/tmp/$UNIF2_NAME

/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/build_defs_file.sh $CONFIG1 $PROC1
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/build_defs_file.sh $CONFIG2 $PROC2

unifdef -f $PROC1 $FILENAME -o $UNIF1
unifdef -f $PROC2 $FILENAME -o $UNIF2

vim $UNIF1 +"vsplit $UNIF2"

rm -rf $PROC1 $PROC2
echo
echo
echo "Created base code files '$UNIF1' '$UNIF2'"
echo "Script ended"
