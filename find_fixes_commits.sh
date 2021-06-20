#!/bin/bash
#
# Copyright (c) 2016 Mellanox Technologies. All rights reserved.
#
# This Software is licensed under one of the following licenses:
#
# 1) he terms of the "Common Public License 1.0" a copy of which is
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
# Author: Roy Novich royno@nvidia.com
#
#########################################################################
RC=0
SHOW_ALL=false
##################################################################
#
# main
#
OUTPUTFILE="fixes_table.csv"
while [ ! -z "$1" ]
do
	case "$1" in
		-h | --help)
		echo "Usage: find_fixes_commits.sh [options]

		Description: This script uses for find all OFED patches that Fixes other patches.
			     It should be run under MLNX_OFA project ditrctory.

		-h, --help 		display this help message and exit.
		-a, --show-all		show all Fixes include upstream.
		-o, --otuput		redirect output file.
"
		exit 1
		;;
		-a | --show-all)
			SHOW_ALL=true
		;;
		-o | --output)
			shift
			OUTPUTFILE=$1
		;;
		*)
		echo "-E- Unsupported option: $1" >&2
		echo "use -h flag to display help menu"
		exit 1
		;;
	esac
	shift
done
echo "sep=;">$OUTPUTFILE
echo "Subject; Fixes; Status;" >>$OUTPUTFILE
slog=$(git log --oneline --color=never --pretty=format:%h)
full_slog=$(git log --oneline --color=never --pretty=format:"%h %s")
first_commit=$(git log --oneline --color=never --pretty=format:%h | tail -1)
manually_check=""
OLD_IFS=$IFS
for sha in $slog
do
	#fail in log at Initial commit
	if [ "$sha" == "$first_commit" ]; then
		continue
	fi
	cmsg=$(git log $sha^..$sha)
	sub=$(git log $sha^..$sha --color=never --pretty=format:"%s")
	if (echo $cmsg | grep -qE ".*Fixes.*"); then
		fixes_line=$(echo $cmsg | grep -E ".Fixes.*[0-9a-f]{12}")
		fixes_hash=$(echo $fixes_line | grep -oE "[0-9a-f]{12}")
		fixes_sub=$(echo $fixes_line | grep -oE "\".*\"" | sed 's/\"//g')
		# catch cases Fixes in commit but no hash provided
		if [ -z "$fixes_hash" ]; then
			manually_check="$manually_check $sha"
			continue
		fi
		if (echo $full_slog | grep -q "$fixes_sub"); then
			echo "$sub;$fixes_sub;;" >> $OUTPUTFILE
		fi
		IFS=$OLD_IFS
	fi
done
if [ ! -z "$manually_check" ]; then
	echo
	echo "Please check manually:"
	echo $manually_check
fi
echo 
echo "See results in '$OUTPUTFILE'"
exit $RC
