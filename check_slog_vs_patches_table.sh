#!/bin/bash

# USAGE PURPOSE:
# run this script at the end of REBASE stage.
# the script will output diff between your patches tracking table and final
# OFED slog, please verify diff.
#
# HOWTO:
# this script should be copied to last OFED version mlnx-ofa_kernel-4.0 directory.
# copy ONLY subject from patches tracking table that marked as inside OFED
# to file and give it to script as
#
# run the script and result output to the screen.
# run example: './check_slog_vs_patches_table.sh ./inside_pathces_subjects.txt'
#
# Author: Roy Novich <royno@nvidia.com>
################################################################################


sh='slog_helper.txt'
ph='patches_helper.txt'

if [ "X$1" == "X" ]; then
	echo "-E- scripts must get path to file with"
	echo "all subject in patches tracking table"
	echo "that marked as inside OFED"
	exit 1
fi

echo "script is running..."
echo
git log --pretty="format:%s" | sort > $sh
sort $1 > $ph
echo "commits in patches tables that miss from slog:"
echo "----------------------------------------------"
diff --changed-group-format='%<' --unchanged-group-format=''  $ph $sh
echo
echo
echo "commits in slog that miss from patches table:"
echo "----------------------------------------------"
diff --changed-group-format='%<' --unchanged-group-format='' $sh $ph

rm -rf $sh
rm -rf $ph

echo
echo "script ended... please verify all commits in output"
