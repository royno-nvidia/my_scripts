#!/bin/bash

NEVER_CONFIG_LIST=$1; shift
ALWAYS_CONFIG_LIST=$1; shift
FILE_CHECKED=$1; shift
if [ "X$FILE_CHECKED" == "X" ]; then
	echo "Must provide file to check!" >&2
	exit 1
fi
if [ "X$NEVER_CONFIG_LIST" == "X" ]; then
	echo "Must provide at never set config list!" >&2
	exit 1
fi
if [ "X$ALWAYS_CONFIG_LIST" == "X" ]; then
	echo "Must provide at ALWAYS set config list!" >&2
	exit 1
fi
echo 
echo "checking never/always set defines in file: '${FILE_CHECKED}'"
echo
if [ ! "X$NEVER_CONFIG_LIST" == "X" ]; then
	echo "NEVER SET in file"
	echo "-----------------"
	while read -r dd
	do
		if (grep -q ${dd} ${FILE_CHECKED}); then
			echo "${dd}"
		fi
	done < $NEVER_CONFIG_LIST
fi
if [ ! "X$ALWAYS_CONFIG_LIST" == "X" ]; then
	echo
	echo "ALWAYS SET in file"
	echo "------------------"
	while read -r dd
	do
		if (grep -q ${dd} ${FILE_CHECKED}); then
			echo "${dd}"
		fi
	done < $ALWAYS_CONFIG_LIST
fi
