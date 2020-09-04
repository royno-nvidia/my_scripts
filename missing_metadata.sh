#!/bin/bash

# USAGE PURPOSE:
# Help to notify about commits that has missing lines over
# metadata, those commits need to be tested more carefully when
# rebase start.
#
# HOWTO:
# this script should be copied to last OFED version mlnx-ofa_kernel-4.0 directory.
# just run the script and result output to the screen.
#
# Author: Roy Novich <royno@nvidia.com>
################################################################################





old_ifs=$IFS
IFS=$'\n'
err=0
commits=

echo "Script start, looking for commits missing metadata.."
echo
echo "------------------------------------"
for sub in $(git log --pretty="format:%s");
do
	if (echo $commits | grep -qi $sub); then
		continue
	fi
	in_slog=$(git slog | grep $sub | wc -l)
	in_meta=$(git grep $sub metadata/ | wc -l)
	if [ $in_slog -gt $in_meta  ]; then
		echo "-I- $sub"
		commits="$commits $sub"
		err=$((err += 1))
	fi
done

echo "------------------------------------"
if [ $err -gt 0 ]; then
	echo "Found $err patches that need closer look [subjects has more slog than metadata]"
else
	echo "No issues found."
fi
echo "script finished"
IFS=$old_ifs
