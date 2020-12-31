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


get_feature_from_csv()
{
	local line=$1; shift

	echo $(echo "$line" | sed -r -e 's/.*name=\s*/;/' -e 's/;\s*type=.*/;/')
}

get_count()
{       
        local feature=$1; shift

	echo $( grep -ow "$feature" ./filtered.csv | wc -l)        
}

get_status()
{       
        local feature=$1; shift
	local type=$1; shift

	echo $( grep -w "$feature" ./filtered.csv |  grep "$type" | wc -l)        
}

##################################################################
#
# main
#

WDIR=$(cd ${0%/*} && pwd | sed -e 's/devtools//')
OUTPUT_FILE="feature_statistics.csv"
FEATURES_DB="metadata/features_metadata_db.csv"
STATUS_DB="NA \
		   ignore \
		   in_progress \
		   accepted \
		   rejected \
"

while [ ! -z "$1" ]
do
	case "$1" in
		-h | --help)
		echo "Usage: get_log_stats [-h]
			
	use this script to check the numbers of commits per feature in ./metadata/features_metadata_db.csv.
	precondition: 	must run 'slog_filter.sh' before running this script.
	Output: 	feature_statistics.csv - list of all features and commits count per each.
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

echo "sep=;">$OUTPUT_FILE
echo "feature; overall; NA; in_progress; ignore; rejected; accepted;" >> $OUTPUT_FILE
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
		if [ "X${feature}" == "Xsep=;" ]; then
			continue
		fi		
		feature=$(echo "$feature"| cut -d";" -f2)
		count=$(get_count "$feature")
		NA=$(get_status "$feature" "NA")
		progress=$(get_status "$feature" "in_progress")
		ignore=$(get_status "$feature" "ignore")
		accepted=$(get_status "$feature" "accepted")
		rejected=$(get_status "$feature" "rejected")
		echo "$feature; $count; $NA; $progress; $ignore; $rejected; $accepted;" >> $OUTPUT_FILE
		if [ ${count} -eq 0 ]; then
			echo "${feature}" >> $zero_list
		fi
	done < $file_path
echo
echo "--------------------------------------------------------------"
echo "see results in 'feature_statistics.csv'"
echo "check for features with no commit at 'zero_commit_feature.txt'"
echo "--------------------------------------------------------------"
echo
exit $RC
