#!/bin/bash
#
# Copyright (c) 2018 Mellanox Technologies. All rights reserved.
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
# Author: Alaa Hleihel <alaa@mellanox.com>
#

dir=$1; shift

defsfile=/tmp/defs_file
output_dir=/var/tmp/clean_code
if [ ! -d "${dir}" ]; then
	echo "Path to dir not given" >&2
fi
if [ ! -f "${defsfile}" ]; then
	echo "defs file does not exist at ${defsfile}" >&2
fi
mkdir $output_dir
#need to add check for unifdef installed
for i in $(find ${dir} \( -name '*.c' -o \
			  -name '*.h' -o \
			  -name 'Kbuild' -o \
			  -name 'Makefile' \) )
do
	echo "FULL: $i"
	filename=$(basename $i)
	filepath=$(dirname $i)
	echo "FILE: $filename"
	echo "PATH: $filepath"
	#echo "cleaning ${i} ..."
	#filename=$(basename $i)
	#unifdef -f ${defsfile} ${i} -o $output_dir${i}
done
