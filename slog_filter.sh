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

get_subject_from_csv()
{
        local line=$1; shift

        echo $(echo "$line" | sed -r -e 's/^[^;]*;//'| cut -f1 -d";")
}

get_line_without_subject()
{
	local line=$1; shift
	echo $(echo "$line" | cut -d" " -f1)
}

get_all_but_CID()
{
	local line=$1; shift
	echo $(echo "$line" | sed -r -e 's/^[^;]*;//')
}
##################################################################
#
# main
#

while [ ! -z "$1" ]
do
	case "$1" in
		-h | --help)
		echo "Usage: slog_filter [-h]

	use this script to get patches table of all OFED patches.
	precondition: 	run 'analyze_metadata' [this script use 'combined.csv'].
			must run inside mlnx-ofa_kernel-4.0 directory.
	Output: 'filtered.csv'
	errors: 'filter_errors.txt'

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
echo "commitID; subject; feature; upstream_status; general; type; author; Fixes; changeID; dup" >>$OUTPUT_FILE
RC=0
echo "Scanning files..."
file_path="./combined.csv"
log_path="./ofa_log.txt"
err_path="./filter_errors.txt"
touch ${log_path}
touch ${err_path}
git log --oneline --color=never > ${log_path}
	while read -r line
	do
		commitID="$(get_line_without_subject "$line")"
		changeID=$(git show ${commitID} | grep Change-Id: | head -1| cut -d":" -f2)
		if [ -z $"$changeID" ]; then
			echo "no change-id found for commit: "${commitID}"" >> $err_path
			continue
		fi
		line_at_combined=$(grep ${changeID} ${file_path})
		subject=$(get_subject_from_csv "${line_at_combined}")
		if [ -z "$subject" ]; then
			echo "no subject found for commit: "${commitID}"" >> $err_path
			continue
		fi
		fixes=$(git show $commitID | grep "Fixes:" | sed -e 's/Fixes://' | sed 's/^ *//g' | sed ':a;N;$!ba;s/\n/ /g')
		patch_data="$(get_all_but_CID "${line_at_combined}")"
		copies=$(grep "${subject}" "${file_path}" | wc -l)
		if [ $copies -gt 1 ]; then
			echo "${commitID}; ${patch_data} $fixes; ${changeID}; dup subject" >>$OUTPUT_FILE
		else
			echo "${commitID}; ${patch_data} $fixes; ${changeID};" >>$OUTPUT_FILE
		fi

	done < $log_path
	echo "script is done,"
	echo "result at 'filtered.csv"
	if [ -s "$err_path" ]; then
		echo "please check errors at 'filter_errors.txt'"
	else
		rm -f "$err_path"
	fi
exit $RC
