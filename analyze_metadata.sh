#!/bin/bash
#
# Copyright (c) 2016 Mellanox Technologies. All rights reserved.
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
#
# Author: Shani Shapp shanish@mellanox.com
#
#########################################################################
#------------------------------------------------------#
# usage:
# run this script inside mlnx-ofa_kernel-4.0 directory #
#------------------------------------------------------#
WDIR=$(cd ${0%/*} && pwd | sed -e 's/devtools//')
OUTPUT_FILE="combined.csv"
FEATURES_DB="metadata/features_metadata_db.csv"
STATUS_DB="NA \
		   ignore \
		   in_progress \
		   sent
		   accepted \
		   rejected \
"

get_feature_from_csv()
{
	local line=$1; shift

	echo $(echo "$line" | sed -r -e 's/.*;\s*feature=\s*/name=/' -e 's/;\s*upstream_status.*/;/')
}

clear_line()
{
	local line=$1

	echo $(echo "$line" | sed -e 's/\s*Change-Id=//' -e 's/\s*subject=//' -e \
                              's/\s*feature=//' -e 's/\s*upstream_status=//' -e 's/\s*general=//')
}

get_type_from_db()
{
	local feature=$1; shift
	line=`grep "$feature" metadata/features_metadata_db.csv`
	if [ "$line" = "" ]; then
		return
	fi
	echo $(echo "$line"|sed -r -e 's/.*;\s*type=\s*//' -e 's/;\s*upstream.*//')
}

##################################################################
#
# main
#

while [ ! -z "$1" ]
do
	case "$1" in
		-h | --help)
		echo "Usage: analyze_metadata [-h]
		
	use this script to combine all metadata commits in one form.
	this script need to run before 'slog_filter' [slog_filter uses this script output].	
	Output: 	'combined.csv'.
			must run inside mlnx-ofa_kernel-4.0 directory.	

		-h, --help 		display this help message and exit
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

echo "sep=;">$OUTPUT_FILE
echo "change_id; subject; feature; upstream_status; general; type;" >>$OUTPUT_FILE
RC=0
echo "Scanning files..."
for file_path in ./metadata/*.csv
do
	if [ $file_path == "./metadata/features_metadata_db.csv" ];then
			continue
	fi
	while read -r line
	do
		case "$line" in
			*'sep=;'*)
			continue
			;;
		esac
		cerrs=
		cleared_line=$(clear_line "$line")
		feature=$(get_feature_from_csv "$line")
		ty=$(get_type_from_db "$feature")
		author="$(basename -- $file_path)"
		echo "${cleared_line} ${ty}; ${author};" >> $OUTPUT_FILE

	done < $file_path
done

echo "Found $RC issues."
if [ $RC -ne 0 ]; then
	echo "Please fix the above issues"
	echo "Then run again"
else
	echo "passed."
fi
exit $RC
