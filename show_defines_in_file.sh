#!/bin/bash

NEVER_CONFIG_LIST=$1; shift
ALWAYS_CONFIG_LIST=$1; shift
FILE_CHECKED=$1; shift
IGNORE_LIST=$1; shift
MY_BRANCH=$(cat ./.git/HEAD | sed -e 's/.*heads\///')
if [[ ! $MY_BRANCH == *"backport"* ]]; then
        echo "-E- script must run over backport branch!"
        echo "please congifure before running this script"
        exit 1
fi
TEMP_FILE="temp_file_to_delete"
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
if [ "X$IGNORE_LIST" == "X" ]; then
	echo "************************************" >$TEMP_FILE
	echo "* NOTICE: no ignore list provided! *" >>$TEMP_FILE
	echo "************************************" >>$TEMP_FILE
	echo >>$TEMP_FILE
else
	echo >$TEMP_FILE
fi
echo "SCRIPT START" >&2
echo "checking never/always set defines in file: '${FILE_CHECKED}'" >&2
if [ ! "X$NEVER_CONFIG_LIST" == "X" ]; then
	echo "NEVER SET in file" >>$TEMP_FILE
	echo "-----------------" >>$TEMP_FILE
	while read -r dd
	do
		if (grep -q ${dd} ${FILE_CHECKED}); then
			if [ ! "X$IGNORE_LIST" == "X" ]; then
				if (grep -q ${dd} $IGNORE_LIST); then
					echo "-I- Ignoring a never set define: $dd" >>$TEMP_FILE
				else
					echo "${dd}" >>$TEMP_FILE
				fi
			else
				echo "${dd}" >>$TEMP_FILE
			fi
		fi
	done < $NEVER_CONFIG_LIST
fi
if [ ! "X$ALWAYS_CONFIG_LIST" == "X" ]; then
	echo >>$TEMP_FILE
	echo "ALWAYS SET in file" >>$TEMP_FILE
	echo "------------------" >>$TEMP_FILE
	while read -r dd
	do
		if (grep -q ${dd} ${FILE_CHECKED}); then
			if [ ! "X$IGNORE_LIST" == "X" ]; then
				if (grep -q ${dd} $IGNORE_LIST); then
					echo "-I- Ignoring a always set define: $dd" >>$TEMP_FILE
				else
					echo "${dd}" >>$TEMP_FILE
				fi
			else
				echo "${dd}" >>$TEMP_FILE
			fi
		fi
	done < $ALWAYS_CONFIG_LIST
fi
echo "opening vim with vsplit mode" >&2
vim -O $FILE_CHECKED $TEMP_FILE

echo "SCRIPT END" >&2
