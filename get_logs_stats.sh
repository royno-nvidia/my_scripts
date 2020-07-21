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

WDIR=$(cd ${0%/*} && pwd | sed -e 's/devtools//')
OUTPUT_FILE="filtered.csv"
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

	echo $(echo "$line" | sed -r -e 's/.*name=\s*/;/' -e 's/;\s*type=.*/;/')
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

get_subject_from_csv()
{
        local line=$1; shift

        echo $(echo "$line" | sed -r -e 's/^[^;]*;//' -e 's/\(.*\);.*//'| cut -f1 -d";")
}

get_line_without_id()
{
	local line=$1; shift

	echo $(echo "$line" |  cut -d" " -f2- )
}

get_line_without_subject()
{
	local line=$1; shift
	echo $(echo "$line" | cut -d" " -f1)
}
get_count()
{       
        local line=$1; shift

	echo $( grep -o "$line" ./filtered.csv | wc -l)        
}

##################################################################
#
# main
#

while [ ! -z "$1" ]
do
	case "$1" in
		-h | --help)
		echo "Usage: get_log_stats [-h]
			
	use this script to check the numbers of commits per feature in ./metadata/features_metadata_db.csv.
	precondition: 	must run 'slog_filter.sh' before running this script.
	Output: 	on screen - list of all features and commits count per each.
			in file './zero_commit_feature.txt' - feature without any commits.
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

RC=0
echo "Scanning files..."
file_path="./metadata/features_metadata_db.csv"
log_path="./filtered.csv"
temp_path="./temp.csv"
zero_list="./zero_commit_feature.txt"
echo "" > $zero_list
	while read -r line
	do
	
		feature=$(get_feature_from_csv "$line")		
		count=$(get_count "$feature")
		echo "$feature" "$count"
		if [ ${count} -eq 0 ]; then
			echo "${feature}" >> $zero_list
		fi
	done < $file_path
echo
echo "--------------------------------------------------------------"
echo "check for features with no commit at 'zero_commit_feature.txt'"
echo "--------------------------------------------------------------"
echo
exit $RC
