#!/bin/bash

CONFIG_LIST=$1; shift
OUTPUT_FILE="which_files_defines.csv"
echo "started.."
if [ "X$CONFIG_LIST" == "X" ]; then
	echo "Must provide config list for statisics!" >&2
	exit 1
fi

echo "sep=;">$OUTPUT_FILE
echo "name; file;" >>$OUTPUT_FILE

while read -r dd
do
	files=$(git grep --no-color ${dd} | grep -v ${dd}_ | grep -v backports |cut -d":" -f1 | uniq)
	for file in ${files}
	do
		echo "${dd}; ${file};"
		echo "${dd}; ${file};" >>$OUTPUT_FILE
	done
done < $CONFIG_LIST

