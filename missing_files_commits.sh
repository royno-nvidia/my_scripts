#!/bin/bash

# USAGE PURPOSE:
# run this script before REBASE stage.
# the script will output commits that changed files no longer exists in
# in new OFED version, those commits should be mark and treat with more suspicious.
#
# HOWTO:
# this script should be copied to last OFED version mlnx-ofa_kernel-4.0 directory.
# run this script with argument- full path to your new OFED version repository.
#
# run the script and result output to the screen.
# run example: "./missing_files_commits.sh ../mlnx-ofa_kernel-4.0_5_9-rc2/'
#
# Author: Roy Novich <royno@nvidia.com>
################################################################################


NEW_VER_PATH=$1
OLD_VER_PATH=$PWD

if [ "X$1" == "X" ]; then
	echo "-E- scripts must get path to new OFED repository"
	exit 1
fi
echo "script is running..."
echo
echo "search for file who missing in new version"
echo "------------------------------------------"
MISS_FILES=""
MISS_FILES="$MISS_FILES $(diff -crw $OLD_VER_PATH/drivers/ $NEW_VER_PATH/drivers/ | grep "^Only in $OLD_VER_PATH" | sed -r -e 's/^.*Only in //' -e 's@: @/@' | sed 's/.*drivers/drivers/')"
MISS_FILES="$MISS_FILES $(diff -crw $OLD_VER_PATH/include/ $NEW_VER_PATH/include/ | grep "^Only in $OLD_VER_PATH" | sed -r -e 's/^.*Only in //' -e 's@: @/@' | sed 's/.*include/include/')"
MISS_FILES="$MISS_FILES $(diff -crw $OLD_VER_PATH/net/ $NEW_VER_PATH/net/ | grep "^Only in $OLD_VER_PATH" | sed -r -e 's/^.*Only in //' -e 's@: @/@' | sed 's/.*net/net/')"
echo

for file in $MISS_FILES
do
	slog_file=$(git log --oneline $file)
	if [[ $slog_file == *"Set base code"* ]];
	then
		echo "File '$file':"
		echo "$slog_file"
		echo
	fi
done
echo
echo
echo "search for file who removed during old version"
echo "----------------------------------------------"
REMOVE_FILES=$(git log --diff-filter=D --summary drivers/ include/ net/ | grep delete | cut -d" " -f 5)
echo
for file in $REMOVE_FILES
do
	slog_file=$(git log --oneline -- $file)
	if [[ ! $slog_file == *"Initial commit"* ]];
	then
		echo "File '$file':"
		echo "$slog_file"
		echo
	fi
done
echo
echo "script ended..."
